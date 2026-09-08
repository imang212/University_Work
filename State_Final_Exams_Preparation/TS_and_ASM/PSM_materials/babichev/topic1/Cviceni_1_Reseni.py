"""
Cvičení 1: Lineární a polynomiální regrese
Cíl: Porovnat lineární regresi s polynomiální regresí (stupně 2–7) na syntetických datech, vyhodnotit kvalitu modelů a výsledky přehledně vizualizovat.
"""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import PolynomialFeatures
from sklearn.pipeline import Pipeline
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
import statsmodels.api as sm

# načtení datasetu
file_path = "Synthetic_dataset.csv"  
df = pd.read_csv(file_path)
print(df.head(10))
print(df.info())
print(df.describe())

# Identifikace vstupní a cílové proměnné
col_names = df.columns.tolist()
print("Sloupce:", col_names)
X_col = col_names[0]  # vstupní proměnná
Y_col = col_names[1]  # cílová proměnná
print(f"Vstupní proměnná X: {X_col}")
print(f"Cílová proměnná Y: {Y_col}")

X = df[X_col].values.reshape(-1, 1)
y = df[Y_col].values

# Scatterplot Y = f(X)
plt.figure(figsize=(8, 6))
sns.scatterplot(x=df[X_col], y=df[Y_col], label="Data")
plt.xlabel(X_col, fontsize=14)
plt.ylabel(Y_col, fontsize=14)
plt.title(f"Scatterplot: {Y_col} = f({X_col})", fontsize=16, fontweight='bold')
plt.xticks(fontsize=12)
plt.yticks(fontsize=12)
plt.grid(True, linestyle='--', alpha=0.5)
plt.legend(fontsize=12)
plt.tight_layout()
plt.savefig("scatterplot.png", dpi=150)
plt.show()
print("Graf uložen jako scatterplot.png")

# Trénování regresních modelů
degrees = [1, 2, 3, 4, 5, 6, 7] # lineární i polynomiální modely
models = {}
predictions = {}
for d in degrees:
    pipeline = Pipeline([("poly", PolynomialFeatures(degree=d, include_bias=False)), ("lr",   LinearRegression())])
    pipeline.fit(X, y)
    y_pred = pipeline.predict(X)
    models[d] = pipeline
    predictions[d] = y_pred
    label = "Lineární regrese" if d == 1 else f"Polynomiální regrese (stupeň {d})"
    print(f"Natrénován model: {label}")

# Výpočet metrik kvality
results = []
for d in degrees:
    y_pred = predictions[d]
    mse  = mean_squared_error(y, y_pred)
    rmse = np.sqrt(mse)
    mae  = mean_absolute_error(y, y_pred)
    r2   = r2_score(y, y_pred)
    label = "Lineární (d=1)" if d == 1 else f"Polynomiální (d={d})"
    results.append({"Model": label, "Stupeň (d)": d, "MSE": mse, "RMSE": rmse, "MAE": mae, "R²": r2})

results_df = pd.DataFrame(results)
print(results_df.to_string(index=False))

# Určení nejlepšího polynomiálního stupně (min RMSE mezi d=2..7)
poly_df = results_df[results_df["Stupeň (d)"] >= 2]
best_idx = poly_df["RMSE"].idxmin()
best_degree = poly_df.loc[best_idx, "Stupeň (d)"]
print(f"\nNejlepší polynomiální stupeň (dle min RMSE): d = {best_degree}")

# Společný graf – scatterplot + všechny regresní křivky
X_line = np.linspace(X.min(), X.max(), 300).reshape(-1, 1)
colors = {1: "black", 2: "blue", 3: "green", 4: "orange", 5: "red", 6: "purple", 7: "brown"}
plt.figure(figsize=(12, 7))
sns.scatterplot(x=df[X_col], y=df[Y_col], label="Data", color="gray", alpha=0.7, zorder=5)
for d in degrees:
    y_line = models[d].predict(X_line)
    lbl = "Lineární regrese (d=1)" if d == 1 else f"Polynomiální regrese (d={d})"
    lw  = 2.5 if d == 1 else 1.8
    ls  = "--" if d == 1 else "-"
    plt.plot(X_line, y_line, color=colors[d], label=lbl, linewidth=lw, linestyle=ls)

