library(TSA); library(forecast); library(lmtest)
############################
## Najdete optimalni ARMA model pro radu bluebird - price
data(bluebird)
plot(bluebird[,2]) # tydenni data o cenach "Bluebird standard potato chip" (je stacionární)
# pomoci autokorelacni a parcialni autokorelacni funkce odhadnete rad modelu
# odhadnete konkretni model, jimz se rada ridi
# jsou vysledna residua nekorelovana?
par(mfrow = c(2,1)); acf(bluebird[,2], na.action = na.pass); pacf(bluebird[,2], na.action = na.pass); par(mfrow = c(1,1)) # autokorelacni a parcialni autokorelacni funkce
(fit1 <- Arima(bluebird[,2], order = c(0,0,1))) # vyzkousejte ruzne modely, toto je MA(1)
(fit1 <- Arima(bluebird[,2], order = c(0,0,2))) # vyzkousejte ruzne modely, toto je MA(1)
(fit1 <- Arima(bluebird[,2], order = c(2,0,0))) # ARMA(1,6)
(fit1 <- Arima(bluebird[,2], order = c(1,0,1))) # ARMA(1,6)
(fit1 <- Arima(bluebird[,2], order = c(1,0,0))) # ARMA(1,6)
AIC(fit1) # Akaikeho informacni kritarium
BIC(fit1) # Bayesovske informacni kriterium
# Ktery model je nejlepsi?
Box.test(residuals(fit1), lag=5, type = "Ljung-Box") # test o nulove autokorelaci
(fit.a <- auto.arima(bluebird[,2], seasonal = F)) # automaticky hledani modelu
###########################
### Hledani modelu arima
# pro radu Nile, lynx
plot(Nile) # Flow of the River Nile rada, ktera alespon v uvodu stacionarni neni
par(mfrow = c(2,1)); acf(Nile, na.action = na.pass); pacf(Nile, na.action = na.pass); par(mfrow = c(1,1)) # autokorelacni funkce klesa moc pomalu
acf(Nile, na.action = na.pass, type = "covariance", plot = F) # prvni z uvedenych hodnot je rozptyl rady
  n <- length(Nile)
  var(Nile)*(n - 1)/n

d1 <- diff(Nile) # rada prvnich diferenci
plot(d1)
par(mfrow = c(2,1)); acf(d1, na.action = na.pass); pacf(d1, na.action = na.pass); # druha rada mi rika ze bychom se meli podivat na acf a pacf pro radu diferenci 
par(mfrow = c(1,1)) # rada se jevi jako stacionarni pro radu diferenci se jevi jako optimalni model MA(1)
acf(d1, na.action = na.pass, type = "covariance", plot = F) # rozptyl se zmensil
d2 <- diff(Nile, differences = 2) # rada druhych diferenci
plot(d2)
par(mfrow = c(2,1)); acf(d2, na.action = na.pass); pacf(d2, na.action = na.pass); par(mfrow = c(1,1))
acf(d2, na.action = na.pass, type = "covariance", plot = F) # rozptyl se zvetsil - druha diference uz je spatna x

