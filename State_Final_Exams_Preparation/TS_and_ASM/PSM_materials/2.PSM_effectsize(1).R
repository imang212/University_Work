###################
### Odhad poctu pozorovani
library(pwr)
## Kolik pozorovani potrebuji k tomu, abych odhalila rozdil oproti nulove hypoteze
#   o velikosti 3, pri smerodatne odchylce 5, se silou testu 0.95, na hladine vyznamnosti 0.05.
#   Vyhodnoceni budu delat pomoci jednovyberoveho t-testu
pwr.t.test(d = 3/5, sig.level = 0.05, power = 0.95, type = "one.sample") # Potrebuji 38 pozorovani

# u Wilcoxonova testu potrebuji cca o 15% navic
(n <- pwr.t.test(d = 3/5, sig.level = 0.05, power = 0.95, type = "one.sample")$n)
n*1.15 # Wilcoxonuv test by potreboval 44 pozorovani
## A kolik potrebuji pozorovani, kdyz chci odhalit rozdil ve dvou skupinach o velikosti 8,
#   pri ocekavane sdruzene smerodatne odchylce 20, se silou testu 0.95, na hladine vyznamnosti 0.05.
pwr.t.test(d = 8/20, sig.level = 0.05, power = 0.95, type = "two.sample")
## Chceme-li otestovat pravdepodobnostni rozdeleni kategoricke promenne se ctyrmi kategoriemi,
#   pouzijeme chi-kvadrat test dobre shody. "Effect size" je soucet (pi - p0i)^2/p0i pres vsechny 
#   kategorie a odpovida Cramerovu phi. Kolik potrebujeme pozorovani, kdyz chceme tento
#   effekt o velikosti 0.3, silu testu 0.8 a hladinu vyznamnosti 0.05?
pwr.chisq.test(w = 0.3, df = (4-1), power = 0.80, sig.level = 0.05)
## kolik budeme potrebovat pozorovani, kdyz budeme testovat nezavislost dvou kategorickych
#   promennych se tremi a ctyrmi kategoriemi. Zajima nas "effect size" o velikosti 0.2, 
#   sila testu 0.8 a hladina vyznamnosti 0.05.
pwr.chisq.test(w = 0.2, df = (3-1)*(4-1), power = 0.80, sig.level = 0.05)
## Kolik potrebuji pozorovani, kdyz chci odhalit odchylku od nulove hypotezy o velikosti 1, 
#   pri smerodatne odchylce 5, se silou testu 0.90, na hladine vyznamnosti 0.05?
pwr.t.test(d = 1/5, sig.level = 0.05, power = 0.90, type = "one.sample") # 265
## Kolik potrebuji pozorovani, kdyz chci odhalit rozdil ve dvou skupinach o velikosti 5,
#   pri ocekavane sdruzene smerodatne odchylce 10, se silou testu 0.9, na hladine vyznamnosti 0.05.
pwr.t.test(d = 5/10, sig.level = 0.05, power = 0.90, type = "two.sample") # 85
## Kolik budeme potrebovat pozorovani, kdyz budeme testovat nezavislost dvou kategorickych
#   promennych s peti a ctyrmi kategoriemi. Zajima nas "effect size" o velikosti 0.4, 
#   sila testu 0.9 a hladina vyznamnosti 0.05.
pwr.chisq.test(w = 0.4, df = (4-1)*(5-1), power = 0.90, sig.level = 0.05)
###################
### Nacteni dat Stulong.RData
## data z velke studie, ktera u muzu stredniho veku merila riziko srdecni choroby
names(Stulong)<-c("ID", "vyska", "vaha", "syst1", "syst2", "chlst", "vino", "cukr", "bmi", "vek", "KOURrisk", "Skupina", "VekK")
###################
### Vecna vyznamnost
library(effectsize)
library(DescTools)
## Je vyznamny rozdil ve vysce mezi starsimi a mladsimi muzi? (promenne vyska, VekK)
ciselna <- Stulong$vyska
kategoricka <- Stulong$VekK
tapply(ciselna, kategoricka, mean)
# Test normality pro kazdou skupinu zvlast
par(mfrow = c(1,2)); tapply(ciselna, kategoricka, PlotQQ); par(mfrow = c(1,1))
tapply(ciselna, kategoricka, shapiro.test) # jsou odchylky od normality skutecne vyznamne?
  # pri velkem poctu pozorovani se divame jen na grafy
# Test shody rozptylu
var.test(ciselna ~ kategoricka)
# pouzijeme dvouvyberovy t-test
t.test(ciselna ~ kategoricka,var.eq = T) # Je rozdil ve vyskach skutecne vyznamny?
### Statistiky vecne vyznamnosti
cohens_d(ciselna ~ kategoricka) # Cohenovo d
  interpret_cohens_d(cohens_d(ciselna ~ kategoricka))