plt.xlabel(X_col, fontsize=14)
plt.ylabel(Y_col, fontsize=14)
plt.title("Porovnání lineární a polynomiálních regresí", fontsize=16, fontweight='bold')
plt.xticks(fontsize=12)
plt.yticks(fontsize=12)
plt.legend(fontsize=11, loc="best")
plt.grid(True, linestyle='--', alpha=0.5)
plt.tight_layout()
plt.savefig("regression_curves.png", dpi=150)
plt.show()
print("Graf uložen jako regression_curves.png")

# Závislosti metrik na stupni polynomu d ∈ {2,…,7}
poly_results = results_df[results_df["Stupeň (d)"] >= 2].copy()
poly_degrees = poly_results["Stupeň (d)"].values

best_d_rmse = poly_results.loc[poly_results["RMSE"].idxmin(), "Stupeň (d)"]
best_d_r2   = poly_results.loc[poly_results["R²"].idxmax(),  "Stupeň (d)"]

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("Závislosti metrik na stupni polynomu", fontsize=18, fontweight='bold')
metrics_info = [
    ("MSE",  "MSE = f(d)",  "MSE",  "tab:blue",   best_d_rmse, "min RMSE"),
    ("RMSE", "RMSE = f(d)", "RMSE", "tab:orange", best_d_rmse, "min RMSE"),
    ("MAE",  "MAE = f(d)",  "MAE",  "tab:green",  best_d_rmse, "min RMSE"),
    ("R²",   "R² = f(d)",   "R²",   "tab:red",    best_d_r2,   "max R²"),
]
for ax, (metric, title, ylabel, color, best_d, criterion) in zip(axes.flat, metrics_info):
    values = poly_results[metric].values
    ax.plot(poly_degrees, values, marker='o', color=color, linewidth=2, markersize=7)
    # Zvýraznění nejlepšího stupně
    best_val = poly_results.loc[poly_results["Stupeň (d)"] == best_d, metric].values[0]
    ax.axvline(x=best_d, color='black', linestyle=':', linewidth=1.5, label=f"Nejlepší d={best_d} ({criterion})")
    ax.scatter([best_d], [best_val], color='black', s=120, zorder=5)
    ax.annotate(f"d={best_d}", xy=(best_d, best_val), xytext=(best_d + 0.15, best_val), fontsize=11, color='black')
    ax.set_xlabel("Stupeň polynomu d", fontsize=12)
    ax.set_ylabel(ylabel, fontsize=12)
    ax.set_title(title, fontsize=13, fontweight='bold')
    ax.set_xticks(poly_degrees)
    ax.tick_params(labelsize=11)
    ax.grid(True, linestyle='--', alpha=0.5)
    ax.legend(fontsize=10)
plt.tight_layout()
plt.savefig("metrics_vs_degree.png", dpi=150)
plt.show()
print("Graf uložen jako metrics_vs_degree.png")

# Úkol 10: Interpretace výsledků
print(f"Nejlepší polynomiální stupeň dle min RMSE: d = {best_d_rmse}")
print(f"Nejlepší polynomiální stupeň dle max R²:   d = {best_d_r2}")

"""
Interpretace výsledků:
----------------------
- Lineární regrese (d=1) zachycuje pouze hrubý lineární trend v datech.
  Hodnoty MSE, RMSE a MAE jsou zpravidla vyšší a R² nižší.

- Polynomiální modely (d=2–4) postupně lépe přizpůsobují tvar křivky datům
  – metriky se zlepšují.

- Od určitého stupně (typicky d ≥ 5–6) nastává přetrénování (overfitting):
  model dosahuje nižší chyby na trénovacích datech, ale křivka začíná kmitat
  a přestává zobecňovat.

- Nejlepší stupeň d* je ten, při kterém je RMSE minimální (nebo R² maximální)
  a zároveň tvar křivky vizuálně odpovídá datům bez přílišných výkyvů.

Kritérium výběru: minimum RMSE (resp. maximum R²) doplněné vizuální kontrolou.
"""

