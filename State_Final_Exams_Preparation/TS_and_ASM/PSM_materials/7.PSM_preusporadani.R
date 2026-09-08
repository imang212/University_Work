######################
### Odhady zalozene na preusporadani dat
######################
library(DescTools)
### Pouzijte data PlantGrowth
##  porovnava se vaha ziskane plodiny pri dvou osetrenich a jedne kontrolni skupine
data("PlantGrowth")
## Nejprve checeme odhadnout stredni hodnotu (populacni prumer) a rozptyl prumeru
wt <- PlantGrowth$weight 
### bezny postup 
(original_mean <- mean(wt)) # prumer
(original_variance <- (MeanSE(wt))^2) # rozptyl prumeru
### vyuziti metody Jackknife
n <- length(wt)
jackknife_means <- numeric(n)
# vytvoreni n vyberu, kde kazdy ma jednu vynechanou hodnotu 
for (i in 1:n) {
  jackknife_sample <- wt[-i]
  jackknife_means[i] <- mean(jackknife_sample)
}
# odhad metodou Jackknife
(jackknife_mean <- mean(jackknife_means))
# vychyleni (bias) odhadu
(bias <- (n - 1) * (original_mean - jackknife_mean))
# rozptyl odhadu
(jackknife_variance <- (n - 1) * mean((jackknife_means - jackknife_mean) ^ 2))
# jake je rozdeleni Jackknife odhadu?
hist(jackknife_means, col = "lightgreen")
### vyuziti Bootstrapu
# pocet bootstrapovych vyberu
num_resamples <- 1000
n <- length(wt)
bootstrap_means <- numeric(num_resamples)
# bootstrapove vybery s vracenim   
for (i in 1:num_resamples) {# Resample with replacement
  bootstrap_sample <- sample(wt, size = n, replace = TRUE)
  bootstrap_means[i] <- mean(bootstrap_sample)
}
# odhad metodou Bootstrap
(bootstrap_mean <- mean(bootstrap_means))
# vychyleni (bias) odhadu
(bias <- bootstrap_mean - original_mean)
# rozptyl odhadu
(bootstrap_variance <- var(bootstrap_means))
# jake je rozdeleni bootstrapoveho odhadu
hist(bootstrap_means, col = "lightblue")
# pro jednoducha data vsechny 3 metody dobre funguji
###################################
### Samostatne
## Jak odhadnout sikmost vahy?
wt <- PlantGrowth$weight 
(original_skew <- Skew(PlantGrowth$weight))
n <- length(wt); jackknife_skews <- numeric(n)
for (i in 1:n) {
  jackknife_sample <- wt[-i]
  jackknife_skews[i] <- Skew(jackknife_sample)
}
(jackknife_skew <- Skew(jackknife_skews))
(bias <- (n - 1) * (original_skew - jackknife_skew))
(jackknife_variance <- (n - 1) * mean((jackknife_skews - jackknife_skew) ^ 2))
hist(jackknife_skews, col = "lightgreen")

num_resamples <- 1000; n <- length(wt)
bootstrap_skews <- numeric(num_resamples)
for (i in 1:num_resamples) {
  bootstrap_sample <- sample(wt, size = n, replace = TRUE)
  bootstrap_skews[i] <- Skew(bootstrap_sample)
}
(bootstrap_skew <- Skew(bootstrap_skews)) 
(bias <- bootstrap_skew - original_skew)
(bootstrap_variance <- var(bootstrap_skews))
# jake je rozdeleni bootstrapoveho odhadu
hist(bootstrap_skews, col = "lightblue")

## Odhadnete ruznymi zpusoby stredni hodnotu a rozptyl vyse hladiny Huronskeho jezera
data("LakeHuron")

wt <- LakeHuron
(original_mean <- mean(LakeHuron))
n <- length(wt); jackknife_means <- numeric(n)
for (i in 1:n) {
  jackknife_sample <- wt[-i]
  jackknife_means[i] <- mean(jackknife_sample)
}
(jackknife_mean <- mean(jackknife_means))
(bias <- (n - 1) * (original_skew - jackknife_skew))
(jackknife_variance <- (n - 1) * mean((jackknife_means - jackknife_mean) ^ 2))
hist(jackknife_means, col = "lightgreen")

