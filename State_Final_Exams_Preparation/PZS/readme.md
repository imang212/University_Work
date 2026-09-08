## PZS
**1. Základní vlastnosti a charakteristiky signálu** - Než začneš signál programově zpracovávat, musíš popsat jeho chování v časové oblasti. U obhajoby bys měl definovat tyto pojmy:
- Amplituda: Maximální výchylka signálu z rovnovážné polohy (např. jak "vysoký" je R-vrchol v EKG).  
- Perioda: Časový úsek, za který se signál nebo jeho jeden cyklus zopakuje (u EKG je to vzdálenost mezi dvěma tepy).  
- Frekvence: Převrácená hodnota periody ($f = 1/T$). Říká, kolikrát se cyklus zopakuje za jednu sekundu, a měří se v Hertzech (Hz).  
- Fáze: Udává posunutí signálu v čase oproti nějakému referenčnímu počátku.  
- Práce a energie signálu: Vypočítá se jako integrál (nebo suma) kvadrátu signálu. Ukazuje celkovou "sílu" signálu a používá se pro detekci toho, kde se v signálu děje něco významného.  
- Trend: Dlouhodobý posun nebo kolísání signálu. U EKG se tomu říká baseline wander – jak pacient dýchá, hrudník se hýbe a celá křivka EKG kvůli tomu pomalu stoupá a klesá, což se musí před detekcí tepu matematicky odstranit (tzv. detrendování).  

```python
# Využití vestavěných funkcí NumPy pro výpočet vlastností
amplituda_signalu = np.max(ekg_filtered) - np.min(ekg_filtered)
energie_signalu = np.sum(ekg_filtered ** 2)

print(f"Amplituda EKG signálu: {amplituda_signalu:.2f} mV")
print(f"Celková energie signálu: {energie_signalu:.2f}")
```

**2. Metody zpracování v časové oblasti. Tyto operace pracují se signálem tak, jak ho vidíš běžně vykreslený (osa X je čas)**
- Konvoluce: Tohle je absolutní základ pro filtrace a posílení signálu v časové oblasti. Jde o matematickou operaci, kdy vezmeš původní dlouhý signál a "přejíždíš" po něm jiným (mnohem kratším) signálem, kterému se říká filtr nebo maska. Tím se signály prolínají. Používá se to například pro vyhlazení křivky (klouzavý průměr je vlastně konvoluce).  
- Korelace: Měří podobnost dvou signálů, které proti sobě posouváme v čase. Je to ideální detektor. Pokud máš z lékařské knihovny dokonalý vzor jednoho srdečního tepu, můžeš pomocí korelace "projet" dlouhý pacientův záznam – tam, kde korelace vyskočí na maximum, jsi našel další tep.  
- Kovariance: Je velmi podobná korelaci, ale udává, jak moc se dva signály mění společně, přičemž není na rozdíl od korelace normalizovaná.  

**3. Zpracování ve frekvenční oblasti a Fourierova transformace.**
- Fourierova transformace (FT): Je to metoda zpracování signálu ve frekvenční oblasti. FT vychází z faktu, že jakýkoliv složitý signál (třeba klikaté EKG) se dá matematicky rozložit na součet mnoha jednoduchých sinusovek o různých frekvencích a amplitudách.  
- Intuice: Představ si, že EKG signál je polévka (časová oblast). Fourierova transformace je přístroj, který do té polévky strčíš, a on ti na displeji ukáže přesný recept – kolik gramů soli, pepře a mrkve (frekvencí) v ní je. Tomuto výstupu se říká frekvenční spektrum.  

**Proč to děláme? (Filtrace šumu):** Zadání explicitně vyžaduje znalost technik pro filtraci šumu ve frekvenčním spektru. EKG data jsou často zarušená elektrickou sítí z nemocničních přístrojů, která u nás funguje na 50 Hz.

Když se díváš na signál v časové oblasti, šum se maže těžko. Když ale uděláš Fourierovu transformaci a podíváš se na frekvenční spektrum, šum bude vypadat jako obrovský grafický "špičák" přesně na hodnotě 50 Hz. Ty tento bod v poli prostě programově vymažeš a uděláš Inverzní Fourierovu transformaci zpět do času. Výsledkem je nádherně čisté EKG bez rušení. 

**Detekce tepové frekvence z EKG**
- Tvým úkolem je načíst surová EKG data, očistit je a najít v nich tepovou frekvenci (HR - Heart Rate). Řešení má čtyři klíčové fáze:
- Krok 1: Načtení dat ve specializovaném formátu - V biomedicíně (např. v databázi PhysioNet) se EKG data často ukládají ve speciálních formátech (WFDB, EDF, zřídka čisté CSV). Budeš muset využít nástroje pro načtení těchto signálů do klasického NumPy pole.
- Krok 2: Základní operace se signály (Předzpracování) - Surové EKG je vždycky zašuměné. Budeš muset provést:
    - Detrendování: Odstranění kolísání základní linie (baseline wander), které vzniká tím, jak pacient při měření dýchá.  
    - Filtrace šumu: Použití filtrů (např. propust pásma přes SciPy), abys odstranil vysokofrekvenční šum ze svalů nebo rušení ze sítě (50 Hz). 
