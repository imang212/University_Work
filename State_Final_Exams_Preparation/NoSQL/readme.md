## NoSQL
**Proč ZVOLIT NoSQL (Výhody pro Open Data)**
- flexibilita schématu (Schema-less): Open Data z internetu bývají často nekonzistentní, mohou v nich chybět atributy (např. některý stát nemá uvedené HDP pro daný rok). V MongoDB do kolekce jednoduše vložíš dokument bez tohoto klíče a databáze neprotestuje, zatímco relační tabulka by vyžadovala striktní úpravu schématu.  
- Rychlost čtení díky denormalizaci: Zadání u této úlohy výslovně požaduje denormalizaci. Pokud vložíš (tzv. embedding) makroekonomickou hodnotu HDP přímo do dokumentu k informacím o cizincích, získáš všechny potřebné údaje pro report na jeden rychlý dotaz bez paměťově náročných operací JOIN.  
- Nativní formát pro vývoj: MongoDB ukládá záznamy v dokumentovém formátu BSON. Při vývoji backendových služeb a REST API se s těmito strukturami pracuje naprosto přirozeně – databázový dokument se rovnou mapuje na Python slovník bez nutnosti složitého ORM překladu.  

**Proč NEZVOLIT NoSQL (Nevýhody pro tento analytický úkol)**
- Analytická (OLAP) povaha úkolu: Cílem úlohy je primárně agregace a seskupování velkého množství dat (např. seskupení cizinců podle HDP). Relační (a zejména sloupcové) databáze jsou na tyto hromadné matematické operace architektonicky mnohem lépe optimalizované.  
- Obrovská redundance dat: Pokud do MongoDB denormalizujeme data, budeme muset hodnotu HDP daného státu zkopírovat do každého jednoho dokumentu pro každou demografickou skupinu z dané země. Databáze tak zbytečně nabobtná na velikosti.
- Problém při aktualizaci (Update anomaly): Kdyby se zpětně zjistila chyba ve stažených datech o HDP a bylo potřeba údaj opravit, v SQL přepíšeš jeden řádek. V denormalizované NoSQL databázi bys musel najít a přepsat desítky tisíc zanořených dokumentů.

**Zpracování dat pro MongoDB(Python)**
```python
import pandas as pd
from pymongo import MongoClient

## PŘÍPRAVA A DENORMALIZACE DAT V PANDAS
# Načtení dat
df_cizinci = pd.read_csv('cizinci_2019.csv')
df_hdp = pd.read_csv('hdp.csv')
# Očištění identifikátorů pro spolehlivé spojení (zbavení se mezer a sjednocení velikosti)
df_cizinci['stat'] = df_cizinci['stat'].astype(str).str.strip().str.upper()
df_hdp['stat'] = df_hdp['stat'].astype(str).str.strip().str.upper()
# Zahození prázdných hodnot
df_cizinci = df_cizinci.dropna(subset=['stat'])
df_hdp['hdp_na_hlavu'] = df_hdp['hdp_na_hlavu'].fillna(0)
# DENORMALIZACE - Sloučíme data z obou zdrojů do jedné široké tabulky. Každý demografický záznam nyní bude obsahovat i HDP daného státu.
df_denormalized = pd.merge(df_cizinci, df_hdp, on='stat', how='inner')
# Převod sloučené tabulky na seznam slovníků (JSON formát), kterému MongoDB rozumí
dokumenty = df_denormalized.to_dict(orient='records')

## VLOŽENÍ DO MONGODB
# Připojení k lokálnímu Docker kontejneru s MongoDB
client = MongoClient('mongodb://localhost:27017/')
db = client['statnice_nosql']
kolekce = db['cizinci_data']
# Vyčištění kolekce (pro opakované spouštění skriptu) a vložení nových dokumentů
kolekce.drop()
kolekce.insert_many(dokumenty)
print(f"Úspěšně vloženo {len(dokumenty)} denormalizovaných dokumentů.")

## AGREGAČNÍ PIPELINE (DOTAZOVÁNÍ)
# Zadání preferuje agregační operace. Vytvoříme pipeline, která seskupí data cizinců podle HDP na hlavu v zemích, kde mají státní občanství.
pipeline = [
    {
        # kr.1 Seskupení ($group)
        "$group": {
            "_id": "$hdp_na_hlavu", # Seskupujeme podle HDP (státy se stejným HDP se spojí)
            "celkovy_pocet_cizincu": { "$sum": "$pocet" }, # Sečteme všechny cizince v této skupině
            "seznam_statu": { "$addToSet": "$stat" } # Vytvoříme unikátní seznam států v této skupině
        }
    },
    {
        # kr.2 Seřazení ($sort) od největšího HDP po nejmenší
        "$sort": { "_id": -1 }
    }
]
# Spuštění pipeliny
vysledky = list(kolekce.aggregate(pipeline))

## VÝPIS VÝSLEDKŮ
print("\nUkázka agregovaných výsledků (Top 5 skupin podle HDP):")
for vysledek in vysledky[:5]:
    hdp = vysledek['_id']
    pocet = vysledek['celkovy_pocet_cizincu']
    staty = ", ".join(vysledek['seznam_statu'])
    print(f"HDP: {hdp} | Cizinců celkem: {pocet} | Státy: {staty}")
```

**Agregace a Vizualizace**
```python
import matplotlib.pyplot as plt

# Seskupení podle roku a státu
pipeline_rok_stat = [
    {
        "$group": {
            # V MongoDB můžeme seskupovat podle více klíčů naráz vytvořením složeného _id
            "_id": { "rok": "$rok", "stat": "$stat" },
            "celkem_cizincu": { "$sum": "$pocet" }
        }
    },
    {
        # Seřazení podle počtu cizinců sestupně
        "$sort": { "celkem_cizincu": -1 }
    }
]
vysledky_rok_stat = list(kolekce.aggregate(pipeline_rok_stat))

print("\nUkázka výsledků (Seskupení podle roku a státu):")
for v in vysledky_rok_stat[:3]:
    print(f"Rok: {v['_id'].get('rok', '2019')} | Stát: {v['_id']['stat']} | Cizinců: {v['celkem_cizincu']}")

# VIZUALIZACE VÝSLEDKŮ
# Pro vizualizaci využijeme výsledky z naší první pipeliny (seskupení podle HDP). MongoDB nám vrátilo list slovníků, který pro Matplotlib snadno převedeme zpět do DataFrame.
df_plot = pd.DataFrame(vysledky)
# Mongo nám HDP uložilo do sloupce '_id'. Pro přehlednost si ho přejmenujeme.
df_plot = df_plot.rename(columns={"_id": "hdp"})
# Vykreslení bodového grafu
plt.figure(figsize=(10, 6))
plt.scatter(
    df_plot['hdp'], 
    df_plot['celkovy_pocet_cizincu'], 
    color='forestgreen', 
    alpha=0.7, 
    edgecolors='black'
)
plt.title('Závislost počtu cizinců na HDP (Data z MongoDB)', fontsize=14, pad=15)
plt.xlabel('HDP na hlavu', fontsize=12)
plt.ylabel('Celkový počet cizinců (Logaritmická škála)', fontsize=12)
# I zde použijeme logaritmickou škálu pro lepší čitelnost dat
plt.yscale('log')
plt.grid(True, linestyle='--', alpha=0.5)
plt.show()
```
