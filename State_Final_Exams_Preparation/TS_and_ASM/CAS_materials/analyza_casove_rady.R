install.packages("riingo")
library(riingo); library(ggplot2); library(dplyr)
devtools::install_github("DavisVaughan/riingo")
riingo_set_token("5f75dccb7429296763de041131ffdce9cd89622a")
apple_data <- riingo_prices("AAPL")
head(apple_data)
#analýza apple cen
apple_data <- riingo_prices("AAPL", start_date = "1990-01-01", end_date = "2023-12-31")
head(apple_data)

ggplot(apple_data, aes(x = date, y = adjClose)) + geom_line(color = "blue") + labs(title = "Denní uzavírací ceny AAPL", x = "Datum", y = "Upravená cena") + theme_minimal()
# Přidáme 20denní klouzavý průměr
apple_ma <- apple_data %>% arrange(date) %>% mutate(ma20 = zoo::rollmean(adjClose, k = 20, fill = NA))
apple_data.rm3 <- rollmean(apple_data.ts, 3); apple_data.rm5 <- rollmean(apple_data, 5); apple_data.rm7 <- rollmean(apple_data.ts, 7); apple_data.rm9 <- rollmean(apple_datats, 9); apple_datas.rm11 <- rollmean(kings.ts, 11) # pro krajni body odhady nejsou
# Vizualizace ceny a klouzavého průměru
ggplot(apple_ma, aes(x = date)) + geom_line(aes(y = adjClose), color = "darkblue", size = 1, alpha = 0.8) + geom_line(aes(y = ma20), color = "orange", size = 1) + labs(title = "AAPL: Cena vs. 20denní klouzavý průměr", x = "Datum", y = "Cena") + theme_minimal()
#analýza proměnné high u apple cen
(apple_data.ts <- ts(apple_data["high"],  start = c(1950), end = c(2023)))
head(apple_data.ts)
plot(apple_data.ts)
apple_data.rm3 <- rollmean(apple_data.ts, 3); apple_data.rm5 <- rollmean(apple_data.ts, 5); apple_data.rm7 <- rollmean(apple_data.ts, 7); apple_data.rm9 <- rollmean(apple_data.ts, 9); apple_data.rm11 <- rollmean(apple_data.ts, 11) # pro krajni body odhady nejsou
lines(apple_data.rm3, col = 2); 
lines(apple_data.rm5, col = 3); 
lines(apple_data.rm7, col = 4); 
lines(apple_data.rm9, col = 5); 
lines(apple_data.rm11, col = 6)
#korelační test
index <- 1:length(apple_data.ts)
cor.test(apple_data.ts, index, method = "kendall")
(fit.a <- auto.arima(apple_data.ts, seasonal = F))
(fit.b <- auto.arima(apple_data.ts, seasonal = F, ic = "bic"))
par(mfrow = c(2,1)); acf(residuals(fit.a), na.action = na.pass); pacf(residuals(fit.a), na.action = na.pass); par(mfrow = c(1,1))
plot(apple_data.ts)
lines(fitted(fit.a),col=2) 
(for.fit5 <- forecast(fit.a)) # predpoved s intervalem spolehlivosti
predict(fit.a, 10) # predpoved bez intervalu spolehlivosti pouze se stredni chybou
plot(for.fit5) 