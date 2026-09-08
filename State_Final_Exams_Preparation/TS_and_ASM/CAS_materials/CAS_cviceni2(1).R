############################
### nacteni knihoven, ktere pracuji s casovymi radami
library(TTR); library(zoo); library(forecast) # dalsi uzitecne funkce obsazene primo v knihovne stats
############################
### Vyhlazeni casovych rad, Vyhlazeni pomoci klouzavych prumeru 
kings <- scan("http://robjhyndman.com/tsdldata/misc/kings.dat",skip=3) # veky, ve kterych zemreli anglicti kralove
kings.ts <- ts(kings)
plot(kings.ts) # trendova slozka bez sezonnosti
# klouzave prumery prvniho radu ruzne delky
kings.rm3 <- rollmean(kings.ts, 3); kings.rm5 <- rollmean(kings.ts, 5); kings.rm7 <- rollmean(kings.ts, 7); kings.rm9 <- rollmean(kings.ts, 9); kings.rm11 <- rollmean(kings.ts, 11)
  # pro krajni body odhady nejsou
plot(kings.ts)
lines(kings.rm3, col = 2); lines(kings.rm5, col = 3); lines(kings.rm7, col = 4); lines(kings.rm9, col = 5); lines(kings.rm11, col = 6)
legend(34, 40, legend=c("puvodni rada", "KP delky 3", "KP delky 5", "KP delky 7", "KP delky 9", "KP delky 11"), lty=1, col=1:6, cex=0.8)
  # podivame se na vysledky a podle toho, jak detailni vyhlazeni chceme, volime delku klouzaveho prumeru
  # neni dobre, kdyz vyhlazena rada vykazuje opacne vykyvy nez rada puvodni to znaci male vyhlazeni
# klouzave prumery tretiho radu
vahy <- (1/35)*c(-3, 12, 17, 12, -3)
kings.rm3.5 <- rollapply(kings.ts, 5, function(z){return(weighted_mean = weighted.mean(z, vahy))})
vahy <- (1/231)*c(-21, 14, 39, 54, 59, 54, 39, 14, -21)
kings.rm3.9 <- rollapply(kings.ts, 9, function(z){return(weighted_mean = weighted.mean(z, vahy))})
plot(kings.ts)
lines(kings.rm3.5, col = 2)
lines(kings.rm3.9, col = 3) # mame lepsi vysledky nez obycejnymi klouzavymi prumery?
###################################
### funkcne zapsatelny trend
# pokud jsme tvar trendu schopni odhadnout z dat, je mozne pocitat primo model zavislosti na case
cas <- 1:42
lin.trend <- lm(kings ~ cas)
kv.trend <- lm(kings ~ cas + I(cas^2))
kub.trend <- lm(kings ~ cas + I(cas^2) + I(cas^3))
plot(kings.ts)
abline(lin.trend, col = 2)
lines(cas,fitted(kv.trend), col = 3)
lines(cas,fitted(kub.trend), col = 4)
legend(34, 40, legend=c("puvodni rada", "linearni trend", "kvadraticky trend", "kubicky trend"), lty=1, col=1:4, cex=0.7)
# porovnani, ktery trend je lepsi
summary(lin.trend)$r.squared; summary(kv.trend)$r.squared; summary(kub.trend)$r.squared # procento variability vysvetlene modelem
AIC(lin.trend); AIC(kv.trend); AIC(kub.trend) # Akaikeho informacni kriterium - cim mensi tim lepsi, idealni trend je kubicky
BIC(lin.trend); BIC(kv.trend); BIC(kub.trend) # Bayesovske informacni kriterium - cim mensi tim lepsi, idealni model se jevi kvadraticky
#############################
### Vyhlazeni pomoci exponencialniho vyrovnani
## Jednoduche exponencialni vyhlazovani - vhodne pro lokalne konstantni trend
rain <- scan("http://robjhyndman.com/tsdldata/hurst/precip1.dat",skip=1) # rocni srazky v Londyne merene v palcich z let 1813 az 1912
rain.ts <- ts(rain, start = c(1813))
plot(rain.ts) # aditivni rada s konstantnim trendem
rain.exp <- HoltWinters(rain.ts, beta = FALSE, gamma = FALSE) # jednoduche exponencialni vyrovnani
plot(rain.exp) # vykresli data i s odhadnutym trendem
rain.exp$fitted # predpovedi, neboli hodnoty trendu
rain.exp$SSE # sum of squared errors - soucet druhych mocnin chyb odhadu
rain.exp # odhadnuta hodnota parametru alpha
# cim mensi alpha, tim vetsi vyhlazeni
rain.exp2 <- HoltWinters(rain.ts, alpha = 0.01, beta = FALSE, gamma = FALSE)
plot(rain.exp2)
# cim vetsi alpha, tim mensi vyhlazeni
rain.exp2 <- HoltWinters(rain.ts, alpha = 0.05, beta = FALSE, gamma = FALSE)
plot(rain.exp2)
# pri exponencialnim vyhlazovani se bezne bere jako pocatek trendu prvni merena hodnota, pokud chceme trend zacit v jine hodnote, je mozne vyuzit parametr l.start
plot(HoltWinters(rain.ts, beta = FALSE, gamma = FALSE, l.start = 25)) # jak vypada odhad trendu zacinajiciho na hodnote 25
## Predpovedi z exponencialniho vyhlazovani
rain.exp.for <- forecast(rain.exp, h = 10) # vypocte 10 predpovedi na budouci uhrny srazek
plot(rain.exp.for)
lines(1814:1912, rain.exp$fitted[,1], col = 3) # zakresleni predpovedi do grafu, modra cara je bodova predpoved, tmave seda plocha 80% interval spolehlivosti
  # a svetle seda plocha 95% interval spolehlivosti
