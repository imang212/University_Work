# Autokorelacni a parcialni autokorelacni funkce 
data(lh) # Luteinizing Hormone in Blood Samples
plot(lh) # v rade neni evidentni zadny trend ani sezonnost
# autokovariancni funkce
acf(lh, type = "covariance"); acf(lh, type = "covariance", plot = F) # vypis hodnot, prvni z nich je rozptyl rady
  var(lh)
# autokorelacni funkce
acf(lh); acf(lh, plot = F) # opet si muzeme nechat hodnoty vypsat, když jsem mimo pásmo, tak jsou autokorelace nulove
# parcialni autokorelacni funkce
pacf(lh) # parcialni autokorelacni funkce
pacf(lh, plot = F) # vypis hodnot
# ktere korelace jsou nenulove? Ktere modely pripadaji pro radu v uvahu?
par(mfrow = c(2,1)); acf(lh); pacf(lh); par(mfrow = c(1,1)) # nakresleni obou funkci pod sebe
# test na nulovost autokorelacni funkce
Box.test(lh, lag = 2, type = "Ljung-Box") # testuje, jestli jsou autokorelace do casu 2 nevyznamne
  # rucne najdete hodnotu, kterou by nemela prekrocit druha autokorelace, pokud chceme, aby od druhe dale, byly autokorelace nulove	
# nulovost autokorelacni funkce residui znamena, ze mame spravny model
##########################
### Samostatne
# podivejte se na autorekoralecni a parcialni autokorelacni funkce rad LakeHuron, lynx, co2, discoveries
# LakeHuron: Roční hladina Huronského jezera, mírný trend
par(mfrow = c(3,1)); plot(LakeHuron, main="LakeHuron - Hladina")
acf(LakeHuron, main="ACF LakeHuron") # ACF klesá pomalu (lineárně)
pacf(LakeHuron, main="PACF LakeHuron") # PACF má výrazný první lag. To naznačuje model AR(1) nebo AR(2). (autoregresní proces)
par(mfrow = c(1,1))
# lynx: Počet koček rysů ulovených v Kanadě, silná cykličnost
plot(lynx, main="Lynx - Počet ulovených rysů")
par(mfrow = c(2,1))
acf(lynx, main="ACF Lynx") # ACF má sinusový průběh (vlnění), což potvrzuje cykličnost.
pacf(lynx, main="PACF Lynx") # PACF má výrazné první dva lagy -> často se modeluje jako AR(2).
par(mfrow = c(1,1)) # Interpretace: ACF kles pomalu a má vlnění, PACF má výrazné první dva lagy. To naznačuje model AR(2) nebo ARMA(2,0).
# co2: Měsíční koncentrace CO2, silný trend a sezónnost
plot(co2, main="co2 - Trend + Sezónnost")
par(mfrow = c(2,1)); acf(co2, lag.max = 60, main="ACF co2"); pacf(co2, lag.max = 60, main="PACF co2"); par(mfrow = c(1,1))
# ACF klesá extrémně pomalu kvůli trendu. Jsou vidět "zuby" v ročních intervalech (lag 1, 2...). 
# Pro reálnou analýzu by bylo nutné řadu nejprve diferencovat (odstranit trend).
# discoveries: Počet objevů v oblasti, bez zjevného trendu a sezónnosti
plot(discoveries, main="discoveries - Počty objevů")
par(mfrow = c(2,1)); acf(discoveries, main="ACF discoveries"); pacf(discoveries, main="PACF discoveries"); par(mfrow = c(1,1))
# Většina korelací je v rámci modrého pásma (nevyznamné). 
# Možná slabá korelace v prvním lagu, ale řada je velmi blízká bílému šumu.
##########################
# pomoci funkce arima.sim(n = ,list(ar = ,ma = )) nasimulujte rady typu
#   MA(1) s parametrem theta1 = 0.75
#   MA(1) s parametrem theta1 = -0.75
#   MA(1) s parametrem theta1 = 1.5
#   AR(1) s parametrem phi1 = 0.75
#   AR(1) s parametrem phi1 = - 0.75
#   AR(1) s parametrem phi1 = 1.5
# podivejte se, jak rady vypadaji a jak vypadaji jejich autokorelacni a parcialni autokorelacni funkce
# nasimulujte bily sum a podivejte se na jeho autokorelacni a parcialni autokorelacni funkci
plot_sim <- function(ts_data, title) { par(mfrow = c(1,3)); plot(ts_data, main = title, col = "darkblue"); acf(ts_data, main = "ACF"); pacf(ts_data, main = "PACF"); par(mfrow = c(1,1)) }
# MA(1) procesy (ACF končí po 1. lagu, PACF klesá)
ma1_pos <- arima.sim(n = 200, list(ma = 0.75)); plot_sim(ma1_pos, "MA(1) theta = 0.75") # významná korelace v bodě 1
ma1_neg <- arima.sim(n = 200, list(ma = -0.75)); plot_sim(ma1_neg, "MA(1) theta = -0.75")
# MA(1) s 1.5 není technicky invertibilní, ale simulačně lze vytvořit:
ma1_inv <- arima.sim(n = 200, list(ma = 1.5)); plot_sim(ma1_inv, "MA(1) theta = 1.5 (Non-invertible)")
# AR(1) procesy (ACF klesá, PACF končí po 1. lagu)
ar1_pos <- arima.sim(n = 200, list(ar = 0.75)); plot_sim(ar1_pos, "AR(1) phi = 0.75")
ar1_neg <- arima.sim(n = 200, list(ar = -0.75)); plot_sim(ar1_neg, "AR(1) phi = -0.75")
# AR(1) s phi = 1.5 -> CHYBA (nestacionární). Simulujeme jen pokud |phi| < 1.
ar1_bad <- arima.sim(n = 200, list(ar = 1.5)) # Toto hodí chybu 'A' matrix not invertible
# Bílý šum
wn <- ts(rnorm(200)); plot_sim(wn, "White Noise")
# podivejte se na radu ldeaths, vypoctete jeji autokorelacni a parcialni autokorelacni funkci
#   ocistete ji od trendu a sezonnosti a podivejte se na autokorelacni funkci a parcialni autokorelacni funkci jejich residui
data("ldeaths"); plot(ldeaths)
# 1. Dekompozice (odstranění trendu a sezónnosti)
ldeaths_dec <- decompose(ldeaths); plot(ldeaths_dec)
# 2. Práce s residui (očištěná řada)
res_ldeaths <- ldeaths_dec$random
res_ldeaths <- na.omit(res_ldeaths) # odstranění NA po dekompozici
par(mfrow = c(1,2)); acf(res_ldeaths, main="ACF reziduí ldeaths"); pacf(res_ldeaths, main="PACF reziduí ldeaths")
# Pokud v ACF/PACF něco zbylo, můžeme na tato rezidua nasadit ARMA model.
# stejne pracujte s radou discoveries a WWWusage
data("discoveries")
par(mfrow = c(1,2)); acf(discoveries, main="ACF discoveries"); pacf(discoveries, main="PACF discoveries")
# Většinou vypadá jako bílý šum nebo AR(1) s velmi malým koeficientem.
data("WWWusage"); plot(WWWusage)
# Diferencování (odstranění trendu)
diff_www <- diff(WWWusage)
plot(diff_www, main="Diferencovaná řada WWWusage")
par(mfrow = c(1,2)); acf(diff_www); pacf(diff_www)
# Tady uvidíš, že po 1. nebo 2. diferenci se řada stane stacionární
# a ACF/PACF nám napoví řád p a q pro model ARIMA(p, 1, q).