def nonlinear_func(x, a, b):
    return a * (1 - np.exp(-b * x))

def compute_metrics(y_true, y_pred, model_name):
    mse  = mean_squared_error(y_true, y_pred)
    rmse = np.sqrt(mse)
    mae  = mean_absolute_error(y_true, y_pred)
    r2   = r2_score(y_true, y_pred)
    return {"Model": model_name, "MSE": mse, "RMSE": rmse, "MAE": mae, "R²": r2}

def best_poly_degree(X, y, degrees=range(2, 8)):
    best_d, best_rmse = None, np.inf
    for d in degrees:
        pipe = Pipeline([("poly", PolynomialFeatures(degree=d, include_bias=False)), ("lr",   LinearRegression())])
        pipe.fit(X, y)
        rmse = np.sqrt(mean_squared_error(y, pipe.predict(X)))
        if rmse < best_rmse:
            best_rmse, best_d = rmse, d
    return best_d

def plot_and_save(dataset_name, X, y, x_label, y_label, poly_pipe, poly_degree, nl_params, metrics_df):
    X_line = np.linspace(X.min(), X.max(), 300).reshape(-1, 1)
    y_poly = poly_pipe.predict(X_line)
    y_nl   = nonlinear_func(X_line.ravel(), *nl_params)
    plt.figure(figsize=(9, 6))
    sns.scatterplot(x=X.ravel(), y=y, label="Data", color="gray", alpha=0.8, zorder=5)
    plt.plot(X_line, y_poly, color="blue",   linewidth=2,
             label=f"Polynomiální regrese (d={poly_degree})")
    plt.plot(X_line, y_nl,   color="red",    linewidth=2,
             label=f"Nelineární regrese\na={nl_params[0]:.4f}, b={nl_params[1]:.4f}")
    plt.xlabel(x_label, fontsize=14)
    plt.ylabel(y_label, fontsize=14)
    plt.title(f"Regresní modely – dataset {dataset_name}", fontsize=16, fontweight='bold')
    plt.xticks(fontsize=12)
    plt.yticks(fontsize=12)
    plt.legend(fontsize=11)
    plt.grid(True, linestyle='--', alpha=0.5)
    plt.tight_layout()
    fname = f"{dataset_name}_regression.png"
    plt.savefig(fname, dpi=150)
    plt.show()
    print(f"Graf uložen jako {fname}")
    print(f"\nMetriky kvality modelů – {dataset_name}:")
    print(metrics_df.to_string(index=False))

# Dataset misrala
misrala = sm.datasets.get_rdataset("misrala", package="NISTnls").data
print(misrala.head(10))
print(misrala.info())

X_col_m = misrala.columns[0]
Y_col_m = misrala.columns[1]

X_m = misrala[X_col_m].values.reshape(-1, 1)
y_m = misrala[Y_col_m].values

# Scatterplot
plt.figure(figsize=(8, 6))
sns.scatterplot(x=misrala[X_col_m], y=misrala[Y_col_m], label="Data")
plt.xlabel(X_col_m, fontsize=14)
plt.ylabel(Y_col_m, fontsize=14)
plt.title("Scatterplot – misrala", fontsize=16, fontweight='bold')
plt.xticks(fontsize=12)
plt.yticks(fontsize=12)
plt.grid(True, linestyle='--', alpha=0.5)
plt.legend(fontsize=12)
plt.tight_layout()
plt.savefig("misrala_scatterplot.png", dpi=150)
plt.show()
print("Graf uložen jako misrala_scatterplot.png")

