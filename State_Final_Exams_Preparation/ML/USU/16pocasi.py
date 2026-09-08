import pandas as pd
import numpy as np

df = pd.read_csv('Data/kopisty_pocasi_rozsireno.csv', decimal=",", delimiter=";", parse_dates=True)
df['datum'] = pd.to_datetime(df['datum'], format='%d.%m.%Y')
df.dropna(); df.head()
df.drop(columns="vypar", inplace=True)
df.head()

import seaborn as sns
import matplotlib.pyplot as plt
corr = df.corr()
sns.heatmap(corr, annot=True, cmap='coolwarm', fmt=".2f", linewidths=0.5)
# Zobrazení grafu
plt.show()
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

from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, RobustScaler
from sklearn.metrics import classification_report
from sklearn.svm import LinearSVC
from sklearn.ensemble import StackingClassifier

X,y = transform(data, 3)
scaler = RobustScaler() #StandardScaler()
X = scaler.fit_transform(X)
X_train, X_test, y_train, y_test = train_test_split( X, y, test_size=0.2, random_state=42)

#estimators = [('rf', RandomForestClassifier(n_estimators=5, random_state=42)),
#    ('svr', LinearSVC(random_state=42)),
#   ('lr', LogisticRegression())]

#classifier = StackingClassifier(estimators=estimators, final_estimator=LogisticRegression())

classifier =  RandomForestClassifier(random_state=42)
classifier.fit(X_train, y_train)
y_hat_train = classifier.predict(X_train)
print(classification_report(y_train, y_hat_train))
y_hat_test = classifier.predict(X_test)
print(classification_report(y_test, y_hat_test))

y_rolled = np.array(y_test)
y_rolled=np.roll(y_rolled, +1)

print(np.sum(y_rolled==y_test)/len(y_hat_test))

"""Pokus najít nejlepší pomocí grid search a vah tříd"""
from os import pipe
from sklearn.model_selection import GridSearchCV
from sklearn.utils.class_weight import compute_class_weight
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import PolynomialFeatures
# určím váhy tříd - reálně to moc nepomohlo
class_weights = compute_class_weight(class_weight='balanced', classes=np.unique(y_train), y=y_train)
class_weights = dict(zip(np.unique(y_train), class_weights))
print(f"Váhy tříd: {class_weights}")
# ==================================================
pipe=Pipeline([("datatr", PolynomialFeatures()),('logr', LogisticRegression(max_iter=1000))])

parameters = {
    'logr__penalty':('l2', None),
    'logr__C':[0.01, 0.1, 1, 10],
    "datatr__degree":[1,2,3],
    "logr__class_weight":[class_weights, None]
    }

search = GridSearchCV(pipe, parameters, n_jobs=2)
search.fit(X_train, y_train)
print(search.best_params_)
search.best_estimator_.fit(X_train, y_train)

y_hat_train = search.best_estimator_.predict(X_train)
print(classification_report(y_train, y_hat_train))

y_hat_test = search.best_estimator_.predict(X_test)
print(classification_report(y_test, y_hat_test))