- Krok 3: Detekce událostí v signálech (R vrchol) - EKG křivka (tzv. QRS komplex) má jeden dominantní ostrý hrot – R vrchol (R peak). Tvým úkolem je vytvořit postup, který tyto vrcholy v poli detekuje. Ve SciPy se k tomu s oblibou používá funkce find_peaks, ale musíš jí správně nastavit parametry (např. minimální vzdálenost mezi tepy), a otestovat silné a slabé stránky svého přístupu.
- Krok 4: Výpočet tepové frekvence a Vizualizace - Jakmile znáš časové pozice R vrcholů, spočítáš z jejich vzdáleností tepovou frekvenci. Zadání výslovně požaduje tyto výstupy (grafy vytvořené pravděpodobně v Matplotlibu):  
    - Graf vývoje tepové frekvence v závislosti na čase pro jeden signál (a graf HR v závislosti na průběhu signálu).  
    - Přehledový graf závislosti tepové frekvence (ze všech signálů v databázi).  
    - Graf shody mezi tebou navrženým schématem a anotovanými daty v databázi. (Tzn. srovnání, jak moc se tvůj algoritmus trefil do skutečných hodnot tepu, které určili lékaři).

**1. Načtení dat a nezbytné importy** - Nejprve musíme načíst data ve specializovaném formátu a získat i referenční anotace (skutečné pozice tepů, které označil lékař), abychom s nimi později mohli porovnat náš vlastní algoritmus.
```python
import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import butter, filtfilt, find_peaks, detrend
import wfdb  # Specializovaný nástroj pro databázi PhysioNet
# 1. NAČTENÍ DAT VE SPECIALIZOVANÉM FORMÁTU
# Načteme záznam '100' z MIT-BIH databáze (obsahuje 2 kanály EKG)
record = wfdb.rdrecord('100', sampto=3000) 
annotation = wfdb.rdann('100', 'atr', sampto=3000)
# Extrakce samotného signálu (využijeme první kanál) a vzorkovací frekvence
ekg_signal = record.p_signal[:, 0]
fs = record.fs  # Vzorkovací frekvence (zpravidla 360 Hz)
casova_osa = np.arange(len(ekg_signal)) / fs
# Skutečné pozice R-vrcholů z databáze (pro finální porovnání shody)
skutecne_r_peaky = annotation.sample
```

**2. Předzpracování signálu (Filtrace a Detrendování)** - Surový signál je plný šumu. Aplikujeme detrendování a propustnost pásma (Bandpass filter).
```python
# 2. ZÁKLADNÍ OPERACE SE SIGNÁLY
# A) Detrendování (odstranění kolísání základní linie kvůli dýchání pacientů)
ekg_detrend = detrend(ekg_signal)
# B) Filtrace šumu (Bandpass filtr pro propuštění jen frekvencí typických pro QRS komplex)
# EKG signál je obvykle nejsilnější mezi 0.5 Hz a 15 Hz.
def bandpass_filter(data, lowcut, highcut, fs, order=2):
    nyq = 0.5 * fs # Nyquistova frekvence
    low = lowcut / nyq
    high = highcut / nyq
    b, a = butter(order, [low, high], btype='band')
    y = filtfilt(b, a, data)
    return y
ekg_filtered = bandpass_filter(ekg_detrend, 0.5, 15.0, fs)
```

**3. Detekce R-vrcholů a výpočet tepové frekvence** - Nyní najdeme špičky (R-vrcholy) a z jejich vzdálenosti spočítáme tepovou frekvenci (HR).
```python
# 3. DETEKCE UDÁLOSTÍ V SIGNÁLU (R VRCHOL)
# Parametr 'height' zajistí, že nebereme malé šumové špičky.
# Parametr 'distance' říká, že dva tepy nemohou být blíž než např. 0.3 sekundy (odpovídá max 200 BPM).
min_vzdalenost = int(0.3 * fs) 
detekovane_r_peaky, _ = find_peaks(ekg_filtered, height=0.5, distance=min_vzdalenost)
# 4. VÝPOČET TEPOVÉ FREKVENCE
# Vypočítáme vzdálenosti mezi vrcholy (RR intervaly)
rr_intervaly = np.diff(detekovane_r_peaky) / fs  # v sekundách
# Tepová frekvence v úderech za minutu (BPM)
tepova_frekvence = 60.0 / rr_intervaly
# Přiřazení času k vypočítané tepové frekvenci (hr se váže vždy k druhému z dvojice tepů)
cas_tepu = detekovane_r_peaky[1:] / fs
```