# Polynomiální model
best_d_m = best_poly_degree(X_m, y_m)
poly_pipe_m = Pipeline([
    ("poly", PolynomialFeatures(degree=best_d_m, include_bias=False)),
    ("lr",   LinearRegression())
])
poly_pipe_m.fit(X_m, y_m)
y_pred_poly_m = poly_pipe_m.predict(X_m)

# Nelineární model – fitování curve_fit
p0 = [y_m.max(), 0.01]  # počáteční odhad parametrů
params_m, _ = curve_fit(nonlinear_func, X_m.ravel(), y_m, p0=p0, maxfev=10000)
y_pred_nl_m = nonlinear_func(X_m.ravel(), *params_m)
print(f"Nelineární model (misrala): a = {params_m[0]:.4f}, b = {params_m[1]:.4f}")

# Metriky
metrics_m = pd.DataFrame([
    compute_metrics(y_m, y_pred_poly_m, f"Polynomiální (d={best_d_m})"),
    compute_metrics(y_m, y_pred_nl_m,   "Nelineární: a(1−e^(−bx))"),
])

# Vizualizace + uložení
plot_and_save("misrala", X_m, y_m, X_col_m, Y_col_m, poly_pipe_m, best_d_m, params_m, metrics_m)

# Dataset BoxBOD
boxbod = sm.datasets.get_rdataset("BoxBOD", package="datasets").data
print(boxbod.head(10))
print(boxbod.info())

X_col_b = boxbod.columns[0]
Y_col_b = boxbod.columns[1]

X_b = boxbod[X_col_b].values.reshape(-1, 1)
y_b = boxbod[Y_col_b].values

# Scatterplot
plt.figure(figsize=(8, 6))
sns.scatterplot(x=boxbod[X_col_b], y=boxbod[Y_col_b], label="Data")
plt.xlabel(X_col_b, fontsize=14)
plt.ylabel(Y_col_b, fontsize=14)
plt.title("Scatterplot – BoxBOD", fontsize=16, fontweight='bold')
plt.xticks(fontsize=12)
plt.yticks(fontsize=12)
plt.grid(True, linestyle='--', alpha=0.5)
plt.legend(fontsize=12)
plt.tight_layout()
plt.savefig("boxbod_scatterplot.png", dpi=150)
plt.show()
print("Graf uložen jako boxbod_scatterplot.png")

# Polynomiální model
best_d_b = best_poly_degree(X_b, y_b, degrees=range(1, 5))  # méně bodů → nižší stupně
poly_pipe_b = Pipeline([
    ("poly", PolynomialFeatures(degree=best_d_b, include_bias=False)),
    ("lr",   LinearRegression())
])
poly_pipe_b.fit(X_b, y_b)
y_pred_poly_b = poly_pipe_b.predict(X_b)

# Nelineární model
p0 = [y_b.max(), 0.1]
params_b, _ = curve_fit(nonlinear_func, X_b.ravel(), y_b, p0=p0, maxfev=10000)
y_pred_nl_b = nonlinear_func(X_b.ravel(), *params_b)
print(f"Nelineární model (BoxBOD): a = {params_b[0]:.4f}, b = {params_b[1]:.4f}")

# Metriky
metrics_b = pd.DataFrame([
    compute_metrics(y_b, y_pred_poly_b, f"Polynomiální (d={best_d_b})"),
    compute_metrics(y_b, y_pred_nl_b,   "Nelineární: a(1−e^(−bx))"),
])

# Vizualizace + uložení
plot_and_save("BoxBOD", X_b, y_b, X_col_b, Y_col_b,
              poly_pipe_b, best_d_b, params_b, metrics_b)


# =============================================================================
# Porovnání modelů – shrnutí
# =============================================================================

print("\n" + "=" * 60)
print("SHRNUTÍ POROVNÁNÍ MODELŮ")
print("=" * 60)

print("\nmisrala:")
print(metrics_m.to_string(index=False))

print("\nBoxBOD:")
print(metrics_b.to_string(index=False))