hedges_g(ciselna ~ kategoricka) # Hedgesovo g
  interpret_hedges_g(hedges_g(ciselna ~ kategoricka))
glass_delta(ciselna ~ kategoricka) # Glassovo delta
  interpret_glass_delta(glass_delta(ciselna ~ kategoricka))
eta_squared(aov(ciselna ~ kategoricka)) # Fisherovo eta
  (A <- anova(aov(ciselna ~ kategoricka)))
    A[,2]
    A[1,2]/(sum(A[,2]))
  interpret_eta_squared(0.01, rules = "cohen1992")
  omega_squared(aov(ciselna ~ kategoricka)) # Haysova omega
  (A[1,2] - A[2,3])/(sum(A[,2]) + A[2,3])
epsilon_squared(aov(ciselna ~ kategoricka)) # dalsi charakteristika

###################
### Analyza rozptylu
ciselna <- Stulong$vaha
kategoricka <- Stulong$Skupina
plot(ciselna ~ kategoricka)
# Test normality pro residua modelu
res <- residuals(lm(ciselna ~ kategoricka))
PlotQQ(res, pch = 19) # jsou videt odchylky od normality
# Test shody rozptylu
bartlett.test(ciselna ~ kategoricka)
### Testy analyzy rozptylu
# klasicka ANOVA pro normalne rozdelena data se shodnymi rozptyly ve skupinach
anova(aov(ciselna ~ kategoricka))
  # tabulka analyzy rozptylu
# Welchova ANOVA pro normalne rozdelena data s ruznymi rozptyly ve skupinach
oneway.test(ciselna ~ kategoricka, var.eq = FALSE)
# Kruskal-Wallisova ANOVA pro nenormalne rozdelena data
kruskal.test(ciselna ~ kategoricka)
# vsechny testy ukazuji vyznamne rozdily
# ktere konkretni dvojice skupin se od sebe vyznamne lisi
# parove srovnani pro normalne rozdelena data
TukeyHSD(aov(ciselna ~ kategoricka))
  plot(TukeyHSD(aov(ciselna ~ kategoricka)))
  # nekdy se deli podle shody rozptylu
# parove srovnani pro nenormalne rozdelena data
DunnTest(ciselna ~ kategoricka)
## a jsou zjistene rozdily i vecne vyznamne? 
# Fisherovo eta
eta_squared(aov(ciselna ~ kategoricka))
  interpret_eta_squared(0.03, rules = "cohen1992")
# Haysova omega
omega_squared(aov(ciselna ~ kategoricka))
  interpret_omega_squared(0.02, rules = "cohen1992")
epsilon_squared(aov(ciselna ~ kategoricka))
  interpret_epsilon_squared(0.02, rules = "cohen1992")
###################
## Souvisi spolu diagnosticka Skupina a vek muzu (promenne Skupina, VekK)
kat1 <- Stulong$Skupina
kat2 <- Stulong$VekK
(tab <- table(kat1, kat2))
plot(as.factor(kat1) ~ as.factor(kat2), col = 2:5)
chisq.test(kat1, kat2)
  # je rozdil ve skupinach skutecne podstatny?
# Cramerovo V
cramers_v(tab)
  sqrt(chisq.test(tab)$statistic/(sum(tab)*(ncol(tab) - 1)))
cohens_w(tab)
## Souvisi spolu konzumace vina a vek muzu (promenne vino, VekK)
kat1 <- Stulong$vino
kat2 <- Stulong$VekK
(tab <- table(kat1,kat2))
plot(as.factor(kat1) ~ as.factor(kat2), col=2:5)
chisq.test(kat1, kat2)
  # je rozdil ve skupinach skutecne podstatny?
# Cramerovo phi
phi(tab)  
cohens_w(tab)
# Cramerovo phi
  sqrt(chisq.test(tab)$statistic/sum(tab))
###################
## Souvisi spolu vaha a hladina cholesterolu?
cislo1 <- Stulong$vaha
cislo2 <- Stulong$chlst
plot(cislo1 ~ cislo2, pch = 19, main = "Souvislost vahy a hladiny cholesterolu")
cor(cislo1, cislo2)
cor.test(cislo1, cislo2)
  # Zavislost je statisticky vyznamna
  interpret_r(cor(cislo1, cislo2))
summary(lm(cislo1 ~ cislo2))$r.squared  
  # koeficient determinace
  # kolik procent variability zavisle promenne se modelem vysvetlilo
  interpret_r2(summary(lm(cislo1 ~ cislo2))$r.squared)
#######################
### Samostatne
## Zavisi bmi na koureni? Zjistete statistickou i vecnou vyznamnost.
## Zavisi systolicky tlak na vaze?
## Je rozdil mezi skupinami v hladine cukru v krvi?
## Je rozdil v systolickem tlaku u kuraku a nekuraku?
## Lisi se vyska u tech co piji a nepiji vino?
