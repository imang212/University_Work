import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression #import modulu pro lineární regresi
from sklearn.preprocessing import PolynomialFeatures #import modulu pro polynomiální regresní model
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score #import modulů pro výpočty kritérií kvality


# Načtení dat z obou souborů
def load_data_1(filename):
    return pd.read_csv(filename, sep='\s+', header=None,skiprows=1, converters={0: lambda x: float(x.strip('"')), 1: lambda x: float(x.strip('"'))})

def load_data_2(filename):
    return pd.read_csv(filename, sep='\s+', header=None, skiprows=1, converters={0: lambda x: float(x.strip('"')), 1: lambda x: float(x.strip('"')), 2: float})

# Vizualizace dat pomocí bodového grafu
def vykresli_bodovy_graf(X_simplreg, Y_simplreg, X_fruitohms, Y_fruitohms):
    plt.figure(figsize=(10, 5))
    #fruitohms
    plt.subplot(1, 2, 1)
    plt.scatter(X_simplreg, Y_simplreg); plt.title('Y=F(X)'); plt.xlabel('X'); plt.ylabel('Y')
    #fruitohms
    plt.subplot(1, 2, 2)
    plt.scatter(X_fruitohms, Y_fruitohms); plt.title('juice=F(ohms)'); plt.xlabel('ohms'); plt.ylabel('juice')
    plt.savefig('scatters.png'); plt.close()

# výpočet kritérií kvality
def calculate_quality_criteria(y_true, y_pred):
    mse = mean_squared_error(y_true, y_pred) #MSE
    rmse = np.sqrt(mse) #RMSE
    mae = mean_absolute_error(y_true, y_pred) #MAE
    r2 = r2_score(y_true, y_pred) #R-squared
    return mse, rmse, mae, r2

#polynomiální regrese
def polynomialni_regrese(X_test, Y_test, degrees):
    if isinstance(degrees, int):
        degrees = range(1, degrees + 1)
    #vytvoření seznamu pro ukládání kritérií
    criteria = {'degree': [], 'mse': [], 'rmse': [], 'mae': [], 'r2': []}
    for degree in degrees:
        #výpočet polynomiálního regresního modelu pro stupně
        poly = PolynomialFeatures(degree)
        X_poly_test = poly.fit_transform(X_test)
        #výpočet lineárního regresního modelu pro stupně z pol.
        model = LinearRegression().fit(X_poly_test, Y_test)
        Y_pred = model.predict(X_poly_test) #vytvoření predikce
        #vrácení kalkulací kritérií
        mse, rmse, mae, r2 = calculate_quality_criteria(Y_test, Y_pred)
        #přidání vypočítaných kritérií do slovníku
        criteria['degree'].append(degree)
        criteria['mse'].append(mse)
        criteria['rmse'].append(rmse)
        criteria['mae'].append(mae)
        criteria['r2'].append(r2)
    return criteria

# vykreslení kvality kritérií
def vykresli_kvality_kriterii(criteria_simplreg, criteria_fruitohms):
    plt.figure(figsize=(15, 10))
    #pro simlreg data
    plt.subplot(2, 2, 1)
    plt.plot(criteria_simplreg['degree'], criteria_simplreg['mse'], label='MSE') #mse
    plt.plot(criteria_simplreg['degree'], criteria_simplreg['rmse'], label='RMSE') #rmse
    plt.plot(criteria_simplreg['degree'], criteria_simplreg['mae'], label='MAE') #mae
    plt.plot(criteria_simplreg['degree'], criteria_simplreg['r2'], label='R-squared') #r-squared
    plt.title('Quality Criteria for simplreg'); plt.xlabel('Degree'); plt.ylabel('Criteria'); plt.legend()
    #pro fruitohms data
    plt.subplot(2, 2, 2)
    plt.plot(criteria_fruitohms['degree'], criteria_fruitohms['mse'], label='MSE')
    plt.plot(criteria_fruitohms['degree'], criteria_fruitohms['rmse'], label='RMSE')
    plt.plot(criteria_fruitohms['degree'], criteria_fruitohms['mae'], label='MAE')
    plt.plot(criteria_fruitohms['degree'], criteria_fruitohms['r2'], label='R-squared')
    plt.title('Quality Criteria for fruitohms');plt.xlabel('Degree'); plt.ylabel('Criteria'); plt.legend()
    #uložení a zobrazení
    plt.savefig('quality_criteria.png'); plt.close()

