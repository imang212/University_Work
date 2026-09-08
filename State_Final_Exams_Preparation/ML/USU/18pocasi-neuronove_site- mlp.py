import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler, RobustScaler
from sklearn.model_selection import train_test_split

from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier

from sklearn.svm import SVC
from sklearn.preprocessing import LabelEncoder
from sklearn.base import BaseEstimator, ClassifierMixin
from sklearn.model_selection import cross_val_score

from sklearn.metrics import roc_curve, roc_auc_score, confusion_matrix, classification_report, accuracy_score

# metoda pro generovani datasetu
def transform(data, k_predem):
  X=[]; y=[]
  for row in range(k_predem, len(data)-1):
     X.append(data[row-k_predem:row].to_numpy().flatten())
     y.append(int(data.iloc[row+1]["dest"]>0))
  return np.array(X), y

def Create_train_data(df, target_column_number):
    X, y = transform(df, target_column_number)
    #normalizace dat
    scaler = RobustScaler()#StandardScaler()
    X_scaled = scaler.fit_transform(X)
    #zozdělení dat na trénovací a testovací podmonožinu
    X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.3, random_state=42)
    return X_train, X_test, y_train, y_test

#načtení a zpracování dat
df = pd.read_csv('Data/kopisty_pocasi_rozsireno.csv', decimal=',', sep=";", parse_dates=['datum'], dayfirst=True)
df['datum'] = pd.to_datetime(df['datum'], format='%Y-%m-%d')
df.dropna()
print(df.head()); print("Chybejici hodnoty: ", df.isnull().sum())
df.drop(columns="vypar", inplace=True)
print(df.head()); print(df.describe())

#vykreslení korelační matice
plt.figure(figsize=(10, 6))
sns.heatmap(df.corr(), annot=True, cmap='coolwarm', fmt=".2f", linewidths=0.5)
plt.title("Korelační matice"); plt.show()
correlation_matrix = df.corr()
print("Korelační matice:\n", correlation_matrix)

# extrakce pozadovanych sloupcu
data = pd.DataFrame()
data["dest"]=(df["uhrn_srazky_1"]+df["uhrn_srazky_2"])/2; data["teplota"]=df['teplota']; data["vitr"]=df["rychlost_vitr"]; data["vlhkost"] = df['vlhkost']; data["tlak"]=df["tlak"]; data["obdobi"]=df['datum'].dt.month


# vytvoření neuronových síťí na počasí
import tensorflow as tf
from tensorflow.keras import models, layers

X_train, X_test, y_train, y_test = Create_train_data(data, 3)

def get_model(input_shape, units = [12, 24], activations=['relu', 'relu'], dropout = 0.1):
  model = models.Sequential()
  assert len(units)==len(activations), "units and activations must have the same length"
  model.add(layers.Dense(units = units[0], input_shape = input_shape , activation = activations[0]))
  if dropout is not None:
    model.add(layers.Dropout(dropout))
  for i in range(1, len(units)):
    model.add(layers.Dense(units = units[i], activation = activations[i]))
    if dropout is not None:
      model.add(layers.Dropout(dropout))
  model.add(layers.Dense(1, activation='sigmoid'))
  model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
  return model

EPOCHS = 40
model = get_model(input_shape=(X_train.shape[1],)) # propis tam sloupce
history = model.fit(np.array(X_train), np.array(y_train), epochs=EPOCHS, validation_split=0.1) #!data musí být v np.array()
plt.rcParams["figure.figsize"] = [12,4]
figure, axis = plt.subplots(1, 2)

axis[0].plot(history.history['loss'], label='loss - training data')
axis[0].plot(history.history['val_loss'], label='loss - validating data')
axis[0].grid(); axis[0].set_title('Loss'); axis[0].legend()


axis[1].plot(history.history['accuracy'], label='accuracy - training data')
axis[1].plot(history.history['val_accuracy'], label='accuracy - validating data')
axis[1].grid(); axis[1].set_title('Accuracy'); axis[1].legend()

model.summary()