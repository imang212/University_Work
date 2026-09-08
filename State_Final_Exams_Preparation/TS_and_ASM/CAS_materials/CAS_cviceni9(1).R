####################
### Nektere dalsi moznosti casovych rad
library(fpp3); library(forecast); library(TSA)
#####################################
### Modely harmonicke regrese ( s vyuzitim fourierova rozvoje)
# vstupni data
recent_production <- aus_production |> filter(year(Quarter) >= 1992)
recent_production |> autoplot(Beer) + labs(y = "Megalitres", title = "Australian quarterly beer production") # periodicka data (kvartalni) s klesajicim trendem
# linearni model
fit_beer <- recent_production |> model(TSLM(Beer ~ trend() + season()))
report(fit_beer) # bezny zpusob modelovani trendu a sezonnosti, model: Yt = 441.8 - 0.34 * t -34.66 * Q2 - 17.82 * Q3 + 72.8 * Q4 + et  
# jak odhad sedi na data
augment(fit_beer) |> ggplot(aes(x = Quarter)) + geom_line(aes(y = Beer, colour = "Data")) + geom_line(aes(y = .fitted, colour = "Fitted")) +
  scale_colour_manual(values = c(Data = "black", Fitted = "#D55E00")) + labs(y = "Megalitres", title = "Australian quarterly beer production") + guides(colour = guide_legend(title = "Series"))
# predpovedi
fc_beer <- forecast(fit_beer)
fc_beer |>  autoplot(recent_production) + labs(title = "Forecasts of beer production using regression", y = "megalitres")
# harmonicka regrese - model pomoci clenu Fourierovy rady
fourier_beer <- recent_production |> model(TSLM(Beer ~ trend() + fourier(K = 2)))
  # pocet clenu Fourierovy rady muze byt maximalne polovina delky periody
  # ctvrtletni data: delka periody 4, tedy maximalne 2 cleny Fourierovy rady
report(fourier_beer) # model: Yt = 446.9 - 0.34 * t + 8.9 * cos(2pi*t/4) - 53.7 * sin(2pi*t/4) - 14 * cos(4pi*t/4) + et
# jak model sedi na data
augment(fourier_beer) |>
  ggplot(aes(x = Quarter)) + geom_line(aes(y = Beer, colour = "Data")) + geom_line(aes(y = .fitted, colour = "Fitted")) +
  scale_colour_manual(values = c(Data = "black", Fitted = "#D55E00")) +
  labs(y = "Megalitres", title = "Australian quarterly beer production") + guides(colour = guide_legend(title = "Series"))
# predpovedi
fc_beer <- forecast(fourier_beer)
fc_beer |> autoplot(recent_production) + labs(title = "Forecasts of beer production using regression", y = "megalitres")
# modely jsou prakticky totozne
#################################
### Kombinace harmonicke regrese a ARMA chyb
# jak vypada nahodna slozka (residua) v modelech vyse
fit_beer |> gg_tsresiduals()  # v residuich klasickeho modelu (trend + sezona) je videt periodicita
fourier_beer |> gg_tsresiduals()  # residua z modelu s fourierovymi koeficienty jsou na tom podobne/stejne
arima_fit_beer <- recent_production |> model(ARIMA(Beer ~ trend() + season() + pdq(d=0) + PDQ(D=0)))
report(arima_fit_beer) # residua tvori radu MA(1)
arima_fit_beer |> gg_tsresiduals() # kontrola residui - jsou lepsi
arima_fourier_beer <- recent_production |> model(ARIMA(Beer ~ trend() + fourier(K = 2) + pdq(d=0) + PDQ(D=0)))
report(arima_fourier_beer) # i zde residua tvori radu MA(1)
arima_fourier_beer |> gg_tsresiduals() # kontrola residui - jsou lepsi
#################################
# vstupni data - naklady na jidlo v Autralii
aus_cafe <- aus_retail |>
  filter(Industry == "Cafes, restaurants and takeaway food services", year(Month) %in% 2004:2018) |>
  summarise(Turnover = sum(Turnover))
aus_cafe |> autoplot(Turnover) + labs(y = "$ billions", title = "Australian eating out expenditure") # mesicni periodicka data s rostoucim trendem
# mesicni data maji delku periody 12, mohu tedy uvazovat az 6 clenu Fourierovy rady ale kolik jich skutecne potrebuji?
# 6 modelu vyuzivajicich az 6 clenu fourierovy rady nahodna slozka rady je modelovana jako ARMA model bez periodicke casti
fit <- model(aus_cafe, 
             `K = 1` = ARIMA(log(Turnover) ~ fourier(K=1) + PDQ(0,0,0)),
             `K = 2` = ARIMA(log(Turnover) ~ fourier(K=2) + PDQ(0,0,0)),
             `K = 3` = ARIMA(log(Turnover) ~ fourier(K=3) + PDQ(0,0,0)),
             `K = 4` = ARIMA(log(Turnover) ~ fourier(K=4) + PDQ(0,0,0)),
             `K = 5` = ARIMA(log(Turnover) ~ fourier(K=5) + PDQ(0,0,0)),
             `K = 6` = ARIMA(log(Turnover) ~ fourier(K=6) + PDQ(0,0,0)))
