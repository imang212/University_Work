**Úloha: Výška hladiny v řece**

Tvým úkolem je najít optimální model, který popíše, na čem a jakým způsobem závisí výška hladiny v řece, přičemž máš k dispozici data o různých ukazatelích.  

Zkouška probíhá formou tvorby reportu, který musí obsahovat analýzy, vizualizace a především slovní interpretace. Postupuje se v těchto čtyřech krocích:  

**Krok 1: Průzkum a Vizualizace**
- Nejprve musíš zhodnotit, zda jde o časovou řadu, nebo nezávislá pozorování, a identifikovat závisle proměnnou.  Vykreslíš grafy (bodové grafy pro nezávislá měření, korelační funkce pro časové řady) a napíšeš komentář s očekáváním – například jaké závislosti se dají předpokládat nebo zda jsou v datech závislé regresory.  

**Krok 2: Návrh více modelů**
- Komise vyžaduje, abys navrhl a porovnal více různých modelů.  Pro časové řady zkusíš například model trendu a sezónnosti, SARIMA model, nebo model závislosti na ostatních řadách.  Pro nezávislá data zkusíš lineární/polynomickou regresi s využitím krokové regrese (stepwise) a modelů s interakcemi.  

**Krok 3: Hodnocení kvality a kontrola předpokladů**
- Modely porovnáš pomocí indikátorů jako je Akaikeho (AIC) nebo Bayesovské (BIC) kritérium, procento vysvětlené variability ($R^2$), významnost koeficientů (p-hodnoty) a střední chyba residuí.  Klíčový bod obhajoby: Musíš zkontrolovat předpoklady modelů (nezávislost a normalita residuí, stabilita rozptylu). Pokud nesedí, musíš provést nápravu – například logaritmovat závisle proměnnou (při nestabilním rozptylu) nebo přidat členy ARMA (při závislých residuích).  

**Krok 4: Závěrečná interpretace**
- Slovně popíšeš, který model je nejlepší a proč.  Vítězný model musíš umět zapsat formou matematické rovnice a vysvětlit, jak jednotlivé faktory ovlivňují výšku hladiny a jak dobré predikce lze očekávat.

**1. Příprava dat, vizualizace a průzkum**
```R
# Načtení potřebného balíčku pro časové řady
library(forecast)
# 1. Načtení dat (předpokládáme CSV soubor)
data <- read.csv("reka_data.csv")
# 2. Převod na objekt časové řady (ts) - např. měsíční data od roku 2015
hladina_ts <- ts(data$hladina, start=c(2015, 1), frequency=12)
srazky_ts <- ts(data$srazky, start=c(2015, 1), frequency=12)
# 3. Vizuální průzkum (Očekávaný výstup reportu)
par(mfrow=c(2,2)) # Rozdělení okna na 4 grafy
# Zobrazení samotného průběhu závisle proměnné
plot(hladina_ts, main="Průběh výšky hladiny v čase", ylab="Hladina (cm)", xlab="Čas")
# Korelační funkce (ACF) pro časové řady
Acf(hladina_ts, main="Korelační funkce (ACF) hladiny")
# Bodové grafy pro vizualizaci závislostí na ostatních proměnných
plot(data$srazky, data$hladina, main="Závislost hladiny na srážkách", xlab="Srážky", ylab="Hladina")
plot(data$teplota, data$hladina, main="Závislost hladiny na teplotě", xlab="Teplota", ylab="Hladina")
```
- Z ACF grafu je zřejmé, že data vykazují silnou autokorelaci (hodnoty v čase na sobě závisí) a pravděpodobně i roční sezónnost. Bodový graf ukazuje pozitivní lineární korelaci mezi srážkami a hladinou. Na základě těchto zjištění lze očekávat, že bude nutné použít modely časových řad, nikoliv jen běžnou lineární regresi.

