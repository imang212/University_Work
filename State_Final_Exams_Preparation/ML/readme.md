**Úvod do strojového učení**

**1. Čištění dat a Analýza (Exploratory Data Analysis)** - připravit dataset, vyřešit chybějící hodnoty a analyzovat důležitost příznaků (Feature Importance).
```python
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
import matplotlib.pyplot as plt
# 1. Načtení dat (Auto MPG dataset)
url = "https://archive.ics.uci.edu/ml/machine-learning-databases/auto-mpg/auto-mpg.data"
column_names = ['mpg', 'cylinders', 'displacement', 'horsepower', 'weight', 
                'acceleration', 'model_year', 'origin', 'car_name']
df = pd.read_csv(url, names=column_names, delim_whitespace=True, na_values='?')
# 2. Čištění dat: Řešení chybějících atributů
# V tomto datasetu typicky chybí některé hodnoty 'horsepower' (označené jako '?').
# Nahradíme je mediánem, abychom nepřišli o zbytek řádku.
df['horsepower'] = df['horsepower'].fillna(df['horsepower'].median())
# Zahození textového sloupce, který pro regresi nepotřebujeme
df = df.drop(columns=['car_name'])
# 3. Příprava dat pro modely
X = df.drop(columns=['mpg'])
y = df['mpg']
# 4. Analýza důležitosti příznaků (Feature Importance) pomocí Random Forests
rf_explainer = RandomForestRegressor(random_state=42)
rf_explainer.fit(X, y)
# Vykreslení důležitosti
plt.barh(X.columns, rf_explainer.feature_importances_)
plt.title("Důležitost příznaků pro predikci MPG")
plt.show()
```
- Pokud by graf ukázal, že některé parametry (např. akcelerace) nemají na spotřebu vliv, mohl bys argumentovat, že jsi pomocí PCA mohl tyto méně důležité příznaky zredukovat, čímž bys snížil výpočetní náročnost bez velké ztráty přesnosti.

**Práce s kategorickými daty a PCA**
```python
from sklearn.decomposition import PCA
import pandas as pd
# Kategorická data: Převod textu (např. 'Evropa', 'USA') na čísla, kterým model rozumí.
# Používá se tzv. One-Hot Encoding (v Pandas přes get_dummies).
df = pd.get_dummies(df, columns=['origin'])
# PCA (Redukce dimenzionality): Zmenšíme počet sloupců (příznaků) např. ze 20 na 3 nejdůležitější, čímž zrychlíme trénink modelu a odstraníme šum.
pca = PCA(n_components=3)
X_zredukovane = pca.fit_transform(X)
```

**2. Klasické modely (scikit-learn) a Hyperparametry**
```python
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.svm import SVR
from sklearn.model_selection import GridSearchCV
from sklearn.metrics import mean_squared_error, mean_absolute_error
# Rozdělení na trénovací a testovací sadu (Train-test split)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
# Vytvoření Pipeliny: Nejdřív normalizace dat (StandardScaler), pak samotný model (SVR)
# Normalizace/standardizace je nutností pro modely jako SVM nebo neuronové sítě.
pipeline_svr = Pipeline([('scaler', StandardScaler()), ('svr', ())])

# Hledání optimálních hyperparametrů (Grid Search)
# U SVM ovlivňují parametry C (regularizace) a kernel (jádrová transformace) přesnost
param_grid = {
    'svr__kernel': ['linear', 'rbf'],
    'svr__C': [0.1, 1, 10],
    'svr__gamma': ['scale', 'auto']
}
grid_search = GridSearchCV(pipeline_svr, param_grid, cv=5, scoring='neg_mean_squared_error')
grid_search.fit(X_train, y_train)

best_svr = grid_search.best_estimator_
print(f"Nejlepší parametry SVR: {grid_search.best_params_}")
```
- Abych zabránil přetrénování (overfitting) na jednom konkrétním výseku dat, nepoužil jsem jen jeden train-test split, ale křížovou validaci. Parametr cv=5 rozdělil trénovací data na 5 částí, model se 5x natrénoval a výsledek se zprůměroval.

**3. Návrh neuronové sítě**
```python
import torch
import torch.nn as nn
import torch.optim as optim

# Převod standardizovaných dat do PyTorch tenzorů
scaler = StandardScaler()
X_train_scaled = torch.tensor(scaler.fit_transform(X_train), dtype=torch.float32)
X_test_scaled = torch.tensor(scaler.transform(X_test), dtype=torch.float32)
y_train_tensor = torch.tensor(y_train.values, dtype=torch.float32).view(-1, 1)

# Návrh MLP modelu s výběrem aktivačních funkcí (ReLU)
class SimpleMLP(nn.Module):
    def __init__(self, input_size):
        super(SimpleMLP, self).__init__()
        self.network = nn.Sequential(
            nn.Linear(input_size, 64),
            nn.ReLU(),
            nn.Linear(64, 32),
            nn.ReLU(),
            nn.Linear(32, 1) # Výstup pro regresi (jedno číslo MPG)
        )
    def forward(self, x):
        return self.network(x)

mlp_model = SimpleMLP(input_size=X_train.shape[1])
criterion = nn.MSELoss() # Metrika MSE pro optimalizaci regrese
optimizer = optim.Adam(mlp_model.parameters(), lr=0.01)

# Trénovací smyčka
epochs = 200
for epoch in range(epochs):
    mlp_model.train()
    optimizer.zero_grad()
    predictions = mlp_model(X_train_scaled)
    loss = criterion(predictions, y_train_tensor)
    loss.backward()
    optimizer.step()

# Vyhodnocení sítě
mlp_model.eval()
with torch.no_grad():
    mlp_preds = mlp_model(X_test_scaled).numpy()
```

