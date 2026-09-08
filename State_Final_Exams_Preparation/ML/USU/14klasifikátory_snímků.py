import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

from sklearn.ensemble import RandomForestClassifier
from sklearn.tree import DecisionTreeClassifier

import matplotlib.pyplot as plt
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score

# metoda pro generovani datasetu
def transform(data, k_predem):
  X=[]; y=[]
  for row in range(k_predem, len(data)-1):
     X.append(data[row-k_predem:row].to_numpy().flatten())
     y.append(int(data.iloc[row+1]["dest"]>0))
  return np.array(X), y

def Create_train_data(df, n_keypoints, n_features, n_samples):
    X,y = transform(df, target_column_number)
    #normalizace dat
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)
    #zozdělení dat na trénovací a testovací podmonožinu
    X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.3, random_state=42)
    rf = RandomForestClassifier(n_estimators = 100,random_state=42)
    rf.fit(X_train, y_train)
    return X_train, X_test, y_train, y_test

#načtení a zpracování dat
X_train, X_test, y_train, y_test = Create_train_data(df, 1)
def prepare_data(df, target_columns, pred_columns, feature_columns, feature_cols=None, test_size=0.2, random_state=42):
    if feature_cols is None:
        # Použití všech sloupců kromě cílových a predikovaných
        all_columns = set(df.columns)
        target_pred_columns = set(target_columns + pred_columns)
        feature_columns = list(all_columns - target_pred_columns)
    else:
        feature_columns = feature_cols
    X = df[feature_columns].values
    y = df[target_columns].values.reshape(-1, n_keypoints, 2)
    return train_test_split(X, y, test_size=test_size, random_state=random_state)

def example_usage(n_keypoints=23):
    # Načtení CSV souboru
    df = pd.read_csv('Data/data-recovery.csv', sep=",")
    feature_columns = None  # Definovat později podle dat
    target_columns = _get_target_columns()
    pred_columns = _get_pred_columns()

    print("Chybejici hodnoty: ", df.isnull().sum())
    #df.dropna()
    print(df.head())
    print(df.describe())

    # Příprava dat
    X_train, X_test, y_train, y_test = processor.prepare_data()

    print(f"Trénovací data: {X_train.shape}, {y_train.shape}")
    print(f"Testovací data: {X_test.shape}, {y_test.shape}")

    # Trénování modelu
    model = processor.train_model(X_train, y_train, X_test, y_test, epochs=20)
    # Predikce
    predictions = processor.predict(model, X_test)
    # Vyhodnocení
    metrics = processor.evaluate(y_test, predictions)

    print("Výsledky:")
    print(f"Průměrná MSE: {metrics['overall']['avg_mse']:.4f}")
    print(f"Průměrná vzdálenost: {metrics['overall']['avg_distance']:.4f}")

    # Vizualizace výsledků pro první testovací vzorek
    processor.visualize_keypoints(None, y_test[0], predictions[0])

    # Export predikcí do CSV
    pred_df = processor.format_predictions_to_csv(predictions)
    pred_df.to_csv('predictions.csv', index=False)