**Návrh a odhad modelu**
```R
# Model A: Mnohonásobná lineární regrese (bez ohledu na čas)
model_lm <- lm(hladina ~ srazky + teplota, data=data)
# Model B: SARIMA model (model závislosti na ostatních řadách)
# Funkce auto.arima sama najde optimální parametry p,d,q a P,D,Q podle AIC
xreg_matrix <- cbind(Srazky=data$srazky, Teplota=data$teplota)
model_sarima <- auto.arima(hladina_ts, xreg=xreg_matrix)
# Výpis výsledků modelů pro porovnání (indikátory kvality: AIC, BIC, koeficienty)
summary(model_lm)
summary(model_sarima)
```
**významnost koeficientů**
- V tabulce koeficientů vidíme, že p-hodnota pro srážky je hluboko pod hladinou významnosti $0.05$ (má tři hvězdičky). Srážky mají na hladinu prokazatelný vliv. Naopak teplota má p-hodnotu $0.194$, což znamená, že v tomto konkrétním modelu není statisticky významná a mohli bychom ji z modelu vyřadit (tzv. kroková regrese)
- Vliv na závisle proměnnou (Estimate): Sloupec Estimate říká, jak silný ten vliv je. U srážek je číslo 2.5000
**Adjusted R-squared (procento vysvětlené variability)**
- Obyčejný Multiple R-squared uměle roste, i když do modelu přidáš úplný nesmysl. Upravený Adjusted R-squared tě penalizuje za přidávání zbytečných proměnných, takže je u mnohonásobné regrese mnohem přesnější ukazatel.
- Kvalitu modelu hodnotím podle upraveného R-kvadrát. Hodnota $0.734$ znamená, že náš model dokáže vysvětlit $73.4\%$ veškeré variability ve výšce hladiny řeky. Zbytek (necelých $27\%$) je způsoben náhodnými vlivy nebo faktory, které v datech nemáme změřené
**Residual standard error (Střední chyba residuí)**
- Udává, jak moc se v průměru liší skutečně naměřené hodnoty od těch, které předpověděl tvůj model.
- Střední chyba residuí je $3.45$. To znamená, že když pomocí tohoto modelu zkusíme predikovat výšku hladiny, budeme se v průměru mýlit o $3.45$ centimetru (nebo jiné jednotky, ve které je hladina měřena).

**Kontrola předpokladů a náprava**
```R
# Nástroj checkresiduals z balíčku forecast udělá Ljung-Boxův test nezávislosti, vykreslí histogram normality a graf rozptylu residuí. Předpoklady: nezávislost a normalita residuí a stabilita rozptylu
checkresiduals(model_lm) 
checkresiduals(model_sarima)
# UKÁZKA NÁPRAVY (Pokud předpoklady nejsou splněny):
# Pokud graf residuí ukazuje nestabilní rozptyl (nálevkovitý tvar) nebo nenormální residua, 
# provedeme logaritmování závisle proměnné.
hladina_log_ts <- log(hladina_ts)
# Přepočítání modelu na logaritmovaných datech
model_sarima_log <- auto.arima(hladina_log_ts, xreg=xreg_matrix)
checkresiduals(model_sarima_log)
```

Při porovnání modelů se jako optimální ukázal model SARIMA s externími regresory. Oproti modelu A (klasická regrese) vyřešil problém se závislými residui (autokorelací) přidáním členů ARMA modelů. Model B má navíc výrazně nižší (lepší) Akaikeho informační kritérium (AIC). Ljung-Boxův test potvrdil, že residua u Modelu B jsou již nezávislá a připomínají bílý šum, takže splňují předpoklady."

**Zápis rovnice optimálního modelu:**

Zadání vyžaduje zapsat model formou rovnice a popsat vliv faktorů. Pokud ti auto.arima vyhodí například model ARIMA s jedním autoregresním členem (AR1) a dvěma regresory, rovnice vypadá takto:

$$Y_t = c + \phi_1 Y_{t-1} + \beta_1 X_{1,t} + \beta_2 X_{2,t} + \epsilon_t$$

**Kde:**
- $Y_t$ je výška hladiny v čase $t$.
- $c$ je konstanta (intercept).$\phi_1 
- Y_{t-1}$ je autoregresní část (vliv hladiny z předchozího měsíce).
- $\beta_1 X_{1,t}$ je vliv srážek (vysvětlíš, že pokud $\beta_1$ je např. $2.5$, pak zvýšení srážek o jednotku zvedne hladinu o $2.5$ jednotky).
- $\beta_2 X_{2,t}$ je vliv teploty.
- $\epsilon_t$ je chybový člen (bílý šum).