import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit
from sklearn.preprocessing import PolynomialFeatures
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, r2_score

# Načtení dat
def load_data(filename): return pd.read_csv(filename, sep='\s+', header=0)

#nelineární regresní expoenciální funkce
def non_linear_func(x, a, b): return a * (1 - np.exp(-b * x))

#polynomiální regrese
def polynomial_regression(X, y, max_degree=5):
    mse_list, rmse_list, r2_list = [], [], []
    for degree in range(1, max_degree + 1):
        # vyytvoření polynomiálních vlastností
        poly_features = PolynomialFeatures(degree=degree)
        X_poly = poly_features.fit_transform(X.reshape(-1, 1))
        # vytvoření lineárního regresního modelu
        model = LinearRegression()
        model.fit(X_poly, y)
        # predikce a výpočtet měření
        y_pred = model.predict(X_poly)
        #spočítání kritérií MSE, RMSE, r2
        mse = mean_squared_error(y, y_pred)
        rmse = np.sqrt(mse)
        r2 = r2_score(y, y_pred)
        #přidání kritérií do listu
        mse_list.append(mse)
        rmse_list.append(rmse)
        r2_list.append(r2)
    return { 'mse': mse_list, 'rmse': rmse_list, 'r2': r2_list}

# vykreslení vizualizace dat pro X a y
def create_scatter_plot(X, y, x_label, y_label, title, filename):
    plt.figure(figsize=(10, 6))
    plt.scatter(X, y, label='Original Data')
    plt.xlabel(x_label); plt.ylabel(y_label); plt.title(title)
    plt.legend(); plt.tight_layout(); plt.savefig(filename); plt.close()

def plot_regression_comparison(X, y, poly_degree, filename):
    plt.figure(figsize=(12, 6))
    # originální data
    plt.scatter(X, y, label='Original Data', color='blue')
    # polynomiální regrese
    poly_features = PolynomialFeatures(degree=poly_degree)
    X_poly = poly_features.fit_transform(X.reshape(-1, 1))
    poly_model = LinearRegression()
    poly_model.fit(X_poly, y)
    # seřazení X dat
    X_sorted = np.sort(X)
    X_poly_sorted = poly_features.transform(X_sorted.reshape(-1, 1))
    y_poly_pred = poly_model.predict(X_poly_sorted)
    # Nelineární exponenciální regrese
    popt, _ = curve_fit(non_linear_func, X, y) # optimalizace parametrů
    y_nonlinear_pred = non_linear_func(X_sorted, *popt) # predikce na ose y
    # Plot vykreslení regresních přímek
    plt.plot(X_sorted, y_poly_pred, color='red', label=f'Polynomial (Degree {poly_degree}) Regression')
    plt.plot(X_sorted, y_nonlinear_pred, color='green', label='Non-linear Exponential Regression')
    plt.xlabel('X'); plt.ylabel('Y'); plt.title('Regression Models Comparison')
    plt.legend(); plt.tight_layout(); plt.savefig(filename); plt.close()

# vykreslení vizualizace měření
def plot_metrics(metrics, filename):
    plt.figure(figsize=(15, 5))
    # vykreslení MSE
    plt.subplot(1, 3, 1)
    plt.plot(range(1, len(metrics['mse']) + 1), metrics['mse'], marker='o')
    plt.title('MSE vs Polynomial Degree'); plt.xlabel('Polynomial Degree'); plt.ylabel('Mean Squared Error')
    # vykreslení RMSE
    plt.subplot(1, 3, 2)
    plt.plot(range(1, len(metrics['rmse']) + 1), metrics['rmse'], marker='o')
    plt.title('RMSE vs Polynomial Degree'); plt.xlabel('Polynomial Degree'); plt.ylabel('Root Mean Squared Error')
    # vykreslení R-squared
    plt.subplot(1, 3, 3)
    plt.plot(range(1, len(metrics['r2']) + 1), metrics['r2'], marker='o')
    plt.title('R-squared vs Polynomial Degree'); plt.xlabel('Polynomial Degree'); plt.ylabel('R-squared')

    plt.tight_layout(); plt.savefig(filename); plt.close()

# načtení dat
misrala_data = load_data('misrala.txt')
boxbod_data = load_data('BoxBOD.txt')
print(misrala_data.info(), misrala_data.describe())
print(boxbod_data.info(), boxbod_data.describe())

X_misrala, Y_misrala = misrala_data['x'].values, misrala_data['y'].values

#vykreslení scatter plotu
create_scatter_plot(X_misrala,Y_misrala,'X','Y','Misrala Dara','misrala_data.png')
# polynomiálí regrese pro misrala data
misrala_poly_metrics = polynomial_regression(X_misrala,Y_misrala)
# vykreslení měření podle polynomiálního stupně
plot_metrics(misrala_poly_metrics,'misrala_metrics.png')
# nalezení nejlepšího stupně polynomiální regrese
best_misrala_poly_degree = np.argmax(misrala_poly_metrics['r2']) + 1
# non-linear exponential regrese
popt_misrala, _ = curve_fit(non_linear_func, X_misrala, Y_misrala)
y_nonlinear_misrala = non_linear_func(X_misrala, *popt_misrala) # predikce
# výpočet měření pro nelineární model
mse_nonlinear_misrala = mean_squared_error(Y_misrala, y_nonlinear_misrala)
r2_nonlinear_misrala = r2_score(Y_misrala, y_nonlinear_misrala)
# vykreslení vizualizace regresních modelů
plot_regression_comparison(X_misrala, Y_misrala, best_misrala_poly_degree, 'misrala_regression_comparison.png')
#vypsání informací
print("Misrala Dataset Analysis:\n", f"Best Polynomial Degree: {best_misrala_poly_degree}\n", f"Best Polynomial R-squared: {max(misrala_poly_metrics['r2']):.4f}\n",
      f"Non-linear Model MSE: {mse_nonlinear_misrala:.4f}\n",f"Non-linear Model R-squared: {r2_nonlinear_misrala:.4f}")

X_boxbod, Y_boxbod = boxbod_data['x1'].values, boxbod_data['y1'].values
create_scatter_plot(X_boxbod,Y_boxbod,'X','Y','Misrala Dara','boxbod_data.png')
boxbod_poly_metrics = polynomial_regression(X_boxbod,Y_boxbod)
plot_metrics(boxbod_poly_metrics,'boxbod_metrics.png')
best_boxbod_poly_degree = np.argmax(boxbod_poly_metrics['r2']) + 1

popt_boxbod, _ = curve_fit(non_linear_func, X_boxbod, Y_boxbod)
y_nonlinear_boxbod = non_linear_func(X_boxbod, *popt_boxbod)

mse_nonlinear_boxbod = mean_squared_error(Y_boxbod, y_nonlinear_boxbod)
r2_nonlinear_boxbod = r2_score(Y_boxbod, y_nonlinear_boxbod)

plot_regression_comparison(X_boxbod, Y_boxbod, best_boxbod_poly_degree, 'boxbod_regression_comparison.png')

print("Misrala Dataset Analysis:\n", f"Best Polynomial Degree: {best_boxbod_poly_degree}\n", f"Best Polynomial R-squared: {max(boxbod_poly_metrics['r2']):.4f}\n",
      f"Non-linear Model MSE: {mse_nonlinear_boxbod:.4f}\n",f"Non-linear Model R-squared: {r2_nonlinear_boxbod:.4f}")
