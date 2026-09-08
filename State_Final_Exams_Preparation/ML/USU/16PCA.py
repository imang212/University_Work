import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split

from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier

from sklearn.svm import SVC
from sklearn.preprocessing import LabelEncoder
from sklearn.base import BaseEstimator, ClassifierMixin
from sklearn.model_selection import cross_val_score

from sklearn.metrics import roc_curve, roc_auc_score, confusion_matrix, classification_report, accuracy_score

def Create_train_data(df, target_column_number):
    X,y = transform(df, target_column_number)
    # Zpracování chybějících hodnot pomocí mediánu
    #imputer = SimpleImputer(strategy='median')
    #X_imputed = pd.DataFrame(imputer.fit_transform(X), columns=X.columns)

    #normalizace dat
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)

    #zozdělení dat na trénovací a testovací podmonožinu
    X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.3, random_state=42)


    return X_train, X_test, y_train, y_test

def Create_and_train_models(X_train, y_train):
    # Logistická regrese
    #lr = LogisticRegression(random_state=42)
    #lr.fit(X_train, y_train)
    # Rozhodovací strom
    dt = DecisionTreeClassifier(random_state=42)
    dt.fit(X_train, y_train)
    # Random Forest
    rf = RandomForestClassifier(n_estimators = 100,random_state=42)
    rf.fit(X_train, y_train)
    # nahrazení nulovách hodnot průměrem pro log. regresi
    imputer = SimpleImputer(strategy='mean')
    imputer.fit(X_train)
    X_train_imputed = imputer.transform(X_train)
    lr = LogisticRegression(random_state=42)
    lr.fit(X_train_imputed, y_train)
    return {'Rozhodovací strom': dt, 'Random Forest': rf, 'Lineární regrese': lr}

def Vykresli_a_vyhodnot_modely(models, X_test, y_test, dataset_name):
    models_count = len(models)
    # vytvoření figur pro confusion matrixy
    fig_cm, axes_cm = plt.subplots(1, models_count, figsize=(6*models_count,5))
    fig_cm.suptitle(f'Confusion Matrix - {dataset_name}', fontsize=16, y=0.98)
    # vytvoření figur pro ROC křivky
    fig_roc, axes_roc = plt.subplots(1, models_count, figsize=(6*models_count,5))
    fig_roc.suptitle(f'ROC křivka - {dataset_name}', fontsize=16, y=0.98)

    if models_count == 1: axes_cm = [axes_cm]; axes_roc = [axes_roc]

    # Pro každý model provedem vyhodnocení
    for i, (name, model) in enumerate(models.items()):
        # Získání predikcí ke každému trénovacímu modelu
        y_pred = model.predict(X_test)
        y_pred_proba = model.predict_proba(X_test)[:, 1]
        # Confusion Matrix
        cm = confusion_matrix(y_test, y_pred)
        sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', ax=axes_cm[i])
        axes_cm[i].set_title(f'Confusion Matrix - {name} - {dataset_name}')
        axes_cm[i].set_ylabel('Skutečná třída')
        axes_cm[i].set_xlabel('Predikovaná třída')
        # Classification Report
        print(f"\nClassification Report - {name} - {dataset_name}:")
        print(classification_report(y_test, y_pred))

        # ROC křivka a AUC score
        fpr, tpr, _ = roc_curve(y_test, y_pred_proba)
        roc_auc = roc_auc_score(y_test, y_pred_proba)
#
        #axes_roc[i].plot(fpr, tpr, label=f'AUC = {roc_auc:.3f}')
        #axes_roc[i].plot([0, 1], [0, 1], 'k--')
        #axes_roc[i].set_xlabel('False Positive Rate')
        #axes_roc[i].set_ylabel('True Positive Rate')
        #axes_roc[i].set_title(f'ROC křivka - {name} - {dataset_name}')
        #axes_roc[i].legend()
        print(f"AUC skóre - {name} - {dataset_name}: {roc_auc:.3f}")

    fig_cm.tight_layout()
    fig_cm.savefig(f"{dataset_name}_confusion_matrices.png")
    plt.close(fig_cm)

    #fig_roc.tight_layout()
    #fig_roc.savefig(f"{dataset_name}_roc_curves.png")
    #plt.close(fig_roc)

#načtení a zpracování dat
df = pd.read_csv('Data/kopisty_pocasi_rozsireno.csv', decimal=',', sep=";", parse_dates=['datum'], dayfirst=True)
df['datum'] = pd.to_datetime(df['datum'], format='%Y-%m-%d')
df.dropna()
print(df.head())
print("Chybejici hodnoty: ", df.isnull().sum())
df.drop(columns="vypar", inplace=True)
print(df.head())
print(df.describe())

#vykreslení korelační matice
plt.figure(figsize=(10, 6))
sns.heatmap(df.corr(), annot=True, cmap='coolwarm', fmt=".2f", linewidths=0.5)
plt.title("Korelační matice"); plt.show()
correlation_matrix = df.corr()
print("Korelační matice:\n", correlation_matrix)

# extrakce pozadovanych sloupcu
data = pd.DataFrame()
data["dest"]=(df["uhrn_srazky_1"]+df["uhrn_srazky_2"])/2
data["teplota"]=df['teplota']
data["vitr"]=df["rychlost_vitr"]
data["vlhkost"] = df['vlhkost']
data["tlak"]=df["tlak"]
data["obdobi"]=df['datum'].dt.month

# metoda pro generovani datasetu
def transform(data, k_predem):
  X=[]; y=[]
  for row in range(k_predem, len(data)-1):
     X.append(data[row-k_predem:row].to_numpy().flatten())
     y.append(int(data.iloc[row+1]["dest"]>0))
  return np.array(X), y

X_train, X_test, y_train, y_test = Create_train_data(data, 3)
models = Create_and_train_models(X_train, y_train)
Vykresli_a_vyhodnot_modely(models, X_test, y_test, "Pocasi")