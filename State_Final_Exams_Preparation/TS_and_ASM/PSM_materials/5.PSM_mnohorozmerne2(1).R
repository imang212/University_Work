###########################
library(MASS) # knihovna s nastroji mnohorozmerne statistiky
## Diskriminacni analyza
Iris <- data.frame(rbind(iris3[,,1], iris3[,,2], iris3[,,3]), Sp = rep(c("s","c","v"), rep(50,3)))
  # databaze o trech druzich kosatcu: Setosa (s), Versicolour (c), Virginica (v)
  # mereny jsou 4 ukazatele: sepal length & width, petal length & width
  #	kalisni a okvetni listek, vzdy delka a sirka
train <- sample(1:150, 75) # nahodny vyber 75 rostlin z cele databaze
table(Iris$Sp[train]) # vstupni data do diskriminacni analyzy ... rostliny, u nichz presne zname druh
(z <- lda(Sp ~ ., Iris, prior = c(1,1,1)/3, subset = train)) # linearni diskriminacni analyza
  # vystup: vstupni (apriori) pravdepodobnosti ... jake je ocekavane zastoupeni skupin v populaci 
  #	prumery promennych ve skupinach a koeficienty linearnich diskriminacnich funkci
predict(z, Iris[-train, ])$x # vysledne hodnoty diskriminacnich funkci
predict(z, Iris[-train, ])$posterior # pravdepodobnosti zarazeni do jednotlivych populaci
predict(z, Iris[-train, ])$class #na zaklade vytvorene klasifikacni funkce priradi nova mereni do skupin vybere idealni skupinu + vypocte pravdepodobnosti s nimiz do jednotlivych skupin patri
table(Iris[-train,"Sp"], predict(z, Iris[-train, ])$class)# klasifikacni tabulka, jak dobre se trefim: v radcich skutecne hodnoty, ve sloupcich predikce
#########################
### Samostatne
# vyzkousejte si na datech z biopsie
data("biopsy") # jak vypada diskriminacni funkce rozlisujici zhoubny a nezhoubny nador?
biop <- na.omit(biopsy)[, -1]
colnames(biop) <- c("V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8", "V9", "class")
# rozdeleni dat na trenovaci a testovaci mnozinu
set.seed(123)
n <- nrow(biop)
train_index <- sample(1:n, n/2)
table(biop$class[train_index]) # vstupni data do diskriminacni analyzy ... vzorky, u nichz presne zname zarazeni
(z <- lda(class ~ ., biop, prior = c(1,1)/2, subset = train_index)) # linearni diskriminacni analyza
predict(z, biop[-train_index, ])$class # na zaklade vytvorene klasifikacni funkce priradi nova mereni do skupin bio)
table(biop[-train_index,"class"], predict(z, biop[-train_index, ])$class) # klasifik
#########################
## Shlukova analyza, budem delit americke staty do skupin na zaklade 4 ukazatelu: vrazdy, napadeni, populace, znasilneni
hc <- hclust(dist(USArrests), "ave") # hierarchicke clusterovani metodou average linkage, vstupem je matice vzdalenosti jednotlivych bodu
plot(hc, hang = -1) # nakresleni dendrogramu - postup, jak shlukuje nejprve ma kazde pozorovani svou vlastni skupinu, a ty se pak spojuji do vetsich celku
  #	mozny je i obraceny postup, tj. od jedne velke skupiny k mnoha malym na graf se podivam a urcuji pocet skupin, ktere v nem vidim