## Dvojite exponencialni vyhlazovani - pri lokalne linearnim trendu
skirts <- scan("http://robjhyndman.com/tsdldata/roberts/skirts.dat",skip=5)	# rocni data o prumeru lemu sukni z let 1866 az 1911
skirts.ts <- ts(skirts, start = c(1866))
plot(skirts.ts) # je videt nejprve rostouci a pak klesajici trend bez sezonni slozky s minimalni chybou
skirts.exp <- HoltWinters(skirts.ts, gamma = FALSE) # Holtova metoda - zobecnene dvojite exponencialni vyrovnani
skirts.exp # odhadnute hodnoty parametru alfa a beta nam rikaji, ze odhady jsou zalozene predevsim na nedavnych hodnotach (zavislost nejde daleko do minulosti)
plot(skirts.exp) # vykresleni odhadnuteho trendu
skirts.exp$SSE # Soucet druhych mocnin chyb odhadu

skirts.exp2 <- HoltWinters(skirts.ts, alpha = 0.5, gamma = FALSE) # vyhlazeni trendu dosahnu predevsim zmenou parametru alpha
plot(skirts.exp2)
## Predpovedi z Holtova vyhlazovani
skirts.exp.for <- forecast(skirts.exp, h = 20) # vypocte 20 predpovedi
plot(skirts.exp.for)
lines(1868:1911, skirts.exp$fitted[,1], col = 3) # zakresleni predpovedi do grafu, modra cara je bodova predpoved, tmave seda plocha 80% interval spolehlivosti
  #   a svetle seda plocha 95% interval spolehlivosti
############################
## Parametry funkce HoltWinters:
# alpha - zodpovida za absolutni clen
# beta - zodpovida za linearni clen
# gamma - zodpovida za sezonni slozku
# pocita se vyhlazeni v podobe Y(t+h) = a(t) + h*b(t) + s(t - p + 1 + (h-1) mod p)
# jednotlive slozky jsou pocitany rekurentne a pri svem vypoctu vyuzivaji i ostatnich slozek:
# a(t) = alpha*(Y(t) - s(t - p)) + (1 - alpha)*(a(t - 1) + b(t - 1))
# b(t) = beta*(a(t) - a(t - 1)) + (1 - beta)*b(t - 1)
# s(t) = gamma*(Y(t) - a(t)) + (1 - gamma)*s(t - p)
# chcete-li vetsi vyhlazeni, pak pomuze volit mensi alpha
# pokud menite i parametr beta, pak musite hledat vhodnou kombinaci alpha, beta 
############################
## Najdete optimalni zpusob vyhlazeni u nasledujicich rad
## rocni hodnoty vysky hladiny Huronskeho jezera
plot(LakeHuron)
lake.rm3 <- rollmean(LakeHuron, 3); lake.rm5 <- rollmean(LakeHuron, 5); lake.rm7 <- rollmean(LakeHuron, 7); lake.rm9 <- rollmean(LakeHuron, 9); lake.rm11 <- rollmean(LakeHuron, 11) # pro krajni body odhady nejsou
lines(lake.rm3, col = 2); lines(lake.rm5, col = 3); lines(lake.rm7, col = 4); lines(lake.rm9, col = 5); lines(lake.rm11, col = 6)
legend(1960, 582, legend=c("puvodni rada", "KP delky 3", "KP delky 5", "KP delky 7", "KP delky 9", "KP delky 11"),lty=1, col=1:6, cex=0.8)