(fit1 <- Arima(Nile, order = c(1,1,0))) # ARIMA(1,1,0), uprostřed 1, protože pracuji s 1. diferencí, pro co nejpřesnější model použijeme AIC
(fit2 <- Arima(Nile, order = c(0,1,1))) # ARIMA(0,1,1)
(fit3 <- Arima(Nile, order = c(0,1,2))) # ARIMA(0,1,2) 
(fit4 <- Arima(Nile, order = c(0,1,3))) # ARIMA(0,1,3)
(fit5 <- Arima(Nile, order = c(1,1,1))) # ARIMA(1,1,1) - nejlepší model
(fit6 <- Arima(Nile, order = c(1,1,2))) # ARIMA(1,1,2)
# podle AIC kriteria je optimalni rada ARIMA(1,1,1)
BIC(fit2) # podle BIC kriteria je optimalni rada ARIMA(0,1,1)
BIC(fit3); BIC(fit4); BIC(fit5); BIC(fit6)
(fit.a <- auto.arima(Nile)) # automaticky se voli na zaklade AIC kriteria
# predpovedi pro model ARIMA(1,1,1)
(for.fit5 <- forecast(fit5)) # predpoved s intervalem spolehlivosti
predict(fit5, 10) # predpoved bez intervalu spolehlivosti pouze se stredni chybou
plot(for.fit5) # zakresneni predpovedi do grafu
# simulace budoucich hodnot
s <- matrix(0, 10, 10)
(s[1,] <- simulate(fit5, nsim = 10, future = T)) # simulovane pokracovani rady
plot(Nile, xlim=c(1871,1980), ylim=c(100,1700))
lines(1971:1980, s[1,], col=3) # zakresleni simulovane rady do grafu
for(i in 2:10){
  s[i,] <- simulate(fit5, nsim = 10, future = T)
  lines(1971:1980, s[i,], col = 3)
} # pripocitani a prikresleni dalsich moznych deviti pruchodu
############################
### Hledani modelu SARIMA
# Zkusime najit optimalni model pro rady nottem, UKDriverDeaths
plot(nottem) # Average Monthly Temperatures at Nottingham, 1920–1939 evidentne sezonni rada
par(mfrow = c(2,1)); acf(nottem, na.action = na.pass); pacf(nottem, na.action = na.pass); par(mfrow = c(1,1)) # sezonnost je videt v autokorelacni funkci
d1 <- diff(nottem, lag = 12)
# rada prvnich sezonnich diferenci
plot(d1)
par(mfrow = c(2,1)); acf(d1, na.action = na.pass); pacf(d1, na.action = na.pass); par(mfrow = c(1,1)) # autokorelacni i parcialni autokorelacni funkce stale ukazuji vysoke hodnoty na delce sezony, ale jinde jiz ne
  # jevi se jako MA(1) model na sezonnich datech
acf(d1, na.action = na.pass, type = "covariance", plot = F) # rozptyl se zmensil
fit1 <- Arima(nottem, order = c(1,0,0), seasonal = list(order = c(0,1,0)))
fit2 <- Arima(nottem, order = c(0,0,1), seasonal = list(order = c(0,1,0)))
fit3 <- Arima(nottem, order = c(1,0,1), seasonal = list(order = c(0,1,0)))
fit4 <- Arima(nottem, order = c(0,0,0), seasonal = list(order = c(1,1,0)))
fit5 <- Arima(nottem, order = c(0,0,0), seasonal = list(order = c(0,1,1)))
fit6 <- Arima(nottem, order = c(0,0,0), seasonal = list(order = c(1,1,1)))
(fit7 <- Arima(nottem, order = c(1,0,0), seasonal = list(order = c(1,1,1)))) #(1. sezonní dif)  Zt = Zt -Zt-12, Zt = 0.27*Zt-1-0.32t-12-0.73eta_t-12+eta_t
BIC(fit1); BIC(fit2); BIC(fit3); BIC(fit4); BIC(fit5); BIC(fit6); BIC(fit7) # jako optimalni se jevi posledni model, SARIMA(1,0,0)x(1,1,1)[12]
par(mfrow = c(2,1)); acf(residuals(fit7), na.action = na.pass); pacf(residuals(fit7), na.action = na.pass); par(mfrow = c(1,1)) # významné hodnoty tam nejsou
(fit.a <- auto.arima(nottem)) # automaticky model rozhodne optimalni neni - je prilis komplikovany, je tam u některých odhad vyšší než střední chyba 
BIC(fit.a) # automaticky model rozhodne optimalni neni - je prilis komplikovany
coeftest(fit.a) # model ma spoustu nevyznamnych clenu
(fit.b <- auto.arima(nottem, ic = "bic")) # pomoci Bayesovskeho kriteria vybran jednodussi model
coeftest(fit.b) # pomoci Bayesovskeho kriteria vybran jednodussi model
# autokorelacni a parcialni autokorelacni funkce optimalniho modelu
par(mfrow = c(2,1)); acf(residuals(fit.b), na.action = na.pass); pacf(residuals(fit.b), na.action = na.pass); par(mfrow = c(1,1)) # zavislosti jiz v datech nejsou
#############################
### najdete optimalni model a spocitejte 15 predpovedi pro radu lynx
plot(lynx) # Počet koček rysů ulovených v Kanadě, silná cykličnost
par(mfrow = c(2,1)); acf(lynx, na.action = na.pass); pacf(lynx, na.action = na.pass); par(mfrow = c(1,1)) # zavislosti jiz v datech nejsou
### najdete optimalni model pro radu BJsales, UKDriverDeaths, CREF, electricity, flow
plot(BJsales) # Evidentní trend, řada není stacionární
plot(diff(BJsales))
d1_bj <- diff(BJsales)
plot(d1_bj) # Po 1. diferenci vypadá stacionárně
par(mfrow = c(2,1)); acf(d1_bj); pacf(d1_bj); par(mfrow = c(1,1))
# ACF diferencí utne po 1. lagu -> MA(1). PACF klesá postupně.
(fit_bj <- Arima(BJsales, order = c(0,1,1))) # Proč tento? Protože BJsales se chová jako "náhodná procházka" s krátkou pamětí v chybách. ARIMA(0,1,1) je nejúspornější.
(fit_bj <- Arima(BJsales, order = c(1,1,1)))

