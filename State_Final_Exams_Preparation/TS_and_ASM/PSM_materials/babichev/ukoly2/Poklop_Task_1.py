import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import PolynomialFeatures
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, r2_score
from pyloess import loess
from statsmodels.nonparametric.smoothers_lowess import lowess


#načetení dat
def Load_data(path): return pd.read_csv(path)

# výpočet potřebných metrik r^2 a rmse
def vypocitej_metriky(y_test, y_predikce):
    rmse = np.sqrt(mean_squared_error(y_test, y_predikce))
    r2 = r2_score(y_test, y_predikce)
    return rmse, r2

# LOESS regrese
def Loess_regrese(X_train, Y_train, X_test, feature_columns):
    loess_predictions = []
    for feature in feature_columns:
        #X_train_new = np.linspace(min(X_train[feature]), max(X_train[feature]), num=len(X_train[feature]))
        #loess_fit_y = loess(X_train[feature], Y_train[feature], eval_x=X_train_new, span=0.7, degree=2)
        #loess_predictions.append(np.interp(X_test[feature], loess_fit_y[:, 0], loess_fit_y[:, 1]))
        # Fit LOESS pro každou vlastnost
        loess_result = lowess(Y_train, X_train[feature], frac=0.7, it=0)
        # Predikce pro testovací data pomocí interpolace
        loess_pred = np.interp(X_test[feature], loess_result[:, 0], loess_result[:, 1])
        loess_predictions.append(loess_pred)

    loess_predictions = np.mean(np.array(loess_predictions), axis=0)
    return loess_predictions

# polynomiální regres
def Poly_regrese(X_train, y_train, X_test):
    poly = PolynomialFeatures(degree=2)
    X_poly_train = poly.fit_transform(X_train)
    X_poly_test = poly.transform(X_test)
    poly_model = LinearRegression().fit(X_poly_train, y_train)
    y_poly_predictions = poly_model.predict(X_poly_test)
    return y_poly_predictions

#vykreslení polynomiální a LOESS regrese
def plot_regressions(y_test , y_loess_predictions, y_poly_predictions):
    plt.figure(figsize=(14, 7))

    plt.subplot(1, 2, 1)
    plt.scatter(y_test, y_loess_predictions, alpha=0.5) #body
    plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'r--') #cara
    plt.xlabel('Aktuální proměnná'); plt.ylabel('Predikovaná proměnná'); plt.title('LOESS Regression')

    plt.subplot(1, 2, 2)
    plt.scatter(y_test, y_poly_predictions, alpha=0.5) #body
    plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'r--') #cara
    plt.xlabel('Aktuální proměnná'); plt.ylabel('Predikovaná'); plt.title('Polynomial Regression')

    plt.tight_layout(); plt.show()

#načtení dat z csv souboru
data = Load_data(r'C:\Users\imang\OneDrive\Plocha\PSM\babichev\ukoly2\manufacturing.csv')
#výpis informací o tabulce
print("Hlavička:",data.head(),"\n", data.info(),"\n", data.describe())

#definování proměnných
target = 'Quality Rating' # cílová proměnná
feature_columns = data.columns.drop(target) # ostatní proměnné jako vlastnosti

# rozdělení dat na trénovací a testovací
X_train, X_test, y_train, y_test = train_test_split(data[feature_columns], data[target], test_size=0.3, random_state=42)

# LOESS regrese
loess_predictions = Loess_regrese(X_train, y_train, X_test, feature_columns)

# metriky loess regrese
#print("\nVýsledky LOESS regrese:")
#for y_prediction in loess_predictions:
#    rmse, r2 = vypocitej_metriky(y_test, y_prediction)
#    print(f"RMSE: {rmse:.4f}")
#    print(f"R²: {r2:.4f}")


#poly regrese
poly_predictions = Poly_regrese(X_train, y_train, X_test)

#metriky poly regrese
#print("\nVýsledky polynomiální regrese",":")
#for y_prediction in loess_predictions:
#    rmse, r2 = vypocitej_metriky(y_test, y_prediction)
#    print(f"RMSE: {rmse:.4f}")
#    print(f"R²: {r2:.4f}")

#vykreslení regresí
plot_regressions(y_test, loess_predictions, poly_predictions)