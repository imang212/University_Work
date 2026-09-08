#############################
### Dekompozice casove rady
births <- scan("http://robjhyndman.com/tsdldata/data/nybirths.dat") # mesicni pocty narozenych v New Yorku od ledna 1946 do prosince 1959
births.ts <- ts(births, frequency = 12, start = c(1946, 1)) # prevedeni na casovou radu
plot(births.ts) # vykresleni rady, rada ma konstantni rozptyl, uvazuje se aditivni model
births.dec <- decompose(births.ts)
plot(births.dec) # rada byla rozlozena na trend, sezonni slozku a nahodnou chybu
(sez <- births.dec$seasonal) # sezonni slozka
(trend <- births.dec$trend) # je mozne odhadnout krivkou logistickeho trendu
(ns <- births.dec$random) # nahodna slozka
births.stl <- stl(births.ts, s.window = 9)
plot(births.stl) # jina metoda rozkladu, ktera umoznuje vyuziti loess regrese a tedy muze odhadovat variabilni sezonnost
plot(AirPassengers) # pocty cestujicich vybranou leteckou spolecnosti v letech 1949 - 1960, rada ma rostouci rozptyl, uvazuje se multiplikativni model
AirP.dec <- decompose(AirPassengers, type = "multiplicative")
plot(AirP.dec)
# muzete vyzkouset na radach co2, lynx
plot(co2)
co2.dec <- decompose(co2); plot(co2.dec)
(sez <- co2.dec$seasonal)
(trend <- co2.dec$trend)
(ns <- co2.dec$random)
co2.stl <- stl(co2, s.window = 9); plot(co2.stl)
# lynx
plot(lynx)
lynx.dec <- decompose(lynx); plot(lynx.dec)
lynx <- ts(lynx, frequency = 10)
lynx.dec <- decompose(lynx); plot(lynx.dec)
#############################
#### Hledani trendu v ukazkovych datech
Examples1 <- load("Examples1.txt")
### Linearni trend
time <- 1971:2000
rada <- Examples1[,1]
rada.ts <- ts(rada, start = 1971); plot(rada.ts)
mod1 <- lm(rada.ts ~ time)
summary(mod1)
coef(mod1)
AIC(mod1)
lines(time, fitted(mod1), col = 2)
############################
## Kvadraticky trend
time2 <- time*time
rada <- Examples1[,2]
rada.ts <- ts(rada, start = 1971); plot(rada.ts)
mod1 <- lm(rada.ts ~ time + time2)
summary(mod1)
coef(mod1)
AIC(mod1)
lines(time, fitted(mod1), col = 2)
mod2 <- lm(rada.ts ~ time)
summary(mod2)
coef(mod2)
AIC(mod2)
lines(time, fitted(mod2), col = 3)
############################
## Exponencialni trend
rada <- Examples1[,3]
rada.ts <- ts(rada, start = 1971); plot(rada.ts)
ln.rada.ts <- log(rada.ts)
mod1 <- lm(ln.rada.ts ~ time)
summary(mod1)
coef(mod1)
exp(coef(mod1))
AIC(mod1)
lines(time,exp(fitted(mod1)), col = 2)
mod2 <- lm(rada.ts ~ time+time2)
summary(mod2)
coef(mod2)
AIC(mod2)
lines(time, fitted(mod2), col = 3)
mod3 <- lm(rada.ts ~ time)
summary(mod3)
coef(mod3)
AIC(mod3)
lines(time, fitted(mod3), col = 4)
##############################
## Logisticky trend
x <- 1:30
rada <- Examples1[,4]
rada.ts <- ts(rada, start = 1971); plot(rada.ts)
-(log(120))/log(0.7)
mod1 <- nls(rada.ts ~ SSlogis(time, Asym, xmid, scal))
mod1 <- nls(rada.ts ~ SSlogis(x, Asym, xmid, scal))
summary(mod1)
coef(mod1)
AIC(mod1)
mod2 <- nls(rada.ts ~ SSgompertz(time, Asym, b2, b3))
mod2 <- nls(rada.ts ~ SSgompertz(x, Asym, b2, b3))
summary(mod2)
coef(mod2)
AIC(mod2)
##############################
## Gompertzova krivka
rada <- Examples[,5]
rada.ts <- ts(rada, start = 1971)
plot(rada.ts)
-(log(13.2))/log(0.8)
mod1 <- nls(rada.ts ~ SSgompertz(time, Asym, b2, b3))
mod1 <- nls(rada.ts ~ SSgompertz(x, Asym, b2, b3))
summary(mod1)
coef(mod1)
AIC(mod1)
mod2 <- nls(rada.ts ~ SSlogis(time, Asym, xmid, scal))
mod2 <- nls(rada.ts ~ SSlogis(x, Asym, xmid, scal))
summary(mod2)
coef(mod2)
AIC(mod2)
##############################
## zkuste dalsi rady ze souboru Examples1