num_resamples <- 1000; n <- length(wt)
bootstrap_means <- numeric(num_resamples)
for (i in 1:num_resamples) {
  bootstrap_sample <- sample(wt, size = n, replace = TRUE)
  bootstrap_means[i] <- mean(bootstrap_sample)
}
(bootstrap_mean <- mean(bootstrap_means)) 
(bias <- bootstrap_mean - original_mean)
(bootstrap_variance <- var(bootstrap_means))
# jake je rozdeleni bootstrapoveho odhadu
hist(bootstrap_skews, col = "lightblue")
###################################
### pro odhad intervalu spolehlivosti se pouziva bud klasicky zpusob, nebo metoda bootstrap
## urcete interval spolehlivosti obema zpusoby
# vyjde Vam rucni vypocet bootstrapoveho intervalu spolehlivosti stejne / obdobne
#   jako pri pouziti prednastavene funkce?
wt <- PlantGrowth$weight
(original_mean <- mean(wt)); (original_sd <- sd(wt)); SE <- original_sd / sqrt(n)
n <- length(wt); jackknife_means <- numeric(n)
for (i in 1:n) {
  jackknife_sample <- wt[-i]
  jackknife_means[i] <- mean(jackknife_sample)
}
(jackknife_mean <- mean(jackknife_means))
(bias_jackknife <- (n - 1) * (original_mean - jackknife_mean))
(jackknife_variance <- (n - 1) * mean((jackknife_means - jackknife_mean) ^ 2))
(jackknife_se <- sqrt(jackknife_variance))
hist(jackknife_means, col = "lightgreen", main = "Jackknife Odhad Střední Hodnoty", xlab = "Střední hodnota")

num_resamples <- 1000; bootstrap_means <- numeric(num_resamples)
for (i in 1:num_resamples) {
  bootstrap_sample <- sample(wt, size = n, replace = TRUE)
  bootstrap_means[i] <- mean(bootstrap_sample)
}
(bootstrap_mean <- mean(bootstrap_means))
(bias_bootstrap <- bootstrap_mean - original_mean)
(bootstrap_variance <- var(bootstrap_means))
(bootstrap_se <- sqrt(bootstrap_variance))


hist(bootstrap_means, col = "lightblue", main = "Bootstrap Odhad Střední Hodnoty", xlab = "Střední hodnota")
cat("Originální průměr:", original_mean, "SE:", SE, "\n")
cat("Jackknife průměr:", jackknife_mean, "SE:", jackknife_se, "\n")
cat("Bootstrap průměr:", bootstrap_mean, "SE:", bootstrap_se, "\n")
quantile(bootstrap_skews,c(0.025,0.975))
BootCI(wt,FUN = Skew)
###################################
### Dvouvyberovy test
## porovnejte dva leky na spani
data("sleep") # promenna extra obsahuje informaci, o kolik se prodlouzil spanek
# Testovane hypotezy: H0: oba leky funguji stejne, H1: mezi leky je rozdil
### Klasicky postup
par(mfrow = c(1, 2)); tapply(sleep$extra, sleep$group, PlotQQ); par(mfrow = c(1, 1))# graficky test normality, vse se zda OK
var.test(sleep$extra ~ sleep$group) # test shody rozptylu, vse se zda OK
t.test(sleep$extra ~ sleep$group, var.eq = T) # na hladine vyznamnosti 5% se mezi leky neprokazal vyznamny rozdil
### Permutacni test
set.seed(101); nsim <- 9999; res <- numeric(nsim) 
# generovani permutaci pro permutacni test
for (i in 1:nsim) {
  perm <- sample(nrow(sleep))
  psleep <- transform(sleep, extra = extra[perm])
  res[i] <- mean(psleep$extra[psleep$group == 1])- mean(psleep$extra[psleep$group == 2]) # ulozim rozdil mezi prumery
}
obs <- mean(sleep$extra[sleep$group == 1]) - mean(sleep$extra[sleep$group == 2])
  # pozorovana hodnota rozdilu prumeru, pridam ji k nagenerovanym permutacnim hodnotam
res <- c(res, obs)
# zobrazeni vysledku spolu s nasi pozorovanou hodnotou
hist(res, col = "lightblue", las = 1, main = "")
abline(v = obs, col = "red") #pravděpodobnost čísla
# p-hodnota = procento vysledku v absolutni hodnote vetsi nez ten nas
mean(abs(res) >= abs(obs)) # vysledek odpovida t-testu
###################################
### Samostatne
## Zkuste si test spocitat metodou bootstrap (tj. pro vyhodnoceni nepouzit permutace, ale bootstrapove vybery)
data("sleep")
group1 <- sleep$extra[sleep$group == 1]; group2 <- sleep$extra[sleep$group == 2]
set.seed(101); nsim <- 9999; bootstrap_diffs <- numeric(nsim); n <- dim(sleep)[1]
for (i in 1:nsim) {
  boot_g1 <- sample(group1, size = length(group1), replace = TRUE)
  boot_g2 <- sample(group2, size = length(group2), replace = TRUE)
  psleep <- transform(sleep, extra = sample(group, size=n,replace = TRUE))
  bootstrap_diffs[i] <- mean(boot_g1) - mean(boot_g2)
}
(observed_diff <- mean(group1) - mean(group2))
hist(bootstrap_diffs, col = "lightblue", las = 1, main = "Bootstrap rozdíly")
abline(v = observed_diff, col = "red")
p_value <- mean(abs(bootstrap_diffs) >= abs(observed_diff))
cat("Bootstrap p-hodnota:", p_value, "\n")