plot(UKDriverDeaths) # Sezónnost (12) + klesající trend, Musíme udělat sezónní diferenci (D=1) i běžnou (d=1)
d1_12_uk <- diff(diff(UKDriverDeaths, 12), 1)
par(mfrow = c(2,1)); acf(d1_12_uk); pacf(d1_12_uk); par(mfrow = c(1,1))
# Často vyjde tzv. "letecký model" (Airline model):
(fit_a <- auto.arima(UKDriverDeaths)) # automaticky hledani modelu
(fit_uk <- Arima(UKDriverDeaths, order = c(0,1,1), seasonal = list(order = c(0,1,1))))
# Proč tento? Sezónní MA(1) složka (lag 12 v ACF) čistí sezónní vlivy, běžná MA(1) čistí zbytek po trendu.
data(cref)
plot(cref) # Vypadá stacionárně, ale má silné vnitřní vazby
par(mfrow = c(2,1)); acf(cref); pacf(cref); par(mfrow = c(1,1))
# PACF má hroty na 1. a 2. lagu -> AR(2).
(fit_cref <- Arima(cref, order = c(2,0,0)))
# Proč tento? Ceny/výnosy fondu mají setrvačnost. Včerejší a předvčerejší hodnota přímo ovlivňují tu dnešní.
# Příklad pro řadu elektřiny (např. z balíku fpp2), Pokud se výkyvy zvětšují, musíme nejdřív LOGARITMOVAT!
log_elect <- log(electricity)
plot(log_elect) # Teď už jsou výkyvy stabilní
# Poté hledáme model na zlogaritmovaných datech:
fit_elect <- auto.arima(log_elect, seasonal = TRUE, ic = "bic")
# Proč logaritmus? Bez něj by model ARIMA nedokázal odhadnout tu měnící se šířku sezónních výkyvů.
# data(flow) - pokud pracujeme s průtoky
plot(flow)
# Většinou vykazuje silnou persistenci, ale po 1. diferenci je to bílý šum.
d1_flow <- diff(flow)
acf(d1_flow) # Často zde zbyde jen MA(1) složka
(fit_flow <- Arima(flow, order = c(0,1,1))) # Proč tento? Průtoky mají "hladkou" setrvačnost. ARIMA(0,1,1) funguje jako klouzavý průměr, který tyhle změny dobře kopíruje.
### predikce pro kombinovanou radu
preds_lynx <- forecast(fit_lynx, h = 15); plot(preds_lynx, main = "Předpověď ulovených rysů na 15 let")
# pracujte s daty airquality (nejsou zadany jako casove rady, je treba je transformovat)
# vytvorte novou promennou, ktera bude pocitana jako Temp-0.2*Wind
# predpovidejte nove hodnoty (10 hodnot) temp.ad z dat temp a wind vcetne intervalu spolehlivosti
data("airquality")
# predpovedi je mozne pocitat, jako predpovedi pro kazdou radu zvlast 
#   a vysledek zkombinovat dle daneho vzorce
# kombinovany interval spolehlivosti nebude fungovat
# pro interval spolehlivosti je nutne nasimulovat velke mnozstvi budoucich pruchodu obou rad
#   zkombinovat je dle daneho vzorce 
#   a interval spolehlivosti vzit jako pozadovane kvantily ze simulovanych dat
# kvantily z matice s, kde bude 10000 radku se simulovanymi pruchody rady
quantile(s[,1], c(0.05,0.95))
  # meze 90%-ni interval spolehlivosti v prvnim kroku
# pro kazdou radu tedy najdete optimalni model, simulujte budouci pruchody,
#   zkombinujte je a najdete kvantily intervalu spolehlivosti