def vizualizace_regresniho_modelu(X_simplreg, Y_simplreg, Y_pred_simplreg, X_fruitohms,Y_fruitohms,Y_pred_fruitohms):
    plt.figure(figsize=(10, 5))
    #simplreg data
    plt.subplot(1, 2, 1)
    plt.scatter(X_simplreg, Y_simplreg)
    plt.plot(X_simplreg, Y_pred_simplreg, color='red')
    plt.title('Y=F(X) with Regression Line'); plt.xlabel('X'); plt.ylabel('Y')
    #fruitohms data
    plt.subplot(1, 2, 2)
    plt.scatter(X_fruitohms, Y_fruitohms)
    plt.plot(X_fruitohms, Y_pred_fruitohms, color='green')
    plt.title('juice = F(ohms) with Regression Line'); plt.xlabel('ohms'); plt.ylabel('juice')

    plt.savefig('regression_results.png'); plt.close()

# 1 nacteni a visualizace dat
simplreg_data = load_data_1('simplreg.txt')
fruitohms_data = load_data_2('fruitohms.txt')
print(simplreg_data.info(), simplreg_data.describe()) #podíváme se jak vypadají data
print(fruitohms_data.info(),fruitohms_data.describe())

# Vezmem x a y data
X1, Y1 = simplreg_data[0].values.reshape(-1,1), simplreg_data[1].values #Y=F(x)
X2, juice = fruitohms_data[0].values.reshape(-1,1), fruitohms_data[1].values

#vykreslení bodového grafu u obou dat
vykresli_bodovy_graf(X1,Y1,X2,juice)

#2 polynomialni regeese - vykreslení grafu kvality kritérií
# dosazení a vyhodnocení k lineárnímu modelu pro simpreg.txt
kriteria_dat_simplreg = polynomialni_regrese(X1,Y1,degrees=11)
# dosazení a vyhodnocení k lineárímu modelu pro fruitohms.txt
kriteria_dat_fruitohms = polynomialni_regrese(X2,juice,degrees=11)

#vykreslení kvality kritérií
vykresli_kvality_kriterii(kriteria_dat_simplreg,kriteria_dat_fruitohms)

#vizualizace s regresními přímkami s jednoduchým lineárním modelem a polynomiálním regresním modelem
best_degree_simplreg = kriteria_dat_simplreg['degree'][np.argmax(kriteria_dat_simplreg['r2'])]
best_degree_fruitohms = kriteria_dat_fruitohms['degree'][np.argmax(kriteria_dat_fruitohms['r2'])]

#vytvoření polynomiálních regresních modelů k simplreg X
poly_simplreg = PolynomialFeatures(best_degree_simplreg)
X_poly_simplreg = poly_simplreg.fit_transform(X1) #převedení dat na polynomiální regresní model
#vytvoření lineárního regresního modelu k simlreg Y
model_simplreg = LinearRegression().fit(X_poly_simplreg, Y1)
Y_pred_simplreg = model_simplreg.predict(X_poly_simplreg) #predikce

poly_fruitohms = PolynomialFeatures(best_degree_fruitohms)
X_poly_fruitohms = poly_fruitohms.fit_transform(X2)

model_fruitohms = LinearRegression().fit(X_poly_fruitohms, juice)
Y_pred_fruitohms = model_fruitohms.predict(X_poly_fruitohms)

#visualizace regresního modelu
vizualizace_regresniho_modelu(X1, Y1, Y_pred_simplreg, X2, juice, Y_pred_fruitohms)