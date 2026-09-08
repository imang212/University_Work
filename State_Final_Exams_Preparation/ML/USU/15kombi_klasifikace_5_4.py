from sklearn.datasets import load_wine
data = load_wine()
X, y = load_wine(return_X_y=True)

import pandas as pd
pd.DataFrame(X).describe()

"""Rozdělím na trénovací a testovací soubor"""
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

print(X_train)

"""Naškáluji - pomocí standard scaler, případně dalších."""
from sklearn.preprocessing import StandardScaler, MinMaxScaler, RobustScaler
scaler = MinMaxScaler((-1,1)) #
X_train_sc = scaler.fit_transform(X_train)
X_test_sc = scaler.transform(X_test)
print(X_train_sc)

"""# Použití defaultních klasifikátorů"""
from sklearn.neighbors import KNeighborsClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix, ConfusionMatrixDisplay

models = [RandomForestClassifier(n_estimators=10), SVC(), LogisticRegression(), KNeighborsClassifier() ]
for model in models:
    model.fit(X_train_sc, y_train)
    y_pred = model.predict(X_test_sc)
    print(model)
    print(classification_report(y_test, y_pred))