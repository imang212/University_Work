############################
library(forecast); library(dynlm); library(lmtest) # nacteni knihoven
############################
### dynamicke linearni modely - jak modelovat zavislost mezi casovymi radami
## priklad pro umela data 
# generovani dat
set.seed(999)
x_series <- arima.sim(n = 200, list(order = c(1,0,0), ar = 0.7, sd=1)) # nasimulovany AR(1) proces
z <- ts.intersect(lag(x_series, 0), lag(x_series, -1))  # hodnoty rady x_series v case t a t-1
y_series <- 15 + 0.8*z[,1] + 1.5*z[,2] + rnorm(199,0,1) # kombinace aktualni a zpozdene hodnoty + nahodne chyby
xy_series <- ts.intersect(y_series, z) # datovy soubor s jednou zavislou a dvema znezavislymi promennymi
# jak vypada kroskorelacni funkce?
ccf(x_series, y_series) # nejvetsi zavislost o 1 krok dozadu
# model pomoci bezne linearni regrese
lm1 <- lm(xy_series[,1] ~ xy_series[,2] + xy_series[,3]); summary(lm1) # popis modelu
checkresiduals(lm1) # popis residui modelu, abychom mohli pouzit klasicky linearni model, musi byt residua normalni, s konstantnim rozptylem a NEKORELOVANA
  # nekorelovanosti residui se tyka i vypsany test (Breusch-Godfrey) je-li p-hodnota > alfa 0.05, pak residua jsou nekorelovana az do radu 10
# model pomoci dynamickeho modelovani
dlm1 <- dynlm(y_series ~ L(x_series, 0) + L(x_series, 1)); summary(dlm1) # stejny vysledek
### Jak pracovat s korelovanymi residui 
# generovani dat
set.seed(999)
x2_series <- arima.sim(n = 200, list(order = c(1,0,0), ar = 0.7, sd=1))
z2 <- ts.intersect(x2_series, lag(x2_series, -3), lag(x2_series, -4)) 
y2_series <- 15 + 0.8*z2[,2] + 1.5*z2[,3] 
y2_errors <- arima.sim(n = 196, list(order = c(1,0,1), ar = 0.6, ma = 0.6), sd=1)
y2_series <- y2_series + y2_errors
plot(y2_series) # zavisle promenna - casova rada
# chceme modelovat zavislost y2 na x2, nejprve hledame, zda je zavislost v case t nebo se zpozdenim
ccf(x2_series, y2_series)
(mc <- which.max(ccf(x2_series, y2_series, plot = F)$acf)) # maximalni korelace na 24 pozici
ccf(x2_series, y2_series, plot=F)$lag[mc] # se zpozdenim 4 kroku
# dynamicky model
dlm1 <- dynlm(y2_series ~ L(x2_series, 4))
summary(dlm1) # zavislost je prukazna, je to cela zavislost nebo jeste neco v datech zbylo?
ccf(x2_series, dlm1$residuals)
dlm2 <- dynlm(y2_series ~ L(x2_series, 3) + L(x2_series, 4))
summary(dlm2) # prukazna zavislost o 3 i 4 kroky zpet
ccf(x2_series, dlm2$residuals) # nyni uz v datech zadna zavislost neni
# vyznamnost koeficientu
lm2d <- ts.intersect(y2_series, dlm2$fitted.values)
plot.ts(lm2d, plot.type = "single", col=c("black","red"), lty=c(1,1), lwd=c(1,1), main = "'Classic' Linear Model - Original (black) and Fitted series (red)") 
  # jak model sedi na data
