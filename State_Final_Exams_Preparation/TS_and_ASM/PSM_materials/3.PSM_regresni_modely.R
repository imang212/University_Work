########################
## Jednoducha linearni regrese
# nactete data Ichs
# Zavislost hmotnosti na vysce 
hmot <- Ichs$hmot; vyska <- Ichs$vyska
plot(hmot ~ vyska, pch = 19, main = "Zavislost hmotnosti na vysce")
abline(lm(hmot ~ vyska), col = 2) # regresni primka

# Model jednoduche linearni regrese
model <- lm(hmot ~ vyska)
coef(model) # odhady regresnich koeficientu: hmotnost = -66.85 + 0.84*vyska
            # na 1 cm vysky pripada v prumeru 0.84 kg hmotnosti
summary(model) # odhad a vyznamnost regresnich koeficientu
  # Residual standard error - stredni chyba residui
  # Multiple R-squared - koeficient determinace
  # kolik procent variability se zavislosti vysvetli
AIC(model); BIC(model) # Akaikeho a Bayesovske kriterium
confint(model) # intervaly spolehlivosti pro parametry modelu

# Interval spolehlivosti pro odhad
new <- data.frame(vyska = c(186, 168, 173))
predict(model, new, interval = "confidence")
# predikcni interval spolehlivosti
new <- data.frame(vyska = c(186, 168, 173))
predict(model, new, interval = "prediction")

### Testy predpokladu
# graficka diagnostika
par(mfrow = c(2, 2)); plot(model); par(mfrow = c(1, 1))
  # 1. graf: linearita zavislosti - cervena cara nema mit trend - OK
  # 2. graf: normalita residui - body maji byt na primce - OK
  # 3. graf: stabilita rozptylu (homoskedasticita) - cervena cara nema mit trend - OK
  # 4. graf: vlivnost pozorovani (Cook's distance) - zadny bod nevybocuje z mezi - OK

# test normality residui 
shapiro.test(residuals(model))
# test stability rozptylu
library(lmtest); bptest(model)
# Cookova vzdalenost
cooks.distance(model)
cooks.distance(model)[which.max(cooks.distance(model))] # nejvetsi hodnota Cookovy vzdalenosti
# merime vlivnost pozorovani
influence.measures(model)
summary(influence.measures(model))

# Multikolinearita (ve vicenasobne regresi)
# Zavislost hmotnosti na systolickem a diastolickem tlaku
syst <- Ichs$syst; diast <- Ichs$diast
plot(hmot ~ syst, pch = 19, main = "Zavislost hmotnosti na systolickem tlaku")
plot(hmot ~ diast, pch = 19, main = "Zavislost hmotnosti na diastolickem tlaku")

summary(lm(hmot ~ diast + syst)) # vidim jen slabou zavislost na systolickem tlaku
summary(lm(hmot ~ diast))
summary(lm(hmot ~ syst)) # ve skutecnosti je evidentni zavislost na obou tlacich
plot(syst ~ diast, pch = 19, main = "Vztah mezi systolickym a diastolickym tlakem")
cor(syst, diast) # vysoka vzajemna korelace

library(car)
vif(lm(hmot ~ diast + syst)) # Variance inflaction factor - ma byt maly (idealne pod 1)
######################
## Kategoricka promenna v linearnim modelu
Smok <- Ichs$Kour
plot(hmot ~ Smok)
lm(hmot ~ Smok)
summary(lm(hmot ~ Smok))# vidim vyznamnost dummy promennych
anova(lm(hmot ~ Smok)) # tahle se neprokazala jako vyznamna, vyznamnost cele promenne dohromady 

#####################
### Interakce v ANOVe - dvojne trideni
# Jak hmotnost zavisi na koureni a cholesterolu?
library(RcmdrMisc); library(car)