**4. Porovnání a zhodnocení modelů** - Zadání vyžaduje zhodnocení dosažených výsledků za pomoci vhodných metrik a porovnání vytvořených modelů. U regresní úlohy, jako je predikce spotřeby mpg, komise očekává primárně metriky MSE (Mean Squared Error) nebo MAE (Mean Absolute Error)

```python
# Predikce ze SVR modelu
svr_preds = best_svr.predict(X_test)
# Výpočet metrik
svr_mse = mean_squared_error(y_test, svr_preds)
svr_mae = mean_absolute_error(y_test, svr_preds)
mlp_mse = mean_squared_error(y_test, mlp_preds)
mlp_mae = mean_absolute_error(y_test, mlp_preds)

print("Porovnání modelů")
print(f"SVR- MSE: {svr_mse:.2f}, MAE: {svr_mae:.2f}")
print(f"MLP (PyTorch)- MSE: {mlp_mse:.2f}, MAE: {mlp_mae:.2f}")
```
- Pokud má model MAE například $2.1$, znamená to, že se náš odhad spotřeby plete v průměru o $2.1$ míle na galon. Na základě těchto výsledků vidíme, že (např. SVR s RBF jádrem) překonal jednoduchou MLP síť. Důvodem může být to, že dataset Auto MPG je poměrně malý, a hluboké neuronové sítě vykazují nejlepší výsledky spíše na masivních objemech dat, zatímco SVR dokáže dobře generalizovat i na stovkách záznamů.

**Matice záměn a metriky hodnocení**
```python
from sklearn.metrics import confusion_matrix, classification_report
import seaborn as sns
import matplotlib.pyplot as plt
# Předpokládejme, že y_test jsou skutečné výsledky a y_pred jsou predikce našeho modelu
# y_test = [1, 0, 1, 1, 0, 0]
# y_pred = [1, 0, 1, 0, 0, 1]
# 1. Vypsání Matice záměn
cm = confusion_matrix(y_test, y_pred)
print("Matice záměn:")
print(cm)
# Vykreslení hezké barevné matice záměn pomocí Seaborn/Matplotlib
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues')
plt.title('Matice záměn (Confusion Matrix)')
plt.xlabel('Predikováno modelem')
plt.ylabel('Skutečnost')
plt.show()
# 2. Souhrnný report obsahující Accuracy, F1-skóre a další[cite: 1]
report = classification_report(y_test, y_pred)
print("\nKlasifikační report:")
print(report)
```
True Positive- Správně pozitivní., False Negative - Falešně negativní
False Positive - Falešně pozitivní (Pacient je zdravý, ale model vyhlásil poplach), True Negative - Správně negativní

**Z matice záměn se počítají všechny hlavní klasifikační metriky. Každá se hodí na něco jiného:**
- **Accuracy (Celková přesnost):** Kolik procent ze všech případů model uhodl správně. $Accuracy = \frac{TP + TN}{TP + TN + FP + FN}$, Kdy nepoužít: U nevyvážených dat (imbalanced datasets). Pokud máš 99 zdravých lidí a 1 nemocného, model, který slepě odpovídá "všichni jsou zdraví", bude mít 99% accuracy, ale je naprosto k ničemu.  
- **Senzitivita (Sensitivity / Recall):** Z těch, kteří byli doopravdy nemocní, kolik procent jich model dokázal odhalit?     $Sensitivity = \frac{TP}{TP + FN}$ Využití: Tam, kde nesmíme minout pozitivní případy (např. testy na nemoci, hledání teroristů).
- **Specificita (Specificity):** Z těch, kteří byli doopravdy zdraví, kolik jich model správně označil za zdravé?$Specificity = \frac{TN}{TN + FP}$ Využití: Když falešný poplach stojí hodně peněz nebo úsilí (např. automatické banování hráčů ve hře – nechceš omylem zabanovat poctivého hráče).
- **F1-skóre:** Harmonický průměr mezi Precizností (Precision) a Senzitivitou. $F1 = 2 \cdot \frac{Precision \cdot Sensitivity}{Precision + Sensitivity}$ Využití: Ideální metrika, pokud máš nevyváženou datovou sadu (mnohem více příkladů jedné třídy než druhé). Spojuje v sobě úspěšnost obou pohledů do jednoho čísla od 0 do 1.

Model ResNet50: pomocí svých konvolučních vrstev postupně extrahuje vizuální příznaky z obrazu (nejprve hrany, pak tvary a nakonec celé objekty). Komisi u tohoto bodu stačí vysvětlit, že konvoluce namísto klasického násobení vah používá filtry (matice), které "kloužou" po obrázku a hledají specifické vzory, což radikálně snižuje počet parametrů sítě oproti klasickému MLP.