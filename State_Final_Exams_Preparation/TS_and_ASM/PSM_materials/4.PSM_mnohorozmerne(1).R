#######################################
#### Mnohorozmerna statistika
library(DescTools); library(MASS) # nacteni knihoven
#######################################
### Zobecneni jednorozmernych metod
## Mnohorozmerny dvouvyberovy T-test (Hotellingovo T2)
# Porovnavame 2 vyucujici na zaklade hodnoceni jejich studentu. 
#   Je mezi vyucujicimi vyznamny rozdil?
matematici <- data.frame(ucitel = factor(rep(1:2, c(5, 7))), 
                         spokojenost = c(1, 3, 2, 4, 3, 2, 6, 4, 5, 5, 3, 4), 
                         znalost = c(4, 7, 2, 6, 3, 6, 6, 8, 7, 10, 9, 6))
# vytvoreni dat
matematici # ukazka dat
tapply(matematici$spokojenost, matematici$ucitel, mean)
tapply(matematici$znalost, matematici$ucitel, mean) # prumerna spokojenost a znalost u jednotlivych ucitelu
# jednorozmerne porovnani
boxplot(matematici$spokojenost ~ matematici$ucitel)
boxplot(matematici$znalost ~ matematici$ucitel)
t.test(matematici$spokojenost ~ matematici$ucitel)
t.test(matematici$znalost ~ matematici$ucitel) # u znalosti vychazi vyznamny rozdil, u spokojenosti ne
(m1 <- HotellingsT2Test(cbind(matematici$spokojenost, matematici$znalost) ~ matematici$ucitel))
  # porovnani obou hodnoceni u ucitelu, p<= 0.05, tak zavrhame H0, ze mezi uciteli neni rozdil, a prijmeme H1, ze mezi uciteli je rozdil
## MANOVA - jak se vytvari plasticky film
# vytvoreni dat
trhliny <- c(6.5, 6.2, 5.8, 6.5, 6.5, 6.9, 7.2, 6.9, 6.1, 6.3, 6.7, 6.6, 7.2, 7.1, 6.8, 7.1, 7.0, 7.2, 7.5, 7.6)
lesk <- c(9.5, 9.9, 9.6, 9.6, 9.2, 9.1, 10.0, 9.9, 9.5, 9.4, 9.1, 9.3, 8.3, 8.4, 8.5, 9.2, 8.8, 9.7, 10.1, 9.2)
sytost <- c(4.4, 6.4, 3.0, 4.1, 0.8, 5.7, 2.0, 3.9, 1.9, 5.7, 2.8, 4.1, 3.8, 1.6, 3.4, 8.4, 5.2, 6.9, 2.7, 1.9)
Y <- cbind(trhliny, lesk, sytost) # zavisle promenna se sklada ze tri dilcich promennych
pomer <- factor(gl(2,10), labels = c("Nizky", "Vysoky"))
prisady <- factor(gl(2, 5, length = 20), labels = c("Nizky", "Vysoky"))
  # dva nezavisle faktory ... tri zavisle promenne se budou porovnavat v techto skupinach
data <- data.frame(Y, pomer, prisady)
## Graf ukazujici rozdily mezi skupinami
library(ggplot2)
library(ggpubr) # nacteni potrebnych knihoven
ggboxplot(data, x = "prisady", y = "trhliny", color = "pomer") # krabicovy graf pro trhliny
ggboxplot(data, x = "prisady", y = "lesk", color = "pomer") # krabicovy graf pro lesk
ggboxplot(data, x = "prisady", y = "sytost", color = "pomer") # krabicovy graf pro sytost
## prumery po skupinach
pomer_prisady <- paste(pomer, prisady, sep = "_") # kombinovana promenna
meany <- data.frame("trhliny.m" = tapply(trhliny, pomer_prisady, mean),
                    "lesk.m" = tapply(lesk, pomer_prisady, mean),
                    "sytost.m" = tapply(sytost, pomer_prisady, mean))
meany # prumery po skupinach
# Analyza rozptylu
(fit <- manova(Y ~ pomer * prisady)) # vlastni model - na vystupu jsou soucty ctvercu pro kazdou promennou
summary.aov(fit) # tabulky jednorozmernych analyz rozptylu pro kazdou promennou zvlast
  # na nezavisle promennych zavisi jen trhliny a lesk
