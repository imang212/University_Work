
if(!"sets" %in% row.names(installed.packages()))
  install.packages("sets")
library(sets)

# Membership functions example
p1 <- fuzzy_normal_gset(universe = seq(-3,3,0.1))
p2 <- fuzzy_sigmoid_gset( slope = 1.8, universe = seq(-3,3,0.1))
p3 <- fuzzy_trapezoid_gset(corner = c(-2,0,1,3), universe = seq(-3,3,0.1))
p4 <- fuzzy_triangular_gset(corner = c(-1,0,2), universe = seq(-3,3,0.1))

png(filename = 'Fig_3.png', width = 7500, height = 5500, res = 600)
par(mfrow = c(2,2))
par(omi=c(0.2,0.4,0.2,0.4),mai=c(1,1,0.6,0.1),lheight =1.15,las=0)
par(cex = 1.2, cex.axis = 1.2, cex.lab = 1.2, cex.main = 1.4, bg = 'white')
plot(p1)
title("a) Gaussian membership function")
plot(p2)
title("b) Sigmoidal membership function")
plot(p3)
title("c) Trapezoidal membership function")
plot(p4)
title("d) Triangular membership function")
dev.off()

#Linguistic variables formation
variables <- set(
  service = fuzzy_variable(
    poor = fuzzy_trapezoid_gset(corners=c(-2,0,1,3),universe = seq(0,10,0.01)),
    good = fuzzy_cone_gset(center = 5, radius = 3,universe = seq(0,10,0.01)),
    exellent = fuzzy_trapezoid_gset(corners=c(7,9,10,12),universe = seq(0,10,0.01))),
  food = fuzzy_variable(
    rancid = fuzzy_trapezoid_gset(corners=c(-2,0,2,4),universe = seq(0,10,0.01)),
    delicios = fuzzy_trapezoid_gset(corners=c(6,8,10,12),universe = seq(0,10,0.01))),
  tips = fuzzy_variable(
    cheap = fuzzy_trapezoid_gset(corners=c(-5,0,5,10),universe = seq(0,30,0.1)),
    average = fuzzy_cone_gset(center = 15, radius = 5,universe = seq(0,30,0.1)),
    generous = fuzzy_trapezoid_gset(corners=c(20,25,30,35),universe = seq(0,30,0.1)))
)

#Fuzzy rules
rules <- set(
  fuzzy_rule(service %is% poor || food %is% rancid, tips %is% cheap),
  fuzzy_rule(service %is% good, tips %is% average),
  fuzzy_rule(service %is% exellent || food %is% delicious, tips %is% generous)
)

#Greate system
tips_fuzzy_system <- fuzzy_system(variables, rules)

#vizualization
print(tips_fuzzy_system)
plot(tips_fuzzy_system)

png(filename = 'Fig_8.png', width = 5000, height = 3000, res = 600)
par(mfrow = c(1,1))
par(omi=c(0.2,0.4,0.2,0.4),mai=c(0.8,0.8,0.5,0.1),lheight =1.15,las=0)
par(cex = 1.2, cex.axis = 1.2, cex.lab = 1.2, cex.main = 1.4, bg = 'white')
plot(tips_fuzzy_system)
dev.off()

#operate of fuzzy inference system
rez1 <- fuzzy_inference(tips_fuzzy_system, list(service = 0, food = 0))
rez2 <- fuzzy_inference(tips_fuzzy_system, list(service = 4, food = 6))
rez3 <- fuzzy_inference(tips_fuzzy_system, list(service = 7, food = 2))
rez4 <- fuzzy_inference(tips_fuzzy_system, list(service = 10, food = 10))
t1 = gset_defuzzify(rez1, method = "centroid")
t2 = gset_defuzzify(rez2, method = "centroid")
t3 = gset_defuzzify(rez3, method = "centroid")
t4 = gset_defuzzify(rez4, method = "centroid")

png(filename = 'Fig_9.png', width = 7500, height = 5500, res = 600)
par(mfrow = c(2,2))
par(omi=c(0.2,0.4,0.2,0.4),mai=c(1,1,0.6,0.1),lheight =1.15,las=0)
par(cex = 1.2, cex.axis = 1.2, cex.lab = 1.2, cex.main = 1.4, bg = 'white')
plot(rez1)
title("a) Servise = 0, food = 0, tips = 3.86%")
plot(rez2)
title("b) Servise = 4, food = 6, tips = 15%")
plot(rez3)
title("c) Servise = 7, food = 2, tips = 6.86%")
plot(rez4)
title("d) Servise = 10, food = 10, tips = 26.14%")
dev.off()

# Function to return crisp output parameter value
infer <- function(s, f){
  res <- fuzzy_inference(tips_fuzzy_system, list(service = s, food = f))
  return (gset_defuzzify(res, method = "centroid"))
}

infer(9,8)

