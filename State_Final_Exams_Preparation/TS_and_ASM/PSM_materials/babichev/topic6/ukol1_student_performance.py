"""
Úkol 1 – Porovnání Bayesovského a klasického přístupu
Datová sada: Student_Performance.csv
Autor: praktická úloha z předmětu (UJEP)
Skript provádí:
  1. Načtení a průzkum dat
  2. Diskretizaci číselných proměnných (pro Bayesovskou síť / GeNIe)
  3. Klasický model – Random Forest
  4. Výpočet metrik (MSE, RMSE, Accuracy)
  5. Uložení diskretizovaných dat jako student_bn.csv pro import do GeNIe
"""
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import (mean_squared_error, accuracy_score, classification_report, confusion_matrix)
import warnings
warnings.filterwarnings("ignore")
# 1. NAČTENÍ DAT
print("ÚKOL 1 – Student Performance")
df = pd.read_csv("Student_Performance.csv", sep=";")
print(f"\nNačteno {df.shape[0]} záznamů, {df.shape[1]} sloupců")
print(df.head())
print("\nZákladní statistiky:")
print(df.describe())
# 2. DISKRETIZACE (pro Bayesovskou síť v GeNIe)
print("2. DISKRETIZACE PROMĚNNÝCH")
df_bn = df.copy()
# Hours Studied: Low=1–3, Medium=4–6, High=7–9
df_bn["Hours_cat"] = pd.cut(df["Hours Studied"], bins=[0, 3, 6, 9], labels=["Low", "Medium", "High"])
# Previous Scores: Low=40–60, Medium=61–80, High=81–99
df_bn["Score_cat"] = pd.cut(df["Previous Scores"], bins=[39, 60, 80, 100], labels=["Low", "Medium", "High"])
# Sleep Hours: Low=4–5, Normal=6–7, High=8–9
df_bn["Sleep_cat"] = pd.cut(df["Sleep Hours"], bins=[3, 5, 7, 9], labels=["Low", "Normal", "High"])
# Sample Question Papers: Low=0–3, Medium=4–6, High=7–9
df_bn["Practice_cat"] = pd.cut(df["Sample Question Papers Practiced"], bins=[-1, 3, 6, 9], labels=["Low", "Medium", "High"])
# Performance Index: Low=10–40, Medium=41–70, High=71–100
df_bn["Performance_cat"] = pd.cut(df["Performance Index"], bins=[9, 40, 70, 100], labels=["Low", "Medium", "High"])
# Extracurricular Activities – ponechat jako Yes/No
df_bn["Extracurricular"] = df["Extracurricular Activities"]
# Výsledný dataset pro GeNIe
df_export = df_bn[["Hours_cat", "Score_cat", "Extracurricular", "Sleep_cat", "Practice_cat", "Performance_cat"]]
print("\nUkázka diskretizovaných dat:")
print(df_export.head(10))
print("\nRozložení stavů – Performance_cat:")
print(df_export["Performance_cat"].value_counts())
# Uložení pro GeNIe
df_export.to_csv("student_bn.csv", index=False)
print("\n✓ Diskretizovaná data uložena do: student_bn.csv → Tento soubor importujte do GeNIe přes Data/Cases")
# 3. KLASICKÝ MODEL – RANDOM FOREST (regrese)
print("3. KLASICKÝ MODEL – Random Forest (regrese)")
# Příprava dat – numerická verze
X_num = df[["Hours Studied", "Previous Scores", "Sleep Hours", "Sample Question Papers Practiced"]].copy()
X_num["Extracurricular"] = (df["Extracurricular Activities"] == "Yes").astype(int)
y_reg = df["Performance Index"]
X_train, X_test, y_train, y_test = train_test_split(X_num, y_reg, test_size=0.2, random_state=42)
rf_reg = RandomForestRegressor(n_estimators=100, random_state=42)
rf_reg.fit(X_train, y_train)
y_pred_reg = rf_reg.predict(X_test)

mse  = mean_squared_error(y_test, y_pred_reg)
rmse = np.sqrt(mse)
print(f"\nVýsledky regrese (Performance Index jako číslo):")
print(f"  MSE  = {mse:.4f}")
print(f"  RMSE = {rmse:.4f}")
# Feature importance
print("\nDůležitost proměnných (feature importance):")
fi = pd.Series(rf_reg.feature_importances_, index=X_num.columns)
for feat, imp in fi.sort_values(ascending=False).items():
    bar = "█" * int(imp * 40)
    print(f"  {feat:<42} {imp:.4f}  {bar}")

# 4. KLASICKÝ MODEL – RANDOM FOREST (klasifikace)
print("\n4. KLASICKÝ MODEL – Random Forest (klasifikace)")
# Cílová proměnná jako kategorie (srovnatelné s BN)
y_cat = df_bn["Performance_cat"].astype(str)
X_train_c, X_test_c, y_train_c, y_test_c = train_test_split(X_num, y_cat, test_size=0.2, random_state=42)
rf_cls = RandomForestClassifier(n_estimators=100, random_state=42)
rf_cls.fit(X_train_c, y_train_c)
y_pred_cls = rf_cls.predict(X_test_c)
acc = accuracy_score(y_test_c, y_pred_cls)
print(f"\nAccuracy klasifikace (Low/Medium/High): {acc:.4f}  ({acc*100:.1f} %)")
print("\nKlasifikační zpráva:")
print(classification_report(y_test_c, y_pred_cls, target_names=["High", "Low", "Medium"]))
print("Matice záměn:")
cm = confusion_matrix(y_test_c, y_pred_cls, labels=["Low", "Medium", "High"])
cm_df = pd.DataFrame(cm, index=["Skutečné Low", "Skutečné Medium", "Skutečné High"], columns=["Pred. Low", "Pred. Medium", "Pred. High"])
print(cm_df)
# 5. SROVNÁNÍ PŘÍSTUPŮ
print("5. SROVNÁNÍ PŘÍSTUPŮ")
print("""
┌─────────────────────────┬──────────────────────────┬──────────────────────────┐
│ Kritérium               │ Bayesovská síť (GeNIe)   │ Random Forest            │
├─────────────────────────┼──────────────────────────┼──────────────────────────┤
│ Přesnost                │ Pravděpodobnosti stavů   │ RMSE, Accuracy           │
│ Interpretovatelnost     │ CPT tabulky + DAG graf   │ Feature importance       │
│ Práce s nejistotou      │ P(X | evidence)          │ Bodová predikce          │
│ Flexibilita             │ Diagnostická inference   │ Predikční výkon          │
│ Nutná data              │ Diskretizovaná           │ Numerická i kategorická  │
└─────────────────────────┴──────────────────────────┴──────────────────────────┘
""")
print(f"Random Forest Accuracy (klasifikace): {acc*100:.1f} %")
print(f"Random Forest RMSE     (regrese):     {rmse:.2f} bodů")
print("""
Závěr:
    Random Forest dosahuje vyšší numerické přesnosti predikce.
    Bayesovská síť umožňuje diagnostickou inferenci (např. jaké jsou
    pravděpodobné hodnoty HoursStudied, pokud víme PerformanceIndex=High?).
    BN explicitně modeluje nejistotu přes rozdělení pravděpodobnosti, RF vrací pouze bodový odhad (nebo hlasování tříd).
""")