report(fit) # porovnani modelu
fit |>
  forecast(h = "2 years") |>
  autoplot(aus_cafe, level = 95) +
  facet_wrap(vars(.model), ncol = 2) +
  guides(colour = "none", fill = "none", level = "none") +
  geom_label(aes(x = yearmonth("2007 Jan"), y = 4250, label = paste0("AICc = ", format(AICc))), data = glance(fit)) +
  labs(title= "Total monthly eating-out expenditure", y="$ billions") # vykresleni vylepsujici se predikce
# nejlepsi model
fit_best <- model(aus_cafe, ARIMA(log(Turnover) ~ fourier(K=6) + PDQ(0,0,0))); report(fit_best) # jak vypada model?
############################
### Vicenasobna (dvojita) perioda v rade 
# vstupni data - telefonaty do banky
bank_calls |> fill_gaps() |> autoplot(Calls) + labs(y = "Calls", title = "Five-minute call volume to bank")
calls <- bank_calls |>
  mutate(t = row_number()) |>
  update_tsibble(index = t, regular = TRUE)
  # v datech jsou chybejici hodnoty mimo pracovni dobu - vynechame je
# dekompozice rady na trend, prvni sezonnost a druhou sezonnost
calls |>
  model(STL(sqrt(Calls) ~ season(period = 169) + season(period = 5*169), robust = TRUE)) |>
  components() |> autoplot() + labs(x = "Observation")
## Porovnani predpovedi z dekompozice + exponencialniho vyrovnani a harmonicke regrese
# dekompozice + exponencialni vyrovnani
my_dcmp_spec <- decomposition_model(STL(sqrt(Calls) ~ season(period = 169) + season(period = 5*169), robust = TRUE), ETS(season_adjust ~ season("N")))
# predpovedi
fc <- calls |> model(my_dcmp_spec) |> forecast(h = 5 * 169)
# Priprava dat pro vykresleni (pridani chybejicich hodnot)
fc_with_times <- bank_calls |>
  new_data(n = 7 * 24 * 60 / 5) |>
  mutate(time = format(DateTime, format = "%H:%M:%S")) |>
  filter(time %in% format(bank_calls$DateTime, format = "%H:%M:%S"), wday(DateTime, week_start = 1) <= 5) |>
  mutate(t = row_number() + max(calls$t)) |>
  left_join(fc, by = "t") |>
  as_fable(response = "Calls", distribution = Calls)
# Vykresleni predpovedi na 3 tydny
fc_with_times |>
  fill_gaps() |>
  autoplot(bank_calls |> tail(14 * 169) |> fill_gaps()) + labs(y = "Calls", title = "Five-minute call volume to bank")
# harmonicka regrese - vyplati se pri dlouhych periodach (jine postupy na nich kolabuji)
fit <- calls |> model(dhr = ARIMA(sqrt(Calls) ~ PDQ(0, 0, 0) + pdq(d = 0) + fourier(period = 169, K = 10) + fourier(period = 5*169, K = 5)))
# predpovedi
fc <- fit |> forecast(h = 5 * 169)
# Priprava dat pro vykresleni (pridani chybejicich hodnot)
fc_with_times <- bank_calls |>
  new_data(n = 7 * 24 * 60 / 5) |>
  mutate(time = format(DateTime, format = "%H:%M:%S")) |>
  filter(time %in% format(bank_calls$DateTime, format = "%H:%M:%S"), wday(DateTime, week_start = 1) <= 5) |>
  mutate(t = row_number() + max(calls$t)) |>
  left_join(fc, by = "t") |>
  as_fable(response = "Calls", distribution = Calls)
# Vykresleni predpovedi na 3 tydny
fc_with_times |>
  fill_gaps() |>
  autoplot(bank_calls |> tail(14 * 169) |> fill_gaps()) + labs(y = "Calls", title = "Five-minute call volume to bank")
################ 
# vstupni data: zavislost spotreby el.energie na teplote
vic_elec |>
  pivot_longer(Demand:Temperature, names_to = "Series") |>
  ggplot(aes(x = Time, y = value)) + geom_line() + facet_grid(rows = vars(Series), scales = "free_y") + labs(y = "")