**Posílení signálu v časové oblasti:** Než se na EKG signál pustí algoritmus pro hledání R-vrcholů (find_peaks), v praxi (např. v proslulém Pan-Tompkinsově algoritmu) se provádí nelineární posílení signálu umocněním na druhou.
- Proč to děláme: Protože všechny hodnoty EKG pole umocníme na druhou (tedy $x^2$), malá čísla (šum) se stanou ještě menšími a velká čísla (dominantní R-vrcholy) vystřelí prudce nahoru. Tím se signál dramaticky posílí pro detekci. Navíc se tím odstraní záporné hodnoty (vše se překlopí do plusu).
```python
# Technika pro posílení signálu: Umocnění signálu na druhou (Squaring)
ekg_posilene = ekg_filtered ** 2
# Nyní bys funkci find_peaks pustil na 'ekg_posilene' místo na 'ekg_filtered'
```

**4. Vizualizace (Očekávané výstupy)** - Zadání specifikuje tři konkrétní grafy. Zde je kód, který pomocí Matplotlibu vygeneruje přesně požadované vizuály.
```python
plt.figure(figsize=(12, 10))
# GRAF 1: Průběh signálu a zobrazení tepové frekvence v závislosti na něm
plt.subplot(3, 1, 1)
plt.plot(casova_osa, ekg_filtered, label='Vyfiltrované EKG', color='black', alpha=0.7)
plt.plot(detekovane_r_peaky / fs, ekg_filtered[detekovane_r_peaky], 'ro', label='Detekované R-vrcholy')
plt.ylabel('Amplituda (mV)')
plt.title('Detekce R-vrcholů a průběh EKG signálu')
plt.legend()
# Přidáme druhou osu Y pro zobrazení vývoje tepové frekvence nad signálem
ax2 = plt.gca().twinx()
ax2.plot(cas_tepu, tepova_frekvence, color='blue', marker='x', linestyle='--', label='Tepová frekvence (HR)')
ax2.set_ylabel('Tepová frekvence (BPM)', color='blue')
ax2.tick_params(axis='y', labelcolor='blue')
# GRAF 2: Přehledový graf vývoje tepové frekvence v čase pro vybraný signál
plt.subplot(3, 1, 2)
plt.plot(cas_tepu, tepova_frekvence, color='darkorange', marker='o', linestyle='-')
plt.xlabel('Čas (s)')
plt.ylabel('Tepová frekvence (BPM)')
plt.title('Vývoj tepové frekvence (BPM) v čase')
plt.grid(True)
# GRAF 3: Graf shody mezi navrženým schématem a daty v databázi
plt.subplot(3, 1, 3)
# Osa X = indexy tepů, Osa Y = časový výskyt tepu (detekovaný vs skutečný)
# Pro porovnání ořízneme pole na stejnou délku, aby šly vykreslit proti sobě
min_delka = min(len(detekovane_r_peaky), len(skutecne_r_peaky))
plt.plot(detekovane_r_peaky[:min_delka] / fs, label='Můj algoritmus (find_peaks)', linestyle='--', marker='x', color='red')
plt.plot(skutecne_r_peaky[:min_delka] / fs, label='Anotace z databáze (Skutečnost)', alpha=0.5, linewidth=4, color='green')
plt.xlabel('Pořadové číslo srdečního tepu')
plt.ylabel('Čas výskytu tepu (s)')
plt.title('Shoda detekce: Náš algoritmus vs. Lékařské anotace z databáze')
plt.legend()
plt.tight_layout()
plt.show()
```

**Výpočet frekvenčního spektra signálu**
```python
from scipy.fft import fft, fftfreq
# Zjištění počtu vzorků v našem NumPy poli
N = len(ekg_signal)
# Výpočet frekvenčního spektra (samotná transformace)
# 'fft' vypočítá komplexní hodnoty amplitud
yf = fft(ekg_signal)
# 'fftfreq' nám k nim vygeneruje odpovídající osu X (frekvence v Hz)
xf = fftfreq(N, 1 / fs)
# FFT generuje zrcadlové (i záporné) frekvence, které nepotřebujeme.
# Pomocí slicingu v NumPy poli [0:N//2] si vezmeme jen první (kladnou) polovinu.
xf_kladne = xf[:N//2]
yf_amplitudy = np.abs(yf[:N//2]) # np.abs převede komplexní čísla na reálné amplitudy
# Vykreslení spektra
plt.figure(figsize=(10, 4))
plt.plot(xf_kladne, yf_amplitudy, color='purple')
plt.title("Frekvenční spektrum EKG signálu")
plt.xlabel("Frekvence (Hz)")
plt.ylabel("Amplituda")
# Pro lepší čitelnost si omezíme osu X, protože EKG má smysl cca do 50 Hz
plt.xlim(0, 50)
plt.grid(True)
plt.show()
```