summary(fit, test = "Wilks")
  # existuje nekolik testovych statistik na nichz je zalozena mnohorozmerna analyza rozptylu
  # R-ko nabizi statistiky: "Pillai", "Wilks", "Hotelling-Lawley", "Roy"
  # Wilkovo lambda je zobecnenim klasicke F-statistiky z jednorozmerne ANOVy
summary(fit)
  summary(fit, test = "Hotelling-Lawley")
  # pouziti jine testove statistiky
  # interakce nejsou vyznamne
(fit2 <- manova(Y ~ pomer + prisady))
summary(fit2) # mira vlivu samostatnych promennych
#################################
### Samostatne
data(mtcars)
## Lisi se ciselne charakteristiky podle poctu valcu?
## Lisi se ciselne charakteristiky podle typu motoru?
#################################
## Kanonicka korelace
#	korelace mezi dvema skupinami promennych, pracujme s charakteristikami statu: osobni uspory, podil populace do 15 let, podil populace nad 75 let, prijem na obyvatele, narust prijmu na obyvatele
# rozdelime promenne do skupin: populacni podily, ekonomicke charakteristiky
pop <- LifeCycleSavings[, 2:3]
oec <- LifeCycleSavings[, -(2:3)]
cancor(pop, oec)# vypocet kanonickych korelaci na vystupu jsou kanonicke korelace (jejich pocet je stejny jako pocet promennych v mensi skupine), koeficienty kanonickych promennych prumery promennych
library(CCP)
p.asym(cancor(pop, oec)$cor, dim(pop)[1], dim(pop)[2], dim(oec)[2], tstat = "Wilks")
#################################
### Samostatne
data("UScrime")
# Souvisi zasah policie s kriminalitou? 
#   Zasah policie popisuji promenne Po1 a Po2 a kriminalitu promenne Prob, Time a y.
# kanonicke korelace mezi zasahy policie a kriminalitou
(policie <- UScrime[, c("Po1", "Po2")])
(kriminalita <- UScrime[, c("Prob", "Time", "y")])
cc_policie <- cancor(policie, kriminalita)
cc_policie$cor
p.asym(cc_policie$cor, dim(policie)[1], dim(policie)[2], dim(kriminalita)[2], tstat = "Wilks") # podle prvni vidím, že závisí, ale podle druhé ne, 
# protože p-hodnota je větší než 0.05, takže nezamítáme H0, že mezi zasahy policie a kriminalitou není závislost, a přijímáme H1, že mezi zasahy policie a kriminalitou je závislost
# Souvisi nezamestnanost s kriminalitou?
#   Nezamestnanost popisuji promenne U1 a U2.
nezamestnanost <- UScrime[, c("U1", "U2")]
cc_nezamestnanost <- cancor(nezamestnanost, kriminalita)
cc_nezamestnanost$cor
p.asym(cc_nezamestnanost$cor, nrow(UScrime), ncol(nezamestnanost), ncol(kriminalita), tstat = "Wilks")
#################################
# Metoda hlavnich komponent
v1 <- c(1,1,1,1,1,1,1,1,1,1,3,3,3,3,3,4,5,6)
v2 <- c(1,2,1,1,1,1,2,1,2,1,3,4,3,3,3,4,6,5)
v3 <- c(3,3,3,3,3,1,1,1,1,1,1,1,1,1,1,5,4,6)
v4 <- c(3,3,4,3,3,1,1,2,1,1,1,1,2,1,1,5,6,4)
v5 <- c(1,1,1,1,1,3,3,3,3,3,1,1,1,1,1,6,4,5)
v6 <- c(1,1,1,2,1,3,3,3,4,3,1,1,1,2,1,6,5,4)
vmat <- data.frame(v1,v2,v3,v4,v5,v6)
m1 <- cbind(v1,v2,v3,v4,v5,v6) # vytvoreni dat
# Zakladem analyzy hlavnich komponent je korelacni matice
cor(m1) # korelacni matice
eigen(cor(m1)) # vlastni cisla a vlastni vektory korelacni matice
# Pocet potrebnych hlavnich komponent ma byt pocet vlastnich cisel vetsich nez 1
screeplot(princomp(m1, cor = T), type="l")
abline(h=1, col="green") # dostatecne velke procento vyuzite variability (80%)
  cumsum(eigen(cor(m1))$values / sum(eigen(cor(m1))$values)) # prvni 3 komponenty vysvetli pres 90% variability
