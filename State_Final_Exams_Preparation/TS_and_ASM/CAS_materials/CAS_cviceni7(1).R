############################
library(forecast); library(TSA); library(dynlm); library(lmtest) # nacteni knihoven
############################
### Opakovani - Hledani modelu SARIMA
# Zkusime najit optimalni model pro radu M1Germany$logm1
data("M1Germany")
head(M1Germany) # ekonomicka ctvrtletni data z Nemecka, M1 index "financni zasoby"
plot(M1Germany$logm1) # je na prvni pohled videt trend a sezonnost?
plot(decompose(M1Germany$logm1)) # trend i sezonnost se zdaji byt pritomne
# Autokorelacni a parcialni atokorelacni funkce
par(mfrow = c(2,1)); acf(M1Germany$logm1, na.action = na.pass); pacf(M1Germany$logm1, na.action = na.pass); 
par(mfrow = c(1,1)) # podle acf je dominantni trend, sezonni slozka uz mene, stacionarni rada neni, budu potrebovat diferencovat
# Bude potreba radu differencovat, ktere difference jsou idealni?
n <- length(M1Germany$logm1)
var(M1Germany$logm1, na.rm = T)*(n - 1)/n # rozptyl rady
d1 <- diff(M1Germany$logm1) # rada prvnich diferenci
plot(d1) # v rade zustala sezonnost sezonnosti
par(mfrow = c(2,1)); acf(d1, na.action = na.pass); pacf(d1, na.action = na.pass); par(mfrow = c(1,1)) # na autokorelacni funkci je sezonnost videt
n <- length(d1)
var(d1, na.rm = T)*(n - 1)/n # rozptyl rady diferenci je mensi nez rozptyl puvodni rady
d2 <- diff(M1Germany$logm1, lag = 4) # rada prvnich sezonnich diferenci (máme čtvrtletní data)
plot(d2) # rada se zda byt bez trendu i sezonnosti
par(mfrow = c(2,1)); acf(d2, na.action = na.pass); pacf(d2, na.action = na.pass)
par(mfrow = c(1,1)) # podle tvaru ACF a PACF vidime radu typu AR(1), pokud už mám stacionární řadu, tak tam mohu vidět modely
n <- length(d2); var(d2, na.rm = T)*(n - 1)/n # rozptyl rady sezonnich diferenci je nejmensi ze vsech, rada typu ARIMA(1, 0, 0)x(0, 1, 0)4 ?
# Co navrhuje auto.arima?
(fit.a <- auto.arima(M1Germany$logm1)) # autoarima vraci vyrazne slozitejsi model
  coeftest(fit.a) # jsou v nem i nevyznamne cleny
# Zkusime auto.arimu s BIC kriteriem
(fit.b <- auto.arima(M1Germany$logm1, ic = 'bic')) # vyuzitim BIC ziskavame jednodussi model, oproti nasemu puvodnimu navrhu ma navic dva MA cleny v sezonni casti
  coeftest(fit.b) # vsechny cleny jsou vyznamne
# srovnani s komplikovanejsim auto-navrhem
AIC(fit.a); BIC(fit.a)
AIC(fit.b); BIC(fit.b) # druhy navrh se zda po vsech strankach lepsi
# A co nas jednoduchy model?
(fit.nas <- Arima(M1Germany$logm1, order = c(1,0,0), seasonal = list(order = c(0,1,0)))) # podle AIC i BIC je horsi
# Idealni model fit.b
# model pro difference Zt = Yt - Yt-4, Zt = 0.85Zt-1 - 0.587et-4 - 0.221et-8
acf(residuals(fit.b), na.action = na.pass) # autokorelacni funkce pro residua
  checkresiduals(fit.b) # kompletni diagnostika residui (mame vhodny model?)
# zakresleni odhadu do dat
plot(M1Germany$logm1)
lines(fitted(fit.b), col = 2) # model dobre kopiruje data a predikce
pred.s <- forecast(fit.b, 30)
plot(pred.s) # je videt linearni trend se sezonnimi vykyvy
#############################
### Dynamicky linearni model
# jednoducha verze - trend + sezonnost
m1 <- dynlm(M1Germany$logm1 ~ trend(M1Germany$logm1) + season(M1Germany$logm1))
summary(m1) # odhady koeficientu trendu i sezonni slozky
# Muze byt toto idealni model?
# jak vypadaji residua?
plot(m1$residuals) # nemaji ani trend ani sezonnost
acf(m1$residuals) # residua jsou korelovana, je treba pridat arima model pro residua
  checkresiduals(m1)