# pridani pracovnich dni
elec <- vic_elec |>
  mutate(DOW = wday(Date, label = TRUE), Working_Day = !Holiday & !(DOW %in% c("Sat", "Sun")), Cooling = pmax(Temperature, 18))
elec |> ggplot(aes(x=Temperature, y=Demand, col=Working_Day)) + geom_point(alpha = 0.6) + labs(x="Temperature (degrees Celsius)", y="Demand (MWh)")
# harmonicky model
## pozor, velka data - bezi dlouho!!!
fit <- elec |> model(ARIMA(Demand ~ PDQ(0, 0, 0) + pdq(d = 0) + Temperature + Cooling + Working_Day + fourier(period = "day", K = 7) +
            fourier(period = "week", K = 4) + fourier(period = "year", K = 2)))
# priprava dat pro vypocet predpovedi
elec_newdata <- new_data(elec, 2*48) |>
  mutate(Temperature = tail(elec$Temperature, 2 * 48), Date = lubridate::as_date(Time), DOW = wday(Date, label = TRUE),
    Working_Day = (Date != "2015-01-01") & !(DOW %in% c("Sat", "Sun")), Cooling = pmax(Temperature, 18))
# predpovedi
fc <- fit |> forecast(new_data = elec_newdata)
fc |> autoplot(elec |> tail(10 * 48)) + labs(title="Half hourly electricity demand: Victoria", y = "Demand (MWh)", x = "Time [30m]")
#####################################
recent_elec <- aus_production |> 
  filter(year(Quarter) >= 1992) |> 
  select(Quarter, Electricity)
recent_elec |> autoplot(Electricity) + labs(y = "GWh", title = "Australian quarterly electricity production")
#fit_el_fourier <- recent_elec |> 
#  model(dhr = TSLM(Electricity ~ trend() + fourier(K = 2)))
#Harmonická regrese pomocí TSLM (Trend + Fourierovy členy), Pro kvartální data (perioda 4) je maximální K = 2
fit_el_fourier <- recent_elec |> model(TSLM(Electricity ~ trend() + fourier(K=2))); report(fit_el_fourier)
augment(fit_el_fourier) |>
  ggplot(aes(x = Quarter)) + geom_line(aes(y = Electricity, colour = "Data")) + geom_line(aes(y = .fitted, colour = "Fitted")) +
  scale_colour_manual(values = c(Data = "black", Fitted = "#D55E00")) +
  labs(y = "GWh", title = "Fitted values: Electricity production (Fourier K=2)")
# Kombinace harmonické regrese a ARIMA chyb (přesnější model), TSLM často nechává v reziduích autokorelaci, ARIMA se o ni postará
fit_el_arima <- recent_elec |> model(arima_dhr = ARIMA(Electricity ~ trend() + fourier(K = 2) + PDQ(0,0,0))); report(fit_el_arima)
fit_el_arima |> gg_tsresiduals()
fc_el <- fit_el_arima |> forecast(h = "2 years")
fc_el |> autoplot(recent_elec) + labs(title = "Forecast of Electricity production (ARIMA + Fourier)", y = "GWh")
#####################################
## periodogram - hledani cyklu
plot(lynx) # data s evidentnimi cykly, ale nejedna se o sezonni data (rocni data)
n <- length(lynx)
FF <- abs(fft(lynx)/sqrt(n))^2 # Fast Discrete Fourier Transform
P <- (4/n)*FF[1:(n/2 + 1)] # potrebujeme prvnich (n/2)+1 hodnot FFT transformace
P <- P[-1] # prvni hodnota je nesmyslna
f <- (0:(n/2))/n # this creates harmonic frequencies from 0 to .5 in steps of 1/n.
f <- f[-1]
plot(f, P, type = "h") # periodogram rucne
(fr.max <- f[which.max(P)]) # frekvence s maximalni hodnotou periodogramu
1/fr.max
per <- periodogram(lynx)
per$freq; per$spec
(fr.max <- per$freq[which.max(per$spec)]) # frekvence s maximalni hodnotou periodogramu
1/fr.max # delka cyklu 10 let
############################
### Samostatne 
# hledejte delku cyklu pro slunecni aktivitu
data("sunspots")
# mesicni data
plot(sunspots)
per <- periodogram(sunspots)
# Nalezení dominantní frekvence, Index frekvence s nejvyšší hodnotou spektra
idx <- which.max(per$spec)
fr_max <- per$freq[idx]
cycle_months <- 1 / fr_max # Výpočet délky cyklu
cycle_years <- cycle_months / 12
# Výpis výsledků
cat("Dominantní frekvence:", fr_max, "\n", "Délka cyklu v měsících:", cycle_months, "\n", "Délka cyklu v letech:", cycle_years, "\n")

