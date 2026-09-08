import os
import numpy as np
import pandas as pd
from PIL import Image
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
import torchvision.transforms as transforms
import torchvision.models as models
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, f1_score, classification_report
import matplotlib.pyplot as plt
import tensorflow as tf
import tensorflow_datasets as tfds
from pathlib import Path
import glob, json

def load_bee_dataset(data_dir, labels_file):
    data_path = Path(data_dir)
    if not data_path.exists(): raise FileNotFoundError(f"Data directory {data_dir} not found")
    image_extensions = ['*.jpg', '*.jpeg', '*.png']; image_paths = []
    for ext in image_extensions:
        image_paths.extend(glob.glob(str(data_path / '**' / ext), recursive=True))
    print(f"Found {len(image_paths)} images in {data_dir}")
    with open(labels_file, 'r') as f:
        labels_dict = json.load(f)
    labels = []
    valid_image_paths = []
    for img_path in image_paths:
        img_name = Path(img_path).name
        if img_name in labels_dict:
            img_labels = labels_dict[img_name]
            label = [
                1 if img_labels.get('cooling', False) else 0,
                1 if img_labels.get('pollen', False) else 0,
                1 if img_labels.get('varroa', False) else 0,
                1 if img_labels.get('wasps', False) else 0
            ]
            labels.append(label)
            valid_image_paths.append(img_path)
    if labels: labels = np.array(labels,  dtype=np.float32)
    print(f"Prepared dataset with {len(image_paths)} labeled images: {labels}")
    return image_paths, labels

def get_transforms():
    """Definování transformací obrázků pro trénování a validaci"""
    train_transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.RandomHorizontalFlip(),
        transforms.RandomRotation(10),
        transforms.ColorJitter(brightness=0.2, contrast=0.2),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])
    val_transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])
    return train_transform, val_transform

class BeeDataset(Dataset):
    def __init__(self, image_paths, labels=None, transform=None):
        self.image_paths = image_paths
        self.labels = labels
        self.transform = transform
    def __len__(self): return len(self.image_paths)
    def __getitem__(self, idx):
        img_path = self.image_paths[idx]
        image = Image.open(img_path).convert('RGB')
        if self.transform:
            image = self.transform(image)
        if self.labels is not None:
            label = self.labels[idx]
            return image, torch.FloatTensor(label)
        else: return image

# vytvoření multi-label klasifikátoru pomocí resnet50
class BeeClassifier(nn.Module):
    def __init__(self, num_classes=4):
        super(BeeClassifier, self).__init__()
        self.resnet = models.resnet50(pretrained=True)
        # zmrazení posledních 10 vrstev
        for param in list(self.resnet.parameters())[:-10]:
            param.requires_grad = False
        # nahrazení finální plně připojené vrstvy pro multilabel kalsifikaci
        in_features = self.resnet.fc.in_features
        self.resnet.fc = nn.Sequential(nn.Linear(in_features, 256), nn.ReLU(), nn.Dropout(0.3), nn.Linear(256, num_classes), nn.Sigmoid()) # Sigmoid for multilabel classification
    # přední vrstva
    def forward(self, x):
        return self.resnet(x)

def train_model(model, train_loader, val_loader, criterion, optimizer, scheduler, num_epochs=10):
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Using device: {device}")
    model = model.to(device)
    best_val_f1 = 0.0
    train_losses = []; val_losses = []
    for epoch in range(num_epochs):
        # Training phase
        model.train()
        running_loss = 0.0
        for inputs, labels in train_loader:
            inputs = inputs.to(device)
            labels = labels.to(device)
            optimizer.zero_grad()
            outputs = model(inputs)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
            running_loss += loss.item() * inputs.size(0)

        epoch_train_loss = running_loss / len(train_loader.dataset)
        train_losses.append(epoch_train_loss)
        # Validation phase
        model.eval()
        running_loss = 0.0
        all_preds = []; all_labels = []
        with torch.no_grad():
            for inputs, labels in val_loader:
                inputs = inputs.to(device)
                labels = labels.to(device)
                outputs = model(inputs)
                loss = criterion(outputs, labels)

                running_loss += loss.item() * inputs.size(0)
                # Convert probabilities to binary predictions using 0.5 threshold
                preds = (outputs > 0.5).float().cpu().numpy()
                all_preds.extend(preds)
                all_labels.extend(labels.cpu().numpy())

        epoch_val_loss = running_loss / len(val_loader.dataset)
        val_losses.append(epoch_val_loss)
        # Calculate metrics
        all_preds = np.array(all_preds)
        all_labels = np.array(all_labels)
        # Calculate F1 score for each class and average
        f1_scores = []
        for i in range(all_labels.shape[1]):
            f1 = f1_score(all_labels[:, i], all_preds[:, i], zero_division=0)
            f1_scores.append(f1)
        avg_f1 = np.mean(f1_scores)
        print(f'Epoch {epoch+1}/{num_epochs}:')
        print(f'Train Loss: {epoch_train_loss:.4f}, Val Loss: {epoch_val_loss:.4f}')
        print(f'F1 Scores: Cooling: {f1_scores[0]:.4f}, Pollen: {f1_scores[1]:.4f}, Varroa: {f1_scores[2]:.4f}, Wasps: {f1_scores[3]:.4f}')
        print(f'Average F1: {avg_f1:.4f}')
        # Update learning rate
        scheduler.step(epoch_val_loss)
        # Save best model
        if avg_f1 > best_val_f1:
            best_val_f1 = avg_f1
            torch.save(model.state_dict(), 'best_bee_classifier.pth')
            print("Saved best model!")
        print("-" * 60)
    plt.figure(figsize=(10, 5))
    plt.plot(range(1, num_epochs+1), train_losses, label='Training Loss')
    plt.plot(range(1, num_epochs+1), val_losses, label='Validation Loss')
    plt.xlabel('Epoch'); plt.ylabel('Loss'); plt.title('Training and Validation Loss')
    plt.legend(); plt.savefig('loss_plot.png'); plt.close()
    return model

