import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.preprocessing import PolynomialFeatures
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, r2_score
import seaborn as sns

# naštení dat z datasetu
def load_data(filename): return pd.read_csv(filename)

#polynomiální regrese
def polynomial_regression(X, y, max_degree=9):
    mse_list, rmse_list, r2_list = [], [], [] #vytvoření listů pro ukládání kritérií
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
    return { 'mse': mse_list, 'rmse': rmse_list, 'r2': r2_list }

# vykreslení vizualizace vztahů
def plot_relationships(df, filename):
    plt.figure(figsize=(15, 10))
    # vybrání číselných vlastností
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    # vytvoření korelační mapy
    plt.subplot(2, 1, 1)
    correlation_matrix = df[numeric_cols].corr()
    sns.heatmap(correlation_matrix, annot=True, cmap='coolwarm', center=0)
    plt.title('Korelační mapa')
    # vytvoření párového grafu
    plt.subplot(2, 1, 2)
    sns.pairplot(df[numeric_cols], diag_kind='kde')
    plt.tight_layout(); plt.savefig(filename); plt.close()

# vykreslení vizualizace měření
def plot_metrics(metrics, title, filename):
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

    plt.suptitle(title); plt.tight_layout(); plt.savefig(filename); plt.close()

# vykreslení vizualizace regrese
def plot_regression(X, y, best_degree, feature_name, target_name, filename):
    plt.figure(figsize=(10, 6))
    # Rozptylový graf původních dat
    plt.scatter(X, y, label='Original Data', alpha=0.7)
    # polynomiální regresní přímky pro různé stupně
    degrees_to_plot = [1, best_degree]
    colors = ['red', 'green']
    for degree, color in zip(degrees_to_plot, colors):
        # Polynomiální vlastnosti
        poly_features = PolynomialFeatures(degree=degree)
        X_poly = poly_features.fit_transform(X.reshape(-1, 1))
        # Vytvoření modelu
        model = LinearRegression()
        model.fit(X_poly, y)
        # Predikce
        X_sorted = np.sort(X)
        X_poly_sorted = poly_features.transform(X_sorted.reshape(-1, 1))
        y_pred_sorted = model.predict(X_poly_sorted)
        plt.plot(X_sorted, y_pred_sorted, color=color, label=f'Degree {degree} Regression')

    plt.xlabel(feature_name); plt.ylabel(target_name); plt.title(f'{feature_name} vs {target_name} Regression')
    plt.legend(); plt.tight_layout(); plt.savefig(filename); plt.close()


# Načtení dat z datasetu
dataset = load_data('manufacturing.csv')
# vizualizace vztahů v datasetu
plot_relationships(dataset, 'manufacturing_relationships.png')
# definování seznamu vlastností datasetu
features = ['Temperature (°C)','Pressure (kPa)','Temperature x Pressure','Material Fusion Metric','Material Transformation Metric']
#určení cíloové vlastnosti
target = ['Quality Rating']

# vykreslení polynomiální regrese pro každou vlastnost
for feature in features:
    #vezmu data
    X = dataset[feature].values
    y = dataset[target].values
    metrics = polynomial_regression(X, y) #vytvoření regresních měření
    # vykreslení měření pomocí optimalizace s použitím regresních metrik k dané vlastnosti
    plot_metrics(metrics, f'{feature} vs {target}', f'{feature}_metrics.png')
    # nalezení nejlepšího stupně dané vlastnosti
    best_degree = np.argmax(metrics['r2']) + 1
    # vizualizace regrese k dané vlastnosti
    plot_regression(X, y, best_degree, feature, target, f'{feature}_regression.png')
    # výpis výsledků
    print(f"{feature} - Nejlepší polynomiální stupeň: {best_degree}")
    print(f"Max R-squared: {max(metrics['r2']):.4f}\n")