import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, r2_score
from sklearn.preprocessing import StandardScaler
import statsmodels.api as sm
from statsmodels.stats.outliers_influence import variance_inflation_factor
from scipy import stats

#načetení dat
def Load_data(path): return pd.read_csv(path)
#průzkum dat
def data_info(df):
    print("Data Head:\n", df.head(), "\nData Info:\n", df.info(), "\nData Description:\n", df.describe(),"\nMissing Values:\n", df.isnull().sum())

#analýza multikolinearity
def check_multicollinearity(df, target_column, threshold=80.0):
    df = df.drop(columns=[target_column], errors='ignore')
    X = df.select_dtypes(include=[np.number]) # Cílový sloupec ponecháme
    vif_data = pd.DataFrame()
    vif_data["feature"] = X.columns
    vif_data["VIF"] = [variance_inflation_factor(X.values, i) for i in range(len(X.columns))]
    print("\nVIF Data:\n", vif_data)

    #odstranění sloupců s vysokům VIF
    high_vif_features = vif_data[vif_data["VIF"] > threshold]["feature"].tolist()
    df = df.drop(columns=high_vif_features, errors='ignore')
    print("\nOdstraněny sloupce s vysokým VIF ", threshold ,":", high_vif_features)
    return df

def delete_column(df, column_name):
    #smazání zbytečného sloupce
    df = df.drop(column_name, errors='ignore')

#odstranění zbytečného sloupce, rozdělení dat na trénovací a testovací množinu
def split_scale_normalise_data(df, target_column):
    #výjimka pokud sloupec v db neexistuje
    if target_column not in df.columns: raise ValueError(f"Cílový sloupec '{target_column}' není v datasetu!")
    #zozdělení dat na trénovací a testovací podmonožinu
    X = df.drop(target_column, axis=1)
    y = df[target_column]
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

    #normalizace dat
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)

    return X_train_scaled, X_test_scaled, y_train, y_test

#vytvoření a trénování lineárního modelu
def train_model(X_train, y_train):
    model = LinearRegression()
    model.fit(X_train, y_train)
    return model

#statistická významnost koeficientů
def test_significance(X_train, y_train):
    X_train_const = sm.add_constant(X_train)
    model = sm.OLS(y_train, X_train_const).fit()
    print("\nStatistická významnost koeficientů:\n", model.summary())

#vyhodnocení modelu
def evaluate_model(model, X_test, y_test):
    y_pred = model.predict(X_test)
    rmse = np.sqrt(mean_squared_error(y_test, y_pred))
    r2 = r2_score(y_test, y_pred)
    print("\nModel Performance:\n","RMSE:", rmse, "\nR2 Score:", r2)

#načtení dat
df = Load_data(r'C:\Users\imang\OneDrive\Plocha\PSM\babichev\ukoly2\house_data.csv')

# průzkum dat
data_info(df) #výpis informací o tabulce

# kontrola multikolimearity
check_multicollinearity(df, "MEDV")

# odstranění zbytečného sloupce
delete_column(df,"CHAS")

# rozdělení dat a vytvoření regresního modelu, normalizace testovacích dat
X_train, X_test, y_train, y_test = split_scale_normalise_data(df, 'MEDV')

# trénování modelu
model = train_model(X_train, y_train)

# test významnosti koeficientů
test_significance(X_train, y_train)

# porovnání výsledků
evaluate_model(model, X_test, y_test)