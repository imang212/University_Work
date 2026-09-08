###########################
library(MASS)# knihovna s nastroji mnohorozmerne statistiky
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
predict(z, Iris[-train, ])$class # na zaklade vytvorene klasifikacni funkce priradi nova mereni do skupin
  #	vybere idealni skupinu + vypocte pravdepodobnosti s nimiz do jednotlivych skupin patri
table(Iris[-train,"Sp"], predict(z, Iris[-train, ])$class) # klasifikacni tabulka, jak dobre se trefim: v radcich skutecne hodnoty, ve sloupcich predikce
#########################
### Samostatne
# vyzkousejte si na datech z biopsie
data("biopsy") # jak vypada diskriminacni funkce rozlisujici zhoubny a nezhoubny nador?
head(biopsy)
set.seed(123)
biopsy <- na.omit(biopsy)
train_index <- sample(1:dim(biopsy)[1], 350)
train_data <- biopsy[train_index, ]; test_data <- biopsy[-train_index, ]

lda_model <- lda(class ~ V1+V2+V3+V4+V5+V6+V7+V8+V9,data=biopsy, prior=c(1,1)/2, subset = train_data)
pred <- predict(lda_model, test_data)$class
table(test_data$class,pred)

#########################
## Shlukova analyza
# budem delit americke staty do skupin na zaklade 4 ukazatelu: vrazdy, napadeni, populace, znasilneni
hc <- hclust(dist(USArrests), "ave") # hierarchicke clusterovani metodou average linkage, vstupem je matice vzdalenosti jednotlivych bodu
plot(hc, hang = -1) # nakresleni dendrogramu - postup, jak shlukuje nejprve ma kazde pozorovani svou vlastni skupinu, a ty se pak spojuji do vetsich celku
  #	mozny je i obraceny postup, tj. od jedne velke skupiny k mnoha malym na graf se podivam a urcuji pocet skupin, ktere v nem vidim
seg <- cutree(hc, k = 4) # rozdeli data do 4 skupin
rect.hclust(hc, k=4, border="red") # mohu si nechat zobrazit skupiny do dendrogramu
# Jak vypadaji segmenty v datech?
  # v datech mam jen 4 promenne, mohu si nechat vykreslit
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
crabs_data <- crabs[, 4:8]
crabs_scaled <- scale(crabs_data)
# Hierarchická shluková analýza
hc_crabs <- hclust(dist(crabs_scaled))
plot(hc_crabs, hang = -1, main = "Dendrogram")
seg_crabs <- cutree(hc_crabs, k = 4) # zkus rozdělit na 4 skupiny
# Zobrazení ve 2D
plot(crabs$FL, crabs$RW, col = seg_crabs, pch = 19, xlab = "Front Lobe", ylab = "Rear Width", main = "Shluky v datech crabs")
# Pomocí hlavních komponent
pc_crabs <- prcomp(crabs_scaled)$x
plot(pc_crabs[,1], pc_crabs[,2], col = seg_crabs, pch = 19, main = "Shluky v prvních 2 hlavních komponentách")

hc_crabs <- hclust(dist(crabs_scaled[,1:2]))
plot(hc_crabs, hang = -1, main = "Dendrogram")
seg_crabs <- cutree(hc_crabs, k = 4) # zkus rozdělit na 4 skupiny
plot(crabs$FL, crabs$RW, col = seg_crabs, pch = 19, xlab = "Front Lobe", ylab = "Rear Width", main = "Shluky v datech crabs")


# pouzijte data fgl - chemicke slozeni ulomku skel
data("fgl")# vyzkousejte na nich diskriminacni analyzu i shlukovou analyzu

fgl_data <- scale(fgl[, -10])
# Hierarchické shlukování
hc_fgl <- hclust(dist(fgl_data)) 
plot(hc_fgl, hang = -1, main = "Dendrogram - fgl")
seg_fgl <- cutree(hc_fgl, k = 2)
plot(fgl$RI, fgl$Mg, col = seg_fgl, pch = 19, xlab = "Index lomu", ylab = "Hořčík", main = "Shluky ve fgl")
# K-means shlukování (srovnání s hierarchickým)
km_fgl <- kmeans(fgl_data, centers = 2)
plot(prcomp(fgl_data)$x[,1], prcomp(fgl_data)$x[,2], col = km_fgl$cluster, pch = 19, main = "K-means na prvních 2 hlavních komponentách")
# Porovnání výsledků
table(km_fgl$cluster, seg_fgl)

# Diskriminační analýza na původních třídách skla
train_index <- sample(1:n[1], 100)
train_data <- fgl[train_index, ]; test_data <- fgl[-train_index, ]

lda_fgl <- lda(type ~ ., data = fgl, prior(1,1,1,1,1,1)/2, subset=train_data)
pred_fgl <- predict(lda_fgl)$class
(table <- (fgl[-train_index,]$class))
table(fgl$type, pred_fgl) # jak dobře predikujeme skutečný typ skla

#########################
## Kanonicka korelace
#	korelace mezi dvema skupinami promennych, pracujme s charakteristikami statu: osobni uspory, podil populace do 15 let,
#	podil populace nad 75 let, prijem na obyvatele, narust prijmu na obyvatele, rozdelime promenne do skupin: populacni podily, ekonomicke charakteristiky
(pop <- LifeCycleSavings[, 2:3]) 
oec <- LifeCycleSavings[, -(2:3)]
cancor(pop, oec) # vypocet kanonickych korelaci, na vystupu jsou kanonicke korelace (jejich pocet je stejny jako pocet promennych v mensi skupine), koeficienty kanonickych promennych, prumery promennych
library(CCP)
p.asym(cancor(pop, oec)$cor, dim(pop)[1], dim(pop)[2], dim(oec)[2], tstat = "Wilks")
p.perm(pop,oec,nboot=999, rhostart=1, type="Wilks")
p.perm(pop,oec,nboot=999, rhostart=2, type="Wilks")
#########################
### Samostatne
data("UScrime")
# Souvisi zasah policie s kriminalitou? 
#   Zasah policie popisuji promenne Po1 a Po2 a kriminalitu promenne Prob, Time a y.

police_vars <- UScrime[, c("Po1", "Po2")]
crime_vars <- UScrime[, c("Prob", "Time", "y")]
cc_police_crime <- cancor(police_vars, crime_vars)
p.asym(cc_police_crime$cor, dim(police_vars)[1], dim(police_vars)[2], dim(crime_vars)[2], tstat = "Wilks") #první se významě liší, druhá se moc neliší

p.perm(police_vars,crime_vars, nboot=999, rhostart=2, type="Wilks")

# Souvisi nezamestnanost s kriminalitou?
#   Nezamestnanost popisuji promenne U1 a U2.
police_vars <- UScrime[, c("U1", "U2")]
crime_vars <- UScrime[, c("Prob", "Time", "y")]
#########################