def evaluate_model(model, test_loader):
    """Evaluate the model on test data"""
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model = model.to(device)
    model.eval()
    all_preds = []; all_labels = []
    with torch.no_grad():
        for inputs, labels in test_loader:
            inputs = inputs.to(device)
            outputs = model(inputs)
            # Convert probabilities to binary predictions using 0.5 threshold
            preds = (outputs > 0.5).float().cpu().numpy()
            all_preds.extend(preds)
            all_labels.extend(labels.numpy())
    all_preds = np.array(all_preds)
    all_labels = np.array(all_labels)
    # Calculate metrics
    class_names = ['cooling', 'pollen', 'varroa', 'wasps']
    for i, class_name in enumerate(class_names):
        print(f"Class: {class_name}")
        print(classification_report(all_labels[:, i], all_preds[:, i]))
    # Calculate overall metrics
    accuracy = np.mean(np.all(all_preds == all_labels, axis=1))
    print(f"Exact Match Accuracy: {accuracy:.4f}")
    # Calculate F1 score for each class
    f1_scores = []
    for i in range(all_labels.shape[1]):
        f1 = f1_score(all_labels[:, i], all_preds[:, i], zero_division=0)
        f1_scores.append(f1)
    avg_f1 = np.mean(f1_scores)
    print(f"Average F1 Score: {avg_f1:.4f}")
    return all_preds, all_labels


if __name__ == "__main__":
    # Set random seed for reproducibility
    torch.manual_seed(42)
    np.random.seed(42)
    data_dir = "./dummy_data/images_300"
    labels_file = "./dummy_data/data.json"  # Optional, set to None if unavailable
    print("Loading dataset...")
    image_paths, labels = load_bee_dataset(data_dir, labels_file)
    # Split data into train, validation, and test sets
    train_images, test_images, train_labels, test_labels = train_test_split(image_paths, labels, test_size=0.2, random_state=42)
    train_images, val_images, train_labels, val_labels = train_test_split(train_images, train_labels, test_size=0.2, random_state=42)
    print(f"Train images: {len(train_images)}, Train labels: {len(train_labels)}")
    print(f"Val images: {len(val_images)}, Val labels: {len(val_labels)}")
    print(f"Test images: {len(test_images)}, Test labels: {len(test_labels)}")
    # Get transforms
    train_transform, val_transform = get_transforms()
    # Create dataset objects
    train_dataset = BeeDataset(train_images, train_labels, transform=train_transform)
    val_dataset = BeeDataset(val_images, val_labels, transform=val_transform)
    test_dataset = BeeDataset(test_images, test_labels, transform=val_transform)
    # Create data loaders
    train_loader = DataLoader(train_dataset, batch_size=32, shuffle=True, num_workers=4)
    val_loader = DataLoader(val_dataset, batch_size=32, shuffle=False, num_workers=4)
    test_loader = DataLoader(test_dataset, batch_size=32, shuffle=False, num_workers=4)
    # Create model
    model = BeeClassifier(num_classes=4)
    # Define optimizer and loss function
    criterion = nn.BCELoss()  # Binary Cross Entropy Loss for multilabel classification
    optimizer = optim.Adam(model.parameters(), lr=0.001)
    scheduler = optim.lr_scheduler.ReduceLROnPlateau(optimizer, mode='min', factor=0.1, patience=3)
    print("Training model...")
    model = train_model(model=model, train_loader=train_loader, val_loader=val_loader, criterion=criterion, optimizer=optimizer, scheduler=scheduler, num_epochs=15)
    # Load the best model
    model.load_state_dict(torch.load('best_bee_classifier.pth'))
    print("Evaluating model...")
    predictions, true_labels = evaluate_model(model, test_loader)
    print("\nExample of model prediction:")
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model = model.to(device)
    model.eval()
    # Get a sample image
    sample_img, sample_label = test_dataset[0]
    sample_img = sample_img.unsqueeze(0).to(device)
    with torch.no_grad():
        output = model(sample_img)
        probabilities = output.cpu().numpy()[0]
        predictions = (output > 0.5).float().cpu().numpy()[0]
    class_names = ['cooling', 'pollen', 'varroa', 'wasps']
    print("Probabilities:")
    for i, class_name in enumerate(class_names):
        print(f"{class_name}: {probabilities[i]:.4f} (Prediction: {predictions[i]})")
    print("\nTrue labels:")
    for i, class_name in enumerate(class_names):
        print(f"{class_name}: {sample_label[i]}")