# mohu pridat zavislost na minulych hodnotach
m2 <- dynlm(M1Germany$logm1 ~ trend(M1Germany$logm1) + season(M1Germany$logm1) + lag(M1Germany$logm1,1))
summary(m2)
# a jak jsou na tom resiudua
checkresiduals(m2)  # model vypada dobre
# kdyby nevypadal dobre, muze byt resenim pouzit funkci auto.arima s pridanymi residui
# potrebuji matici "vysvetlujicich promennych modelu m1
m1$model[1:20,]
zavisla <- m1$model[,1] # namisto puvodni rady logm1 pouzivam tu z modelu, kde jsou vynechana chybejici pozorovani, Q1 - závislá 
x.reg1 <- m1$model[,2:3] # regresory, jenze auto.arima neumi zpracovat kategoricky regresor :(, poradim si dummy promennymi, Q3 a Q4, Q1 bude referencni kategorie
x.reg2 <- cbind("trend" = x.reg1[,1],"Q2" = ifelse(x.reg1[,2] == "Q2", 1, 0), "Q3" = ifelse(x.reg1[,2] == "Q3", 1, 0),"Q4" = ifelse(x.reg1[,2] == "Q4", 1, 0))
head(x.reg2) # vytvoreni "dummy variables" do modelu
x.reg3 <- as.matrix(x.reg2) # auto.arima potrebuje regresory ve tvaru matice
# auto.arima
m3 <- auto.arima(zavisla, xreg = x.reg3)
summary(m3) # krome zavislosti ma jednom minulem pozorovani, pridava jeste zavislost na minule sezone
coeftest(m3) # vsechny cleny jsou vyznamne)
checkresiduals(m3) # pekny model
# srovnani modelu
BIC(fit.b); BIC(m1); BIC(m2); BIC(m3) #nejlepší model - nejnižsí BIC 
# kde je chyba???, optimalni model ... :))
#############################
## Samostatne
# najdete optimalni model pro radu flow z knihovny TSA
data(flow)
plot(flow) # Vidíme silnou sezónnost, ale také to, že rozptyl není konstantní
# U průtoků se téměř vždy vyplatí logaritmovat pro stabilizaci rozptylu
log.flow <- log(flow)
# Diferencování pro stacionaritu
d12 <- diff(log.flow, lag = 12) # Jelikož jde o měsíční data, zkusíme sezónní diferenci (lag = 12)
plot(d12) # Řada se zdá být stacionární
par(mfrow = c(2,1)); acf(d12, na.action = na.pass); pacf(d12, na.action = na.pass); par(mfrow = c(1,1))
(fit.a <- auto.arima(d12)) # autoarima vraci vyrazne slozitejsi model
coeftest(fit.a) # jsou v nem i nevyznamne cleny
(fit.b <- auto.arima(d12)); coeftest(fit.b) 
fit1 <- Arima(log.flow, order = c(0,0,1), seasonal = list(order = c(0,1,1)))
fit2 <- Arima(log.flow, order = c(1,0,0), seasonal = list(order = c(0,1,1))) # varianta s AR(1)
BIC(fit1); BIC(fit2) # Vybereme ten s nižším BIC
coeftest(fit2) # všechny koeficienty jsou významné
checkresiduals(fit2) # Musí projít Ljung-Box testem
# najdete optimalni model pro radu co2
plot(co2) # Jasný trend + sezónnost, Potřebujeme odstranit trend (diference 1) i sezónnost (diference 12)
d1 <- diff(co2) # odstraní trend
d1_12 <- diff(d1, 12) # odstraní sezónnost
plot(d1_12) # Teď je řada krásně vycentrovaná kolem nuly
par(mfrow = c(2,1)); acf(d1_12, na.action = na.pass); pacf(d1_12, na.action = na.pass); par(mfrow = c(1,1))
fit_co2_c <- auto.arima(co2, ic = "aic"); BIC(fit_co2_c)
fit_co2_c <- auto.arima(co2, ic = "bic"); BIC(fit_co2_c)
checkresiduals(fit_co2_c) # Residua musí být bílý šum
fit_co2_a <- Arima(co2, order = c(0,1,1), seasonal = list(order = c(0,1,1)))
fit_co2_b <- Arima(co2, order = c(1,1,1), seasonal = list(order = c(0,1,1)))
fit_co2_c <- Arima(co2, order = c(0,1,1), seasonal = list(order = c(0,1,2)))
BIC(fit_co2_c); BIC(fit_co2_b); BIC(fit_co2_a) # Vybereme ten s nejnižším BIC
m1 <- dynlm(co2 ~ trend(co2) + season(co2))
summary(m1) # odhady koeficientu trendu i sezonni slozky
checkresiduals(m1) # residua jsou korelovana, je treba pridat
m1 <- dynlm(co2 ~ trend(co2) + season(co2) + lag(co2, 1))
BIC(m1) # tento model je mnohem horší než model ARIMA, protože nezachycuje vnitřní závislosti v datech, ale pouze trend a sezónnost
summary(m1) # odhady koeficientu trendu i sezonni slozky
checkresiduals(m1)
############################
### kroskorelacni funkce 
# zavislost na ostatnich radach
par(mfrow = c(3, 1))
ccf(M1Germany$logm1, M1Germany$logprice, na.action = na.pass)
ccf(M1Germany$logm1, M1Germany$loggnp, na.action = na.pass)
ccf(M1Germany$logm1, M1Germany$interest, na.action = na.pass)
par(mfrow = c(1, 1)) # je videt vysoka korelovanost s ostatnimi radami s logprice a loggnp s nulovym zpozdenim s interest se zpozdenim 4 roky
###########################
### model zavislosti na ostatnich radach - dynamicky linearni modely
# zavislost na ostatnich promennych
m4 <- dynlm(M1Germany$logm1 ~ M1Germany$logprice + M1Germany$loggnp + M1Germany$interest) # zavislost v aktualnim case
summary(m4) # shrnuti modelu
# ale neni lepsi brat i promenne interest zavislost se zpozdenim?
m5 <- dynlm(M1Germany$logm1 ~ M1Germany$logprice + M1Germany$loggnp + L(M1Germany$interest, -4)) # zpozdeni o 4 kroky
summary(m5) # nevypada to
acf(m4$residuals) # mam korelovana residua, musim pridat jeste cast arima
# vytvoreni matice regresoru
x.reg <- as.matrix(M1Germany[,2:4])
m6 <- auto.arima(M1Germany$logm1, xreg = x.reg)
summary(m6)               
coeftest(m6) # vsechny koeficienty modelu jsou vyznamne
acf(m6$residuals, na.action = na.pass) # nekorelovana residua - dobry model
checkresiduals(m6)
# ktery model je nejlepsi?
BIC(m3); BIC(m6)