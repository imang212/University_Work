# ================================
# TASK 1: LOESS vs Polynomial Regression
# ================================

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import PolynomialFeatures
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, r2_score

from statsmodels.nonparametric.smoothers_lowess import lowess

# -------------------------
# 1 Load dataset
# -------------------------
df = pd.read_csv("Synthetic dataset 1.csv")

print(df.head())

X = df[['X']]      # predictor (change if dataset has another name)
y = df['Y']        # target

# -------------------------
# 2 Train/Test split (70/30)
# -------------------------
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.3, random_state=42
)

# -------------------------
# 3 LOESS model (LOWESS)
# -------------------------
loess_result = lowess(
    y_train,
    X_train.values.flatten(),
    frac=0.3
)

loess_x = loess_result[:, 0]
loess_y = loess_result[:, 1]

# Prediction via interpolation
y_pred_loess = np.interp(
    X_test.values.flatten(),
    loess_x,
    loess_y
)

rmse_loess = np.sqrt(mean_squared_error(y_test, y_pred_loess))
r2_loess = r2_score(y_test, y_pred_loess)

print("LOESS RMSE:", rmse_loess)
print("LOESS R2:", r2_loess)

# -------------------------
# 4 Polynomial regression
# -------------------------
best_rmse = np.inf
best_degree = None
best_model = None
best_poly = None

for degree in range(1, 10):

    poly = PolynomialFeatures(degree=degree)
    X_train_poly = poly.fit_transform(X_train)

    model = LinearRegression()
    model.fit(X_train_poly, y_train)

    X_test_poly = poly.transform(X_test)
    y_pred = model.predict(X_test_poly)

    rmse = np.sqrt(mean_squared_error(y_test, y_pred))

    if rmse < best_rmse:
        best_rmse = rmse
        best_degree = degree
        best_model = model
        best_poly = poly

print("Best polynomial degree:", best_degree)

y_pred_poly = best_model.predict(best_poly.transform(X_test))
r2_poly = r2_score(y_test, y_pred_poly)

print("Polynomial RMSE:", best_rmse)
print("Polynomial R2:", r2_poly)

# -------------------------
# 5 Visualization
# -------------------------
plt.scatter(X_test, y_test, label="True values")

plt.scatter(X_test, y_pred_loess,
            color='red', label="LOESS predictions")

plt.scatter(X_test, y_pred_poly,
            color='green', label="Polynomial predictions")

plt.legend()
plt.xlabel("X")
plt.ylabel("Y")
plt.title("Model comparison")
plt.show()

# ================================
# TASK 2: Multiple Linear Regression
# ================================

import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error
import statsmodels.api as sm

# -------------------------
# 1 Load dataset
# -------------------------
df = pd.read_csv("House price.csv")

print(df.head())

# Target variable (example)
target = "Price"

# -------------------------
# EDA
# -------------------------
print("\nMissing values:")
print(df.isnull().sum())

# -------------------------
# 2 Correlation matrix
# -------------------------
corr_matrix = df.corr()

plt.figure(figsize=(10,8))
sns.heatmap(corr_matrix, annot=True, cmap="coolwarm")
plt.title("Correlation matrix")
plt.show()

# predictors
X = df.drop(columns=[target])
y = df[target]

# -------------------------
# 3 Train/Test split
# -------------------------
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.3, random_state=42
)

# -------------------------
# 4 Fit regression model
# -------------------------
X_train_sm = sm.add_constant(X_train)

model = sm.OLS(y_train, X_train_sm).fit()

print(model.summary())

# -------------------------
# 5 Predictions
# -------------------------
X_test_sm = sm.add_constant(X_test)
y_pred = model.predict(X_test_sm)

rmse = np.sqrt(mean_squared_error(y_test, y_pred))

print("Test RMSE:", rmse)

# -------------------------
# Visualization
# -------------------------
plt.scatter(y_test, y_pred)
plt.xlabel("True price")
plt.ylabel("Predicted price")
plt.title("Prediction vs Reality")
plt.show()