# Vytvoreni hlavnich komponent  
prcomp(m1)
(PC <- prcomp(vmat, scale = T)) # hlavni komponenty, vrati variabilitu hlavnich komponent spolu s koeficienty jednotlivych komponent
plot(PC$x[,1], PC$x[,2], pch = 19, main = "Prvni 2 hlavni komponenty") # vykresleni prvnich dvou hlavnich komponent, ukazuji v datech skupiny
# maji hlavni komponenty prirozenou interpretaci? mnohdy ne, pak je potreba pouzit faktorovou analyzu
## Faktorova analyza
factanal(m1, factors = 3)  # faktorova analyza jen prerotuje hlavni komponenty, metoda rotace 'varimax' je brana jako zakladni (defaultni), vypis loadingu a procent vysvetlene variability
(sc <- factanal(~v1+v2+v3+v4+v5+v6, factors = 3, scores = "Bartlett")$scores) # faktorove skory pro jednotliva pozorovani
plot(sc[,1], sc[,2], pch = 19, main = "Prvni 2 faktory") # vykresleni prvnich dvou faktoru
## Priklad na realnych datech
library(MASS); library(psych) # nacteni knihovny s vhodnymi datovymi soubory
## Je mozne vytvorit smysluplne faktory z ciselnych promennych v datech bfi?
data(bfi)
?bfi # Obsahuje 25 polozek osobnostniho testu (Big Five Inventory)
  # Kolik hlavnich komponent/ faktoru je potreba pro reprezentaci ciselnych promennych?
  #   Jak byste pojmenovali faktory? Nakreslete vhodny graf/ grafy.
bfi2 <- na.omit(bfi) # vynechani pozorovani s chybejicimi hodnotami
# graficke znazorneni dat
PC <- prcomp(bfi2[, 1:25], scale = T) # vytvoreni hlavnich komponent
PC$sdev #	variabilita jednotlivych hlavnich komponent, prvních 6 hlavních má větší variabilitu než 1
plot(PC$x[,1], PC$x[,2], pch = 19, main = "Prvni 2 hlavni komponenty") # graf prvnich dvou hlavnich komponent, nejlepsi graficke zobrazeni dat pomoci dvourozmerneho grafu
# urceni poctu potrebnych faktoru
# vlastni cisla korelacni matice
eigen(cor(bfi2[, 1:25]))$values # 6 vlastnich cisel je vetsich nez 1, meli bychom pouzit 6 hlavnich komponent/ faktoru
# je mozne i graficke znazorneni tohoto poctu
screeplot(princomp(bfi2[, 1:25], cor = T), type="l")
abline(h=1, col="green") # je videt, ze po seste komponente uz je pokles krivky jen minimalni
cumsum(eigen(cor(bfi2[, 1:25]))$values / sum(eigen(cor(bfi2[, 1:25]))$values))
# faktorova analyza
factanal(bfi2[, 1:25], factors = 6) # prvnich 5 faktoru je tvoreno jednotlivymi bloky otazek, sesty faktor je navic
factanal(bfi2[, 1:25], factors = 5) # spravne reseni je reprezentovat data pomoci peti faktoru prvnich 5 faktoru obsahuje 52% variability obsazene v datech
  # faktory muzeme nazvat nasledovne:
  #   1. faktor: Neurotismus 
  #   2. faktor: Otevrenost 
  #   3. faktor: Svedomitost
  #   4. faktor: Vstricnost vuci ostatnim
  #   5. faktor: Nadseni pro praci 
################################
### Samostatne
## Kolik hlavnich komponent/ faktoru je potreba pro reprezentaci ciselnych promennych?
#   Jak byste pojmenovali faktory? Nakreslete vhodny graf/ grafy.

## Hledejte hlavni komponenty / faktory pro soubor UScrime.
data("UScrime")
crime_data <- UScrime
crime_data <- na.omit(crime_data)
ev <- eigen(cor(crime_data))$values
ev
screeplot(princomp(crime_data, cor = T), type="l")
abline(h=1, col="green", lty= 2)
cumsum(ev / sum(ev))

PC_crime <- prcomp(crime_data, scale = T)
plot(PC_crime$x[,1], PC_crime$x[,2], pch = 19, main = "Prvni 2 hlavni komponenty UScrime", xlab = "PC1 (Socioekonomika a Policie)", ylab = "PC2 (Nezaměstnanost)")
text(PC_crime$x[,1], PC_crime$x[,2], labels = rownames(crime_data), pos = 3, cex = 0.7)

fa_crime <- factanal(na.omit(crime_data), factors = 5, rotation = "varimax")
print(fa_crime, cutoff = 0.3)