cas <- 1875:1972
lin.trend <- lm(LakeHuron ~ cas); kv.trend <- lm(LakeHuron ~ cas + I(cas^2)); kub.trend <- lm(LakeHuron ~ cas + I(cas^2) + I(cas^3))
plot(LakeHuron); abline(lin.trend, col = 2); lines(cas,fitted(kv.trend), col = 3); lines(cas,fitted(kub.trend), col = 4)
summary(lin.trend)$r.squared; summary(kv.trend)$r.squared; summary(kub.trend)$r.squared #kubický
AIC(lin.trend); AIC(kv.trend); AIC(kub.trend) # Akaikeho informacni kriterium - cim mensi tim lepsi
BIC(lin.trend); BIC(kv.trend); BIC(kub.trend)# Bayesovske informacni kriterium - cim mensi tim lepsi
## pocty lidi pripojenych k internetu za minutu
plot(WWWusage)
lake.rm3 <- rollmean(WWWusage, 3); lake.rm5 <- rollmean(WWWusage, 5); lake.rm7 <- rollmean(WWWusage, 7); lake.rm9 <- rollmean(WWWusage, 9); lake.rm11 <- rollmean(WWWusage, 11) # pro krajni body odhady nejsou
lines(lake.rm3, col = 2); lines(lake.rm5, col = 3); lines(lake.rm7, col = 4); lines(lake.rm9, col = 5); lines(lake.rm11, col = 6)
legend(80, 120, legend=c("puvodni rada", "KP delky 3", "KP delky 5", "KP delky 7", "KP delky 9", "KP delky 11"),lty=1, col=1:6, cex=0.8)
(WWWusage)
cas <- 1:100; lin.trend <- lm(WWWusage ~ cas); kv.trend <- lm(WWWusage ~ cas + I(cas^2)); kub.trend <- lm(WWWusage ~ cas + I(cas^2) + I(cas^3))
plot(WWWusage); abline(lin.trend, col = 2); lines(cas,fitted(kv.trend), col = 3); lines(cas,fitted(kub.trend), col = 4)
summary(lin.trend)$r.squared; summary(kv.trend)$r.squared; summary(kub.trend)$r.squared
## rocni prumerne teploty v New Haven
plot(nhtemp)
lake.rm3 <- rollmean(nhtemp, 3); lake.rm5 <- rollmean(nhtemp, 5); lake.rm7 <- rollmean(nhtemp, 7); lake.rm9 <- rollmean(nhtemp, 9); lake.rm11 <- rollmean(nhtemp, 11) # pro krajni body odhady nejsou
lines(lake.rm3, col = 2); lines(lake.rm5, col = 3); lines(lake.rm7, col = 4); lines(lake.rm9, col = 5); lines(lake.rm11, col = 6)
## rocni prutoky Nilu
plot(Nile)
lake.rm3 <- rollmean(Nile, 3); lake.rm5 <- rollmean(Nile, 5); lake.rm7 <- rollmean(Nile, 7); lake.rm9 <- rollmean(Nile, 9); lake.rm11 <- rollmean(Nile, 11) # pro krajni body odhady nejsou
lines(lake.rm3, col = 2); lines(lake.rm5, col = 3); lines(lake.rm7, col = 4); lines(lake.rm9, col = 5); lines(lake.rm11, col = 6)
## rada hlavniho indikatoru prodeje
plot(BJsales.lead)
lake.rm3 <- rollmean(BJsales.lead, 3); lake.rm5 <- rollmean(BJsales.lead, 5); lake.rm7 <- rollmean(BJsales.lead, 7); lake.rm9 <- rollmean(BJsales.lead, 9); lake.rm11 <- rollmean(BJsales.lead, 11) # pro krajni body odhady nejsou
lines(lake.rm3, col = 2); lines(lake.rm5, col = 3); lines(lake.rm7, col = 4); lines(lake.rm9, col = 5); lines(lake.rm11, col = 6)
## koncentrace CO2 v ovzdusi v Mauna Loa
plot(co2)