hmot <- Ichs$hmot; vyska <- Ichs$vyska; Cholest <- Ichs$Cholest; Smok <- Ichs$Kour
plotMeans(hmot, Smok, Cholest, error.bars = "se", connect = TRUE, legend.pos = "farright")
plotMeans(hmot, Smok, Cholest, error.bars = "conf.int", connect = TRUE, legend.pos = "farright")
Anova(aov(hmot ~ Smok * Cholest)
# ANOVA pres regresni model
summary(lm(hmot ~ Smok * Cholest)) #slabý kuřák se zvýšeným cholesterolem: hmot = 87.4 - 5.6 -7.7 + 5.8
Anova(lm(hmot ~ Smok * Cholest)) #hmot = B0 + B1*kour + B2*chol + B3*kour*chol+E, hmot = 87.4 - 2.08*nekurak - 7.2*silný - 5.6*slabý
  # hmotnost se v zavislosti na jednotlivych promennych nelisi
Anova(lm(hmot ~ Smok))
plot(hmot ~ Smok)
Anova(aov(hmot ~ Cholest))
plot(hmot ~ Cholest)
#######################
### Multiple linear regression
# Jak systolicky tlak zavisi na hmotnosti, koureni a vysce?
# takto komplikovanou zavislost nelze zobrazit
#   pomohou dilci grafy
# Zavislost na hmotnostni a cholesterolu
syst <- Ichs$syst; hmot <- Ichs$hmot; Cholest <- Ichs$Cholest
plot(syst ~ hmot, pch = 19, col = as.integer(Cholest))
abline(lm(syst[as.integer(Cholest) == 1] ~ hmot[as.integer(Cholest) == 1]), col = 1)
abline(lm(syst[as.integer(Cholest) == 2] ~ hmot[as.integer(Cholest) == 2]), col = 2) # Zavislost se podle cholesterolu nelisi
# Zavislost na hmotnosti a koureni
Kour <- Ichs$Koureni
plot(syst ~ hmot, pch = 19, col = as.integer(Kour))
abline(lm(syst[as.integer(Kour) == 1] ~ hmot[as.integer(Kour) == 1]), col = 1)
abline(lm(syst[as.integer(Kour) == 2] ~ hmot[as.integer(Kour) == 2]), col = 2) # v zavislosti na koureni jsou urcite rozdily videt

model1 <- lm(syst ~ hmot * Kour * vyska)
summary(model1) # model se vsemi promennymi z nejz budem postupne vynechavat

# Rucne: krokova regrese metoda backward (zpetna), nejvetsi inerakce neni vyznamna
model2 <- lm(syst ~ hmot * Kour + vyska * Kour + vyska * hmot); summary(model2) # nejprve se vynechavaji nevyznamne interakce
model3 <- lm(syst ~ hmot * Kour + vyska * Kour); summary(model3)
model4 <- lm(syst ~ hmot + vyska * Kour); summary(model4)
model5 <- lm(syst ~ hmot + vyska + Kour); summary(model5) # az kdyz jsou vynechany nevyznamne interakce, je mozne vynechavat samostatne promenne, 
  #   ktere nejsou obsazeny v interakcich
model6 <- lm(syst ~ hmot + Kour); summary(model6)
# Coefficient of determination
summary(model1)$r.squared
summary(model2)$r.squared
summary(model3)$r.squared

# Krokova regrese
model.st <- step(lm(syst ~ hmot * Kour * vyska)); summary(model.st) # automaticka procedura, ktera hleda optimalni model na zaklade Akaikeho kriteria
AIC(model.st) # u vysledneho modelu je treba zkontrolovat, zda nelze jeste zjednodusit

# Krokova regrese s vyuzitim Bayesovskeho informacniho kriteria
n <- length(syst)  
model.st2 <- step(lm(syst ~ hmot * Kour * vyska), k = log(n))
summary(model.st2) # zde vychazi stejne

# U vysledneho modelu je treba otestovat predpoklady
par(mfrow = c(2, 2)); plot(model.st); par(mfrow = c(1, 1)) # z grafu je videt mensi problem s normalitou dat
# kontrola dvou stezejnich predpokladu ciselnym testem

## normalita: H0: normalni rozdeleni vs. H1: neni normalni rozdeleni
shapiro.test(residuals(model.st)) # p = 5.453e-05 < alfa = 0.05 => zamitame normalitu, predpoklad neni splnen
## stabilita rozptylu: H0: rozptyl je stabilni vs. H1. rozptyl neni stabilni
bptest(model.st) # p = 0.7857 > alfa = 0.05 => nezamitame stabilitu rozptylu, predpoklad je splnen
vif(model.st) # obe hodnoty nizke, problem s multikolinearitou neni

## Jak resit problem s normalitou?
# transformace zavisle promenne
ln.syst <- log(Ichs$syst)
model.ln <- lm(ln.syst ~ hmot * Kour * vyska); summary(model.ln) # neni nic videt
model.lns <- step(model.ln); summary(model.lns) # vysly stejne vyznamne promenne
par(mfrow = c(2, 2)); plot(model.lns); par(mfrow = c(1, 1))
## normalita: H0: normalni rozdeleni vs. H1: neni normalni rozdeleni
  shapiro.test(residuals(model.lns)) # je zrejme, ze normalita se zlepsila

# Jina moznost je vynechat problematicke pozorovani na osmem radku
Ichs2 <- Ichs[-8,]
# optimalni model
model.st3 <- step(lm(syst ~ hmot * Koureni * vyska, data = Ichs2))
summary(model.st3)
# testy predpokladu
par(mfrow = c(2, 2)); plot(model.st3); par(mfrow = c(1, 1))
shapiro.test(residuals(model.st3))
bptest(model.st3) # vsechny predpoklady jsou splneny
### Interpretace regresnich koeficientu
# koeficient u hmotnosti:
#   Pri narustku hmotnosti o 1 kg vzroste systolicky tlak v prumeru o 0.45 jednotek
#     pri stejne kategorii koureni.
# koeficient u koureni:
#   Nekuraci maji v prumeru o 8.8 jednotek vyssi systolicky tlak nez kuraci,
#     pri stejne hmotnosti

##########################
#### Samostatne
# Uvazujte data mtcars
data(mtcars)
head(mtcars)

model1 <- lm(hp ~ mpg + cyl + vs + am + gear + disp + drat + wt + qsec + carb, data = mtcars); summary(model1) #pokud jsou p>0.05%, tak nemají významný vliv
vif(model1)
cor(mtcars[,c(1, 2:7)])

step1 <- step(model1)
summary(step1)
summary(model1)$coefficients #rozdíl mezi manuální a automatickou převodovkou
par(mfrow = c(2, 2)); plot(step1); par(mfrow = c(1, 1))

model2 <- lm(hp ~ mpg + cyl*vs + vs+am + am + gear + disp + drat*vs + wt + qsec + carb, data = mtcars); summary(model2) #pokud jsou p>0.05%, tak nemají významný vliv
vif(model2)
step2 <- step(model2); summary(step1)
par(mfrow = c(2, 2)); plot(step2); par(mfrow = c(1, 1))


model_int1 <- lm(hp ~ cyl + vs * disp + vs * am + am * disp, data = mtcars)
summary(model_int1)

model_int2 <- lm(hp ~ cyl + gear + vs * (disp + mpg) + am * (disp + mpg), data = mtcars)
summary(model_int2)
summary(model_int2)$r.squared
par(mfrow = c(2, 2)); plot(model_int2); par(mfrow = c(1, 1))

# Normalita residuí
shapiro.test(residuals(model_int2))
# Homoskedasticita (stálost rozptylu)
bptest(model_int2)
# Multikolinearita
vif(model_int2)


# Na cem zavisi sila vozu, promenna hp? Promenne cyl, vs, am a gear uvazujte jako kategoricke.
# Jaky je rozdil mezi automatickou a manualni prevodovkou (promenna am)?
# Je dulezita interakce vs a disp? A co interakce vs a am? A interakce am a disp?
# A co kdyz pridam jeste interakce vs a am s mpg?
# Kolik procent variability se vyslednym modelem vysvetli? 
# Jsou splneny predpoklady?
# Spoctete predpoved ...

##########################
#### Logisticka regrese
library(datarium); library(car) # v knihovne datarium je vhodna databaze z Titaniku
smpl<-sample(1:2201,150)
titanic<-titanic.raw[smpl,] # vyber 150 hodnot, abychom mohli pracovat i s p-hodnotama
dependent<- (titanic$Survived=="Yes") # zavisle promenna

table(titanic$Survived,titanic$Class); table(titanic$Survived,titanic$Age); table(titanic$Survived,titanic$Sex) # kontrola, jaci pasazeri prezili

mod1<-glm(dependent~titanic$Class+titanic$Sex+titanic$Age,family="binomial")
  # model logisticke regrese
summary(mod1)
  # odhady koefificnetu a jejich vyznamnost

library(fmsb)
NagelkerkeR2(mod1)
  # neco jako koeficient determinace (pocitany z deviance)

Anova(mod1,type="II")
  # vyznamnost promennych

# interpretace regresnich koeficientu
(b<-coef(mod1))
  # ulozeni koeficientu do promenne
1/exp(b[3])
  # kolikrat se zvysuji sance na preziti u cestujicich v prvni tride oproti cestujicim ve treti tride
1/exp(b[4])
  # kolikrat se zvysuji sance na preziti u cestujicich v prvni tride oproti posadce
exp(b[5])
  # kolikrat se zvysuji sance na preziti u zen oproti muzum

# Jake sance na preziti ma dospely muz cestujici druhou tridou?
(odd<-exp(b[1]+b[2]+b[6]))
# A jakou ma pravdepodobnost, ze prezije
(prob<-odd/(1+odd))

########################
### Samostatne

## Zavisi hladina cholesterolu na hmotnosti, koureni a na veku?
# promenne Rchol, hmot, Kour, vek

########################
### Poissonova regrese - log-linear model
# zavisle promennou tvori pocty
p <- read.csv("https://stats.idre.ucla.edu/stat/data/poisson_sim.csv")
p <- within(p, {
  prog <- factor(prog, levels=1:3, labels=c("General", "Academic", 
                                            "Vocational"))
  id <- factor(id)
})
  # pocty oceneni ziskane studenty v ruznych studijnich programech
  #   pridana je zavislost na vysledcich testu z matematiky
(tab<-table(p$prog,p$num_awards))
barplot(tab,beside=T,col=2:4,main="Numbers of awards for different study programs",legend=T)
  # graficke znazorneni

# Poissonova regrese
(mod.p1 <- glm(num_awards ~ prog + math, family="poisson", data=p))
summary(mod.p1)
library(car)
Anova(mod.p1)
  # obe nezavisle promenne maji vyznamny vliv
  #   "General" a "Vocational" program se od sebe vyznamne nelisi

confint(mod.p1)
  # intervaly spolehlivosti pro regresni koeficienty
NagelkerkeR2(mod.p1)
  # neco jako koeficient determinace

# Graficky vystup
pred<-predict(mod.p1, type="response")
vyst<-data.frame(p$math,p$prog,pred)
vyst<-vyst[order(vyst[,1]),]
plot(num_awards~math,col=prog,pch=19,data=p,main="Zavislost poctu oceneni na testu z matematiky")
lines(vyst[vyst[,2]=="General",1],vyst[vyst[,2]=="General",3],col=1)
lines(vyst[vyst[,2]=="Academic",1],vyst[vyst[,2]=="Academic",3],col=2)
lines(vyst[vyst[,2]=="Vocational",1],vyst[vyst[,2]=="Vocational",3],col=3)
legend(35,5.5,levels(p$prog),lty=1,col=1:3)


##################
### Poradova (ordinalni) regrese
library(MASS)
library(foreign)
dat <- read.dta("https://stats.idre.ucla.edu/stat/data/ologit.dta")
# example data from internet
# data: apply - how likely the student will apply for graduation on a school
#       parent - are the parents graduated?
#       public - is the undergraduate institution public or private?
#       GPA - average score on the undergraduate institution
ftable(xtabs(~ public + apply + pared, data = dat))
# summary contingency table
# a question is: on what the probability to apply for graduation depends?
m <- polr(apply ~ pared + public + gpa, data = dat, Hess=TRUE)
summary(m)
# basic outputs for estimates of regression coefficients
ctable <- coef(summary(m))
pval <- pt(abs(ctable[, "t value"]), df=length(dat$apply)-1, lower.tail = FALSE) * 2
(ctable <- cbind(ctable, "p value" = p))
# table for coefficients together with the p-values
# type of the school (public or private) is not important
#   other variables have significant impact on apply of graduation

## OR and CI
(ci <- confint(m))
# confidence intervals for linear coefficients
exp(cbind(OR = coef(m), ci))
# how many times the odds of apply of graduation increase, when
#   the independent variable increases by one, while the other independent variables stay fixed