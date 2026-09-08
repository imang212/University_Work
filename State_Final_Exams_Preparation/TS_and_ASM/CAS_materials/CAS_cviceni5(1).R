#######################
### knihovny
library(forecast); library(lmtest)
#######################
### Opakovani
# Autokorelacni a parcialni autokorelacni funkce, vyzkousime pro radu nhtemp
plot(nhtemp) # prumerna rocni teplota ve stupnich Fahrenheita v New Haven z let 1912 az 1971, rada bez zasadniho trendu ci sezonnosti
# autokorelacni funkce
acf(nhtemp) # tady není vidět výrazný bod useknutí
acf(nhtemp,plot=F) # konkretni hodnoty
# parcialni autokorelacni funkce
pacf(nhtemp); pacf(nhtemp,plot=F) # vypis hodnot, tady můžu mít jenom 2 hodnoty a potom nic (proces AR(2))
# Ktere hodnoty jsou nenulove? Muzeme jednoznacne urcit model?
  # zasadni hodnoty ani u jedne funkce nejsou, hodnoty ACF klesaji pomaleji, hodnoty PACF jsou od zpozdeni 2 temer nulove
# Pokud predpokladame, ze jen PACF ma bod useknuti a to na zpozdeni k=2, mela by rada byt typu AR(2)
# Kontrola pres odhady ruznych AR a MA modelu, počítá koeficienty s odhadem + stř chybous a intercept, chybovost, věrohodnost a AIC
(fit1 <- arima(nhtemp, order = c(1,0,0))) # rada AR(1) Yt =  51.16 + 0.33Y(t-1) + E(t)
(fit2 <- arima(nhtemp, order = c(2,0,0))) # rada AR(2), koeficienty t-1 a t-2 z AR modelu
(fit3 <- arima(nhtemp, order = c(3,0,0))) # rada AR(3), moc komplikovaný
(fit4 <- arima(nhtemp, order = c(0,0,1))) # rada MA(1)
(fit5 <- arima(nhtemp, order = c(0,0,2))) # rada MA(2)
(fit6 <- arima(nhtemp, order = c(1,0,1))) # rada ARMA(1, 1), nejnižší hodnota AIC
(fit7 <- arima(nhtemp, order = c(2,0,1))) # rada ARMA(2, 1)
# podle AIC kriteria je nejvhodnejsi rada ARMA(1, 1), z vystupu dostavame odhad Y(t) = 51.17 + 0.92Y(t-1) - 0.71e(t-1) + e(t)
plot(nhtemp); lines(fitted(fit2), col = 4) # prestoze je model ze zkoumanych moznosti nejlepsi, uplne dobre data nekopiruje
fit.hw <- HoltWinters(nhtemp, gamma = F); plot(fit.hw) # ani dvojite exponencialni vyrovnani nesedi na data zcela optimalne
# A co rada LakeHuron
plot(LakeHuron) # rocni hodnoty vysky hladiny Huronskeho jezera ve stopach z let 1875-1972
# autokorelacni a parcialni autokorelacni funkce
acf(LakeHuron)
pacf(LakeHuron) # ktere korelace jsou nenulove zde? ktery model bychom odhadovali? a jak takovy model sedi na data?
# Zkusíme různé varianty
(fit_ar1 <- arima(LakeHuron, order = c(1,0,0))) # AR(1)
(fit_ar2 <- arima(LakeHuron, order = c(2,0,0))) # AR(2) - náš favorit z PACF
(fit_ma1 <- arima(LakeHuron, order = c(0,0,1))) # MA(1)
(fit_arma11 <- arima(LakeHuron, order = c(1,0,1))) # ARMA(1,1)
(fit_arma11 <- arima(LakeHuron, order = c(2,0,1))) # ARMA(2,1) - nejlepší
(fit_arma11 <- arima(LakeHuron, order = c(2,0,2))) # ARMA(2,2)
########################
## Hledani modelu ARMA
# rada presidents
plot(presidents) # ctvrtletni hodnoceni americkych prezidentu, rada bez zjevneho trendu, budu na ni hledat model ARMA
# autokorelacni a parcialni autokorelacni funkce
par(mfrow = c(2,1)); acf(presidents, na.action = na.pass); pacf(presidents, na.action = na.pass); par(mfrow = c(1,1))
  # autokorelacni funkce nema bod useknuti, parcialni autokorelacni funkce ho ma, k0 = 1, optimalni model by mel byt AR(1)
# odhadnu vice jednoduchych modelu
(fit1 <- arima(presidents, order = c(1,0,0))) # AR(1)
(fit2 <- arima(presidents, order = c(2,0,0))) # AR(2)
(fit3 <- arima(presidents, order = c(0,0,1))) # MA(1)
(fit4 <- arima(presidents, order = c(1,0,1))) # ARMA(1,1)
# ke kazdemu modelu vidim Akaikeho informacni kriterium, podle nej by mel byt nejlepsi model AR(1) : aic = 839.78
# Bayesovske informacni kriterium - pro vyber optimalniho modelu je lepsi
BIC(fit1); BIC(fit2); BIC(fit3); BIC(fit4) # i timto kriteriem vyberu model AR(1)
# v knihovne forecast existuje i funkce, ktera hleda idealni model automaticky
(fit.a <- auto.arima(presidents, seasonal = F)) # vybira optimalni model se slozitosti az do radu ARMA(5,5), optimalni model vybira podle Akaikeho kriteria
BIC(fit.a) # na zaklade BIC kriteria bych radeji volila jednodussi model AR(1)
  (fit.b <- auto.arima(presidents, seasonal = F, ic = "bic")) # mohu BIC nastavit i primo do funkce auto.arima
# vykresleni obou modelu proti sobe
plot(presidents); lines(fitted(fit1), col = 2); lines(fitted(fit.a), col = 3) # rozdil neni prilis velky - zelena krivka je hladsi
# Odhadnute modely
#   AR(1): Y(t) = 56.15 + 0.82Y(t-1)
#   ARMA(3,2): Y(t) = 56.07 - 0.5Y(t-1) + 0.36Y(t-2) + 0.62Y(t-3) + 1.35e(t-1) + 0.92e(t-2)
### Dalsi kriteria pro urceni idealniho modelu:
  # hodnoty parametru by mely byt alespon 2x vetsi nez jejich stredni chyba, tj. mely by byt vyznamne, autokorelacni funkce residui modelu by mely byt male
# AR(1) model
coeftest(fit1) # vyznamnost vypoctenych koeficientu
par(mfrow = c(2,1)); acf(residuals(fit1), na.action = na.pass); pacf(residuals(fit1), na.action = na.pass); par(mfrow = c(1,1)) # minimalni zbyla autoregrese
# ARMA(3,2) model
coeftest(fit.a) # vyznamnost vypoctenych koeficientu
par(mfrow = c(2,1)); acf(residuals(fit.a), na.action = na.pass); pacf(residuals(fit.a), na.action = na.pass); par(mfrow = c(1,1)) # nulova autokorelace
## test na nulovost autokorelacni funkce, nulovost autokorelacni funkce residui znamena, ze mame spravny model
Box.test(residuals(fit1), lag=5, type = "Ljung-Box")
Box.test(residuals(fit.a), lag=5, type = "Ljung-Box")
  # u ARMA(3,2) modelu vychazi autokorelacni funkce primo nulova, u modelu AR(1) je mirna odchylka
# Jaky model tedy vybrat? - subjektivni rozhodnuti :)
#############################
### Samostatne
# hledejte optimalni model pro rady 
#	  airquality$Wind, discoveries, treering, lh
plot(airquality$Wind)
par(mfrow = c(2,1)); acf(airquality$Wind, na.action = na.pass); pacf(airquality$Wind, na.action = na.pass); par(mfrow = c(1,1))
(fit.a <- auto.arima(airquality$wind, seasonal = F)) # vybira optimalni model se slozitosti az do radu ARMA(5,5), optimalni model vybira podle Akaikeho kriteria
BIC(fit.a)   # na zaklade BIC kriteria bych radeji volila jednodussi model AR(1)
(fit.b <- auto.arima(airquality$wind, seasonal = F, ic = "bic")) # mohu BIC nastavit i primo do funkce auto.arima
plot(airquality$Wind)
lines(fitted(fit.a),col=2) 
fit_auto_wind <- auto.arima(airquality$Wind, seasonal = FALSE)
summary(fit_auto_wind)
Box.test(residuals(fit_auto_wind), lag=10, type="Ljung-Box")
#discoveries
plot(discoveries)
par(mfrow = c(2,1)); acf(discoveries, na.action = na.pass); pacf(discoveries, na.action = na.pass); par(mfrow = c(1,1))
(fit.a <- auto.arima(discoveries, seasonal = F)) 
BIC(fit.a)  
(fit.b <- auto.arima(discoveries, seasonal = F, ic = "bic")) 
plot(discoveries)
lines(fitted(fit.a),col=2) 
fit_auto_disc <- auto.arima(discoveries, seasonal = FALSE)
summary(fit_auto_disc)
Box.test(residuals(fit_auto_disc), lag=10, type="Ljung-Box")
#treeing
plot(treering)
par(mfrow = c(2,1)); acf(treering, na.action = na.pass); pacf(treering, na.action = na.pass); par(mfrow = c(1,1))
(fit.a <- auto.arima(treering, seasonal = F)) 
BIC(fit.a)  
(fit.b <- auto.arima(treering, seasonal = F, ic = "bic")) 
plot(treering)
lines(fitted(fit.a),col=2) 
fit_auto_tree <- auto.arima(treering, seasonal = FALSE)
summary(fit_auto_tree)
Box.test(residuals(fit_auto_tree), lag=10, type="Ljung-Box")
#lh
plot(lh)
par(mfrow = c(2,1)); acf(lh, na.action = na.pass); pacf(lh, na.action = na.pass); par(mfrow = c(1,1))
(fit.a <- auto.arima(lh, seasonal = F)); BIC(fit.a)  
(fit.b <- auto.arima(lh, seasonal = F, ic = "bic")) 
plot(lh)
lines(fitted(fit.a),col=2) 
fit_auto_lh <- auto.arima(lh, seasonal = FALSE)
summary(fit_auto_lh)
Box.test(residuals(fit_auto_lh), lag=10, type="Ljung-Box")

plot(woolyrnq)
acf(treering)
