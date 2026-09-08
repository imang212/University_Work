"""
Úkol 2 – Bayesovská síť + Logistická regrese
Datová sada: Credit.txt
Autor: praktická úloha z předmětu (UJEP)
Skript provádí:
  1. Načtení a průzkum dat
  2. Bayesovská síť v Pythonu (pgmpy) se strukturou z prezentace
  3. Pravděpodobnostní inference pro různé scénáře klientů
  4. Logistická regrese + vyhodnocení metrik
  5. Srovnání obou přístupů
"""
import pandas as pd
import numpy as np
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import (accuracy_score, precision_score, recall_score, f1_score, classification_report, confusion_matrix)
import warnings
warnings.filterwarnings("ignore")
# 1. NAČTENÍ DAT
print("ÚKOL 2 – Credit Worthiness")
df = pd.read_csv("Credit.txt", sep=" ")
print(f"\nNačteno {df.shape[0]} záznamů, {df.shape[1]} sloupců")
print(df.head())
print("\nSloupcová schémata:")
print(df.dtypes)
print("\nRozložení cílové proměnné CreditWorthiness:")
print(df["CreditWorthiness"].value_counts())
print(f"  Podíl Positive (1): {df['CreditWorthiness'].mean():.2%}")
# 2. BAYESOVSKÁ SÍŤ (pgmpy)
print("\n2. BAYESOVSKÁ SÍŤ (pgmpy)")
try:
    from pgmpy.models import BayesianNetwork
    from pgmpy.estimators import MaximumLikelihoodEstimator, BayesianEstimator
    from pgmpy.inference import VariableElimination
    # Struktura DAG podle prezentace
    edges = [
        ("Income", "RatioDebInc"),
        ("Debit", "RatioDebInc"),
        ("Income", "Worth"),
        ("Assets", "Worth"),
        ("PaymentHistory", "Reliability"),
        ("WorkHistory", "Reliability"),
        ("Profession", "FutureIncome"),
        ("Worth", "FutureIncome"),
        ("Reliability", "CreditWorthiness"),
        ("Age", "CreditWorthiness"),
        ("FutureIncome", "CreditWorthiness"),
    ]
    model = BayesianNetwork(edges)
    # Učení parametrů (CPT) z dat – Bayesovský odhad se vyhlazením
    model.fit(df, estimator=BayesianEstimator, prior_type="BDeu", equivalent_sample_size=10)
    print("\n✓ Bayesovská síť úspěšně naučena.")
    print(f"  Uzly: {model.nodes()}")
    print(f"  Hrany (DAG): {model.edges()}")
    # Ověření CPT pro CreditWorthiness
    cpd = model.get_cpds("CreditWorthiness")
    print(f"\nCPT uzlu CreditWorthiness (prvních 6 sloupců):")
    cpd_df = pd.DataFrame( cpd.get_values(), index=[f"CW={s}" for s in cpd.state_names["CreditWorthiness"]])
    print(cpd_df.iloc[:, :6].round(3))
    # Inference
    infer = VariableElimination(model)
    print("\nPRAVDĚPODOBNOSTNÍ INFERENCE – scénáře klientů")
    scenarios = [{
            "name": "Ideální klient",
            "evidence": {"PaymentHistory": 3, "WorkHistory": 3, "Income": 3, "Assets": 3}
            },
            {
            "name": "Rizikový klient",
            "evidence": {"PaymentHistory": 0, "WorkHistory": 0, "Income": 0, "Assets": 0}
            },
            {
            "name": "Průměrný klient",
            "evidence": {"PaymentHistory": 1, "WorkHistory": 2, "Income": 2, "Assets": 1}
            }
            ,{
            "name": "Dobrá platební hist., nízký příjem",
            "evidence": {"PaymentHistory": 3, "WorkHistory": 2, "Income": 0, "Assets": 1}
            },]
    for sc in scenarios:
        result = infer.query(variables=["CreditWorthiness"], evidence=sc["evidence"])
        vals = result.values
        # hodnoty: index 0 = Negative (0), index 1 = Positive (1)
        p_pos = vals[1] if len(vals) > 1 else vals[0]
        p_neg = vals[0]
        verdict = "✓ POSITIVE" if p_pos > 0.5 else "✗ NEGATIVE"
        print(f"\nScénář: {sc['name']}")
        print(f"Evidence: {sc['evidence']}")
        print(f"P(Positive) = {p_pos:.4f}   P(Negative) = {p_neg:.4f}")
        print(f"Verdikt: {verdict}")
    # Diagnostická inference
    print("\nDIAGNOSTICKÁ INFERENCE")
    print("Co víme: CreditWorthiness = Positive")
    print("Co je pravděpodobné pro PaymentHistory?")
    diag = infer.query(variables=["PaymentHistory"], evidence={"CreditWorthiness": 1})
    print(diag)
    bn_available = True
except ImportError:
    print("\npgmpy není nainstalováno.")
    print("Nainstalujte příkazem:  pip install pgmpy")
    print("Bayesovská síť přeskočena; pokračujeme logistickou regresí.")
    bn_available = False

# 3. LOGISTICKÁ REGRESE
print("\n3. LOGISTICKÁ REGRESE")
feature_cols = ["PaymentHistory", "WorkHistory", "Reliability", "Debit", "Income", "RatioDebInc", "Assets", "Worth", "Profession", "FutureIncome", "Age"]
target_col = "CreditWorthiness"
X = df[feature_cols]
y = df[target_col]
# Rozdělení dat 70 / 30
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.30, random_state=42, stratify=y)
print(f"\nTrénovací sada: {X_train.shape[0]} záznamů")
print(f"Testovací sada: {X_test.shape[0]} záznamů")
# Trénování modelu
lr = LogisticRegression(max_iter=500, random_state=42)
lr.fit(X_train, y_train)
y_pred = lr.predict(X_test)
y_prob = lr.predict_proba(X_test)[:, 1]
# Metriky
acc = accuracy_score(y_test, y_pred)
prec = precision_score(y_test, y_pred)
rec = recall_score(y_test, y_pred)
f1 = f1_score(y_test, y_pred)
print(f"\nVýsledky logistické regrese:")
print(f"Accuracy  = {acc:.4f}  ({acc*100:.1f} %)")
print(f"Precision = {prec:.4f}")
print(f"Recall    = {rec:.4f}")
print(f"F1-score  = {f1:.4f}")
print("\nKlasifikační zpráva:")
print(classification_report(y_test, y_pred, target_names=["Negative (0)", "Positive (1)"]))
print("Matice záměn:")
cm = confusion_matrix(y_test, y_pred)
cm_df = pd.DataFrame(cm, index=["Skutečné Negative", "Skutečné Positive"], columns=["Pred. Negative", "Pred. Positive"])
print(cm_df)
# Koeficienty modelu
print("\nKoeficienty logistické regrese (vliv proměnných):")
coef_df = pd.DataFrame({"Proměnná": feature_cols, "Koeficient": lr.coef_[0]}).sort_values("Koeficient", ascending=False)
for _, row in coef_df.iterrows():
    bar_len = int(abs(row["Koeficient"]) * 10)
    sign = "+" if row["Koeficient"] > 0 else "-"
    bar = "█" * bar_len
    print(f"  {row['Proměnná']:<20} {row['Koeficient']:+.4f}  {sign}{bar}")
# 4. SROVNÁNÍ PŘÍSTUPŮ
print("\n4. SROVNÁNÍ PŘÍSTUPŮ")
print(f"""
┌─────────────────────────┬──────────────────────────┬──────────────────────────┐
│ Kritérium               │ Bayesovská síť           │ Logistická regrese       │
├─────────────────────────┼──────────────────────────┼──────────────────────────┤
│ Přesnost (Accuracy)     │ kvalita inference        │ {acc*100:.1f} %                  │
│ Interpretovatelnost     │ CPT tabulky + DAG        │ koeficienty β            │
│ Práce s nejistotou      │ P(X | evidence)          │ pravděpodobn. skóre      │
│ Diagnostická inference  │ ✓ ANO                    │ ✗ NE                     │
│ Scénářová analýza       │ ✓ ANO (změnou evidence)  │ ✗ jen predikce           │
│ Nutná data              │ diskretizovaná           │ libovolná číselná        │
└─────────────────────────┴──────────────────────────┴──────────────────────────┘
Logistická regrese:
  Accuracy  = {acc*100:.1f} %
  Precision = {prec:.4f}
  Recall    = {rec:.4f}
  F1-score  = {f1:.4f}
Závěr:
    Logistická regrese poskytuje přímočarou klasifikaci s měřitelnými metrikami a koeficienty ukazujícími vliv každé proměnné.
    Bayesovská síť umožňuje dotazovat se na libovolnou proměnnou (nejen CreditWorthiness) a měnit evidence za běhu – to je klíčové pro scénářovou analýzu (\"co se stane, když klient zvýší příjem?\").
    Oba přístupy vrací pravděpodobnosti, ale BN dělá inferenci přes celý graf, zatímco LR je čistě predikční (směr: X → Y).
""")