## Porovnejte prvni osetreni a kontrolu u dat PlantGrowth.
#   Porovnani provedte jak klasicky, tak permutacnim testem, tak bootstrapem
data("PlantGrowth")
control <- PlantGrowth$weight[PlantGrowth$group == "ctrl"]; treatment1 <- PlantGrowth$weight[PlantGrowth$group == "trt1"]
print(t.test(control, treatment1, var.equal = TRUE))
set.seed(101); nsim <- 9999; perm_diffs <- numeric(nsim)
for (i in 1:nsim) {
  perm <- sample(c(control, treatment1))
  perm_diffs[i] <- mean(perm[1:length(control)]) - mean(perm[(length(control) + 1):length(perm)])
}
observed_diff <- mean(control) - mean(treatment1)
perm_diffs <- c(perm_diffs, observed_diff)
hist(perm_diffs, col = "lightblue", las = 1, main = "Permutační test PlantGrowth")
abline(v = observed_diff, col = "red")
p_value_perm <- mean(abs(perm_diffs) >= abs(observed_diff))
cat("Permutační p-hodnota:", p_value_perm, "\n")

set.seed(101); bootstrap_diffs <- numeric(nsim)
for (i in 1:nsim) {
  boot_ctrl <- sample(control, size = length(control), replace = TRUE)
  boot_trt1 <- sample(treatment1, size = length(treatment1), replace = TRUE)
  bootstrap_diffs[i] <- mean(boot_ctrl) - mean(boot_trt1)
}
hist(bootstrap_diffs, col = "lightblue", las = 1, main = "Bootstrap rozdíly")
abline(v = observed_diff, col = "red")
p_value_boot <- mean(abs(bootstrap_diffs) >= abs(observed_diff))
cat("Bootstrap p-hodnota:", p_value_boot, "\n")

## Porovnejte vsechny tri osetreni uvedenymi tremi zpusoby
#   Jako statistiku vyhodnocujici rozdil mezi tremi vybery muzete pouzit napr.vsum(ni * mean(Yi)^2), tj. soucet pres vsechny skupiny pocet hodnot ve skupine krat prumer skupiny na druhou
group_ctrl <- PlantGrowth$weight[PlantGrowth$group == "ctrl"]; group_trt1 <- PlantGrowth$weight[PlantGrowth$group == "trt1"]; group_trt2 <- PlantGrowth$weight[PlantGrowth$group == "trt2"]
print(aov(weight ~ group, data = PlantGrowth))
set.seed(101); nsim <- 9999; perm_stats <- numeric(nsim)
observed_stat <- sum(tapply(PlantGrowth$weight, PlantGrowth$group, function(x) length(x) * mean(x)^2))
for (i in 1:nsim) {
  perm <- sample(PlantGrowth$weight)
  perm_groups <- split(perm, PlantGrowth$group)
  perm_stats[i] <- sum(sapply(perm_groups, function(x) length(x) * mean(x)^2))
}
hist(perm_stats, col = "lightblue", las = 1, main = "Permutační test - tři skupiny")
abline(v = observed_stat, col = "red")
p_value_perm <- mean(abs(perm_stats) >= abs(observed_stat))
cat("Permutační p-hodnota pro všechny tři skupiny:", p_value_perm, "\n")

bootstrap_stats <- numeric(nsim); set.seed(101)
for (i in 1:nsim) {
  boot_ctrl <- sample(group_ctrl, size = length(group_ctrl), replace = TRUE)
  boot_trt1 <- sample(group_trt1, size = length(group_trt1), replace = TRUE)
  boot_trt2 <- sample(group_trt2, size = length(group_trt2), replace = TRUE)
  bootstrap_stats[i] <- sum(c(length(boot_ctrl) * mean(boot_ctrl)^2, length(boot_trt1) * mean(boot_trt1)^2, length(boot_trt2) * mean(boot_trt2)^2))
}
p_value_boot <- mean(abs(bootstrap_stats) >= abs(observed_stat))
cat("Bootstrap p-hodnota pro všechny tři skupiny:", p_value_boot, "\n")
###################################
library(lmPerm) # knihovna obsahujici permutacni test ve funkci lmp
res <- lmp(formula = sleep$extra ~ sleep$group)
summary(res)