seg <- cutree(hc, k = 4) # rozdeli data do 4 skupin
rect.hclust(hc, k=4, border="red") # mohu si nechat zobrazit skupiny do dendrogramu
# Jak vypadaji segmenty v datech? v datech mam jen 4 promenne, mohu si nechat vykreslit
plot(USArrests$Murder, USArrests$Assault, col = seg, pch = 19)
plot(USArrests$UrbanPop, USArrests$Assault, col = seg, pch = 19)
plot(USArrests$Rape, USArrests$Assault, col = seg, pch = 19) # pro segmentaci je klicova promenna Assault - proc?
USArrests.sc <- scale(USArrests) # spocitame standardizovane promenne
hc.sc <- hclust(dist(USArrests.sc), "ave")
plot(hc.sc, hang = -1) # zde jsou videt 2 velke skupiny nebo 5 mensich (s jednim outlierem)
seg.sc <- cutree(hc.sc, k = 5) # rozdeli data do 5 skupin
table(seg, seg.sc) # dame-li vsem promennym stejnou vahu, rozdeli se mi staty jinak

plot(USArrests$Murder, USArrests$Assault, col = seg.sc, pch = 19)
plot(USArrests$UrbanPop, USArrests$Rape, col = seg.sc, pch = 19) # zde je videt odlehla Aljaska
# vykresleni skupin v prvnich dvou hlavnich komponentach
pc <- prcomp(USArrests, scale = T)$x
plot(pc[,1], pc[,2], col = seg.sc, pch = 19) # rozdeleni do skupin je dobre videt
# V praxi se casteji pouziva metoda complete linkage
hc.sc2 <- hclust(dist(USArrests.sc))
plot(hc.sc2, hang = -1) # zde mi dendogram jasne deli data na 4 skupiny
# nebo Wardova metoda, ktera dava vetsinou "nejhezci" dendrogram
hc.sc3 <- hclust(dist(USArrests.sc), method = "ward.D2")
plot(hc.sc3, hang = -1) # opet jsou krasne videt 4 skupiny, i kdyz trochu jine nez ty ziskane pomoci complete linkage
seg.sc2 <- cutree(hc.sc2, k = 4) # rozdeli data do 4 skupin - complete linkage
seg.sc3 <- cutree(hc.sc3, k = 4) # rozdeli data do 4 skupin - Wardova metoda
table(seg, seg.sc2)
table(seg.sc, seg.sc2)
table(seg.sc2, seg.sc3) # kontrola, jak vznikle skupiny souhlasi s predchozimi delenimi
# Zakresleni aktualniho deleni do skupin
plot(USArrests$Murder, USArrests$Assault, col = seg.sc2, pch = 19)
plot(USArrests$UrbanPop, USArrests$Rape, col = seg.sc2, pch = 19)
plot(pc[,1], pc[,2], col = seg.sc2, pch = 19) # nahlavnich komponentachvychazi pekne
# je mozne vysledne segmenty popsat pomoci puvodnich promennych
tapply(USArrests$Murder, as.factor(seg.sc2), mean)
tapply(USArrests$Assault, as.factor(seg.sc2), mean)
tapply(USArrests$UrbanPop, as.factor(seg.sc2), mean)
tapply(USArrests$Rape, as.factor(seg.sc2), mean) # pro vybranou promennou spocita prumery za jednotlive shluky
# K-means clustering
require(graphics)
seg.km <- kmeans(USArrests.sc, 4) # pocet skupin beru na zaklade predesleho hierarchickeho shlukovani
table(seg.sc2, seg.km$cluster) # jak vychazi metoda K-means v porovnani s hierarchickym shlukovanim
plot(USArrests$Murder, USArrests$Assault, col = seg.km$cluster, pch = 19)
plot(USArrests$UrbanPop, USArrests$Rape, col = seg.km$cluster, pch = 19)
plot(pc[,1], pc[,2], col = seg.km$cluster, pch = 19) # rozlozeni do skupin je velmi podobne
seg.km$centers # vidime stredy shluku u standardizovanych promennych
#########################
### Samostatne
# vyzkousejte si na datech o krabech
data("crabs") # segmentujte na zaklade ciselnych promennych (4.-8. sloupec), nebyla by lepsi segmentace na zaklade hlavnich komponent/ faktoru?
crabs_data <- scale(crabs[, 4:8]) # Výběr číselných dat a standardizace
hc_crabs <- hclust(dist(crabs_data), method = "ward.D2") # Shlukování (Wardova metoda)
plot(hc_crabs)
seg_crabs <- cutree(hc_crabs, k = 4) # Rozdělení do 4 skupin (máme 2 druhy a 2 pohlaví = 4 kombinace)
pc_crabs <- prcomp(crabs_data, scale = T)$x #Vizualizace pomocí PCA (mnohem přehlednější)
plot(pc_crabs[,1], pc_crabs[,2], col = seg_crabs, pch = 19, main = "Clustering krabů na PCA komponentách")
table(seg_crabs, crabs$sex)
eigen(cor(crabs[,4:8]))$values
hc2 <- hclust(dist(pc_crabs[,1:2]))
plot(hc2, hang = -1)
seq2 <- cutree(hc2, 3)
fa <- factanal(crabs_data, factors = 2, scores = "Bartlett")$scores
plot(pc_crabs[,1], pc_crabs[,2], col = seq2, pch = 19, main = "Clustering krabů na PCA komponentách")
# pouzijte data fgl - chemicke slozeni ulomku skel
data("fgl") # vyzkousejte na nich diskriminacni analyzu i shlukovou analyzu
fgl_data <- scale(fgl[, 1:9]) # vynecháme poslední sloupec 'type')
hc_fgl <- hclust(dist(fgl_data), method = "ward.D2") # Hierarchické shlukování
plot(hc_fgl, labels = fgl$type, cex = 0.6, hang = -1) # labels nám ukáží, zda se shlukují stejné typy
set.seed(123) # pro stabilitu výsledků
km_fgl <- kmeans(fgl_data, centers = 6) # víme, že typů skla je 6, K-means pro srovnání
table(fgl$type, km_fgl$cluster) # Kontrola úspěšnosti - tabulka shody
seq <- cutree(hc_fgl, 6)
table(fgl$type)
table(fgl$type, seq)
pc_f <- prcomp(fgl_data, scale= T)$x
plot(pc_f[,1], pc_f[,2], col = as.numeric((as.factor(fgl$type))), pch = 19, main = "Clustering krabů na PCA komponentách podle typu")
plot(pc_f[,1], pc_f[,2], col = seq, pch = 19, main = "Clustering krabů na PCA komponentách")
plot(pc_f[,1], pc_f[,2], col = km_fgl$cluster, pch = 19, main = "Clustering krabů na PCA komponentách")
eigen(cor(fgl[,1:9]))$values
# diskriminační analýza
library(MASS)
set.seed(111)
train <- sample(1:214, 100)
table(fgl[train, 10])
model_lda <- lda(type ~ ., data = fgl, prior= rep(1, 6)/6, subset = train)
model_lda
#plot(model_lda, col = as.integer(fgl$type), pch=19)
pred_lda <- predict(model_lda, fgl[-train, ])
tabulka <- table(Skutecnost = fgl[-train,10], Predpoved = pred_lda$class)
tabulka
plot(pred_lda$x[,1], pred_lda$x[,2], col = fgl$type[-train], pch=19)
sum(diag(tabulka)) / sum(tabulka)

# h0: skupiny jsou stejné, h1: skupiny se liší
res <- manova(as.matrix(fgl[,1:9]) ~ fgl$type)
summary(res) # liší se
# normalita, shoda rozptylů
library(DescTools)
PlotQQ(residuals(lm(fgl$RI ~ fgl$type)), pch=19) # není normální rozdělení
bartlett.test(fgl$RI ~ fgl$type) # liší se - h1 alternativní 
tapply(fgl$RI, fgl$type, sd)
plot(fgl$RI ~ fgl$type) # testování rozptylů
kruskal.test(fgl$RI ~ fgl$type)
DunnTest(fgl$RI ~ fgl$type)