# kontrola residui
checkresiduals(dlm2) # autokorelovana residua
dlm3 <- dynlm(y2_series ~ L(x2_series, 3) + L(x2_series, 4)+ L(y2_series, -1))
summary(dlm3) # prukazna zavislost o 3 i 4 kroky zpet
checkresiduals(dlm3) # nekorelovana residua, dobry model
# do modelu pridame autokorelovana residua
x2Lagged <- cbind(xLag0 = x2_series, xLag3 = lag(x2_series, -3), xLag4 = lag(x2_series, -4))
xy2_series <- ts.union(y2_series, x2Lagged) # matice se zavisle promennou a posunutymi nezavisle promennymi
# do prikazu auto.arima muzeme pridat i matici regresoru
arima1 <- auto.arima(xy2_series[,1], xreg = xy2_series[,3:4]); arima1
# jak vypadaji residua tohoto modelu
checkresiduals(arima1) # ok
# zakresleni modelu do dat
arima1d <- ts.intersect(na.omit(xy2_series[,1]), arima1$fitted)
plot.ts(arima1d, plot.type = "single", col=c("black","red"), lty=c(1,1), lwd=c(1,1), main = "ARIMA errors model - Original (black) and Fitted series (red)") 
# vyznamnost koeficientu ARIMA modelu
coeftest(arima1)
########################
### Samostatne 
# hledejte optimalni model pro radu ozonu v datech airquality v zavislosti na ostatnich promennych
data("airquality")
par(mfrow = c(2, 2)); plot(ts(airquality$Wind)); plot(ts(airquality$Solar.R)); plot(ts(airquality$Temp)); plot(ts(airquality$Ozone)); par(mfrow = c(1, 1))
aq <- na.omit(airquality)
ozon <- ts(aq$Ozone)
plot(ozon, main = "Ozone levels in New York", ylab = "Ozone (ppb)", xlab = "Day")
par(mfrow = c(2, 2)); acf(aq$Ozone, na.action = na.pass); ccf(aq$Solar.R, aq$Ozone, na.action = na.pass); ccf(aq$Temp, aq$Ozone, na.action = na.pass); ccf(aq$Wind, aq$Ozone, na.action = na.pass); par(mfrow = c(1, 1))
mod1 <- lm(Ozone ~ Temp + Wind + Solar.R, data = na.omit(airquality)); summary(mod1)
checkresiduals(mod1)
par(mfrow = c(2, 2)); plot(mod1); par(mfrow = c(1, 1))
mod2 <- lm(Ozone ~  Solar.R + poly(Temp, 2) + poly(Wind, 2), data = na.omit(airquality)); summary(mod2)
checkresiduals(mod2)
par(mfrow = c(2, 2)); plot(mod2); par(mfrow = c(1, 1))
mod3 <- lm(log(Ozone) ~ Solar.R + Wind + Temp, data = na.omit(airquality)); summary(mod3)
checkresiduals(mod3)
plot(log(airquality$Ozone) ~ airquality$Temp)
plot(log(airquality$Ozone) ~ airquality$Wind)
plot(log(airquality$Ozone) ~ airquality$Solar.R)
m_ozon <- dynlm(ts(Ozone) ~ ts(Temp) + ts(Wind) + ts(Solar.R), data = ts(na.omit(airquality)))
summary(m_ozon)
checkresiduals(m_ozon)
auto.arima(na.omit(airquality)$Ozone, xreg = ts(na.omit(airquality)[,c(3,4,5)]))
########################
data("M1Germany")
head(M1Germany) # ekonomicka ctvrtletni data z Nemecka, M1 index "financni zasoby"
plot(M1Germany$logm1) # casova rada s trendem a sezonnosti, jak pro ni najit optimalni model?
# autokorelacni funkce
par(mfrow = c(2, 1)); acf(M1Germany$logm1, na.action = na.pass); pacf(M1Germany$logm1, na.action = na.pass); par(mfrow = c(1, 1)) # je videt vysoka autokorelovanost (diky trendu)
# zavislost na ostatnich raddach
par(mfrow = c(3, 1)); ccf(M1Germany$logprice, M1Germany$logm1, na.action = na.pass); ccf(M1Germany$loggnp, M1Germany$logm1, na.action = na.pass)
ccf(M1Germany$interest, M1Germany$logm1, na.action = na.pass)
par(mfrow = c(1, 1)) # je videt vysoka korelovanost s ostatnimi radami s logprice a loggnp s nulovym zpozdenim s interest se zpozdenim 4 roky
# model pro radu jako takovou - z minula
plot(decompose(M1Germany$logm1))
m1 <- dynlm(M1Germany$logm1 ~ trend(M1Germany$logm1) + season(M1Germany$logm1))
summary(m1) # odhady koeficientu trendu i sezonni slozky
checkresiduals(m1) # residua jsou korelovana, je treba pridat jeste cast arima
# potrebuji matici "vysvetlujicich promennych tohoto modelu
zavisla <- m1$model[,1]
x.reg1 <- m1$model[,2:3]
x.reg2 <- cbind("trend" = x.reg1[,1],"Q2" = ifelse(x.reg1[,2] == "Q2", 1, 0), "Q3" = ifelse(x.reg1[,2] == "Q3", 1, 0),"Q4" = ifelse(x.reg1[,2] == "Q4", 1, 0))
x.reg3 <- as.matrix(x.reg2) # auto.arima potrebuje regresory ve tvaru matice
m2 <- auto.arima(zavisla, xreg = x.reg3)
summary(m2) # vysledny model
checkresiduals(m2)
###########################
# ještě jednou se podivame na zavislost na ostatnich radach, jestli tam jeste neco nezbyld
# zavislost na ostatnich promennych
m3 <- dynlm(M1Germany$logm1 ~ M1Germany$logprice + M1Germany$loggnp + M1Germany$interest) # zavislost v aktualnim case
summary(m3) # shrnuti modelu
# ale neni lepsi brat i promenne interest zavislost se zpozdenim?
m4 <- dynlm(M1Germany$logm1 ~ M1Germany$logprice + M1Germany$loggnp + L(M1Germany$interest, -4)) # zpozdeni o 4 kroky
summary(m4) # nevypada to
checkresiduals(m4) 
acf(m3$residuals) # mam korelovana residua, musim pridat jeste cast arima
# vytvoreni matice regresoru
x.reg <- as.matrix(M1Germany[,2:4])
m5 <- auto.arima(M1Germany$logm1, xreg = x.reg)
summary(m5)               
coeftest(m5) # vsechny koeficienty modelu jsou vyznamne
acf(m5$residuals, na.action = na.pass) # nekorelovana residua - dobry model
checkresiduals(m5)
# auto arima
m6 <- auto.arima(M1Germany$logm1); summary(m6)
acf(m6$residuals, na.action = na.pass) # nekorelovana residua - dobry model
m6 <- auto.arima(M1Germany$logm1, ic = "bic"); summary(m6)
acf(m6$residuals, na.action = na.pass) # tento model je lepší 
# ktery model je nejlepsi?
BIC(m1); BIC(m2); BIC(m3); BIC(m5); BIC(m6) # m2 a m5 jsou srovnatelne
plot(M1Germany$logm1); lines(m2$fitted, col = 2); lines(m5$fitted, col = 3) # oba modely sedi dobre
# predpovedi
# mohu pocitat jen pro model m2, pro model m5 nemam hodnoty regresoru
newd1 <- data.frame("trend" = seq(36.25, 38, by = 0.25), "Q2" = c(0,1,0,0,0,1,0,0), "Q3" = c(0,0,1,0,0,0,1,0), "Q4" = c(0,0,0,1,0,0,0,1))
newd2 <- as.matrix(newd1)
f2 <- forecast(m2, xreg = newd2); plot(f2); f2 # vykresleni a vypsani predpovedi s intervaly spolehlivosti
#############################
### Samostatne
# pouzijte databazi EuStockMarkets a zkuste najit optimalni model pro index DAX, databaze burzovnich indexu
plot(EuStockMarkets[,1])
dax <- EuStockMarkets[, 1]
par(mfrow = c(3, 1)); ccf(EuStockMarkets[,2], dax, main = "DAX vs SMI (Švýcarsko)"); ccf(EuStockMarkets[,3], dax, main = "DAX vs CAC (Francie)")
ccf(EuStockMarkets[,4], dax, main = "DAX vs FTSE (Británie)"); par(mfrow = c(1, 1)) # obrovské korelace v čase 0
m1 <- dynlm(dax ~ EuStockMarkets[,2] + EuStockMarkets[,3] + EuStockMarkets[,4]) # zavislost v aktualnim case
summary(m1) # shrnuti modelu
checkresiduals(m1) # nekorelovana residua, dobry model
# sezonnost si vyzkousejte na rade
plot(UKgas)
# nactete data EMG a hledejte optimalni model pro radu iEMG