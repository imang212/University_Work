import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import mean_absolute_error, r2_score


def Load_data(path):
    data = pd.read_csv(path, sep=';')
    return data

def Vypis_informace(data):
    print("Data Head:\n", data.head(), "\nData Info:\n", data.info(), "\nData Description:\n", data.describe(),"\nMissing Values:\n", data.isnull().sum(),'\n')

def Process_and_create_train_model(df, target_column):
    #oddělení cílové proměnné
    X = df.drop(target_column, axis=1)
    y = df[target_column]

    # Zpracování chybějících hodnot pomocí mediánu
    imputer = SimpleImputer(strategy='median')
    X_imputed = pd.DataFrame(imputer.fit_transform(X), columns=X.columns)

    #normalizace dat
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X_imputed)

    #zozdělení dat na trénovací a testovací podmonožinu (70/30)
    X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.3, random_state=42)

    return X_train, X_test, y_train, y_test

def Create_train_models(X_train, y_train):
    # Rozhodovací strom
    dt = DecisionTreeClassifier(random_state=42)
    dt.fit(X_train, y_train)
    # Random Forest
    rf = RandomForestClassifier(random_state=42)
    rf.fit(X_train, y_train)
    return {'Rozhodovací strom': dt, 'Random Forest': rf}

def Vykresli_a_vyhodnot_modely(models, X_test, y_test, main_name):
    results = {}
    models_count = len(models)
    fig, axes = plt.subplots(2, models_count, figsize=(6*models_count, 10))
    fig.suptitle(main_name, fontsize=16, y=0.98)

    if models_count == 1: axes = axes.reshape(2, 1)

    for i, (name, model) in enumerate(models.items()):
        #predikce
        y_pred = model.predict(X_test)
        #výpočet metrik
        mse = mean_absolute_error(y_test,y_pred)
        rmse = np.sqrt(mse)
        r2 = r2_score(y_test, y_pred)
        results[name] = {'MSE':mse, 'RMSE':rmse, 'R2': r2}

        #zobrazení skutečných a predikovaných hodnot
        axes[0, i].scatter(y_test, y_pred, alpha=0.5)
        axes[0, i].plot([y_test.min(), y_pred.max()], [y_test.min(),y_pred.max()], "r--")
        axes[0, i].set_xlabel('Skutečné hodnoty'); axes[0, i].set_ylabel('Predikované hodnoty')
        axes[0, i].set_title(f'{name} - Predikce vs. Skutečnost')

        #zobrazení residualů
        residuals = y_test - y_pred
        axes[1, i].scatter(y_test, residuals, alpha=0.5)
        axes[1, i].axhline(y=0, color='r',linestyle='--')
        axes[1, i].set_xlabel('Skutečné hodnoty'); axes[1, i].set_ylabel('Residuály')
        axes[1, i].set_title(f'{name} - Residuály')

        print(f"\nVýsledky pro model: {name}\n",f"MSE: {mse:.4f}\n", f"RMSE: {rmse:.4f}\n"f"R2 skóre: {r2:.4f}")

    #přidání mezer mezi subploty
    plt.tight_layout()
    plt.savefig('model_comparsion.png'); plt.close()

    return results

def Porovnej_modely(results):
    # Tabulkové srovnání
    print("\nSrovnání modelů:")
    comparison_df = pd.DataFrame.from_dict(results, orient='index')
    print(comparison_df)

    # Určení nejlepšího modelu
    best_model_mse = min(results.items(), key=lambda x: x[1]['MSE'])[0]
    best_model_r2 = max(results.items(), key=lambda x: x[1]['R2'])[0]
    print(f"\nNejlepší model podle MSE: {best_model_mse}")
    print(f"Nejlepší model podle R2: {best_model_r2}")

df = Load_data(r'C:\Users\imang\OneDrive\Plocha\PSM\babichev\ukoly3\winequality-red.csv')

Vypis_informace(df)

X_train, X_test, y_train, y_test = Process_and_create_train_model(df, "quality")

models = Create_train_models(X_train, y_train)

results = Vykresli_a_vyhodnot_modely(models, X_test, y_test, main_name='ANALÝZA DATASETU WINE QUALITY (RED)')

Porovnej_modely(results)