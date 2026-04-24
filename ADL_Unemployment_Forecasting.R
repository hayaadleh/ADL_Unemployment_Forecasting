rm(list=ls())
library(fredr)
library(dynlm)
library(timetk)

# Part 2: Authenticate with the FRED API using a personal access key
fredr_set_key('Your Authentification Code')

# Download monthly and weekly unemployment claims and the monthly unemployment rate
Claims <-fredr(series_id = "ICSA",frequency = "m", observation_start=as.Date("1990-01-01
"), observation_end=as.Date("2024-04-01"))

Unempl <-fredr( series_id = "UNRATE",frequency = "m", observation_start=as.Date("1990-01-01
"), observation_end=as.Date("2024-04-01"))

Claims_w <-fredr( series_id = "ICSA",frequency = "w", observation_start=as.Date("1990-01-01
"), observation_end=as.Date("2024-04-01"))
tail(Claims_w)

# Convert data to time-series format (zoo) and merge into a single dataset with clean column names
Claims = tk_zoo_(Claims)
Unempl = tk_zoo_(Unempl)
data = merge(Claims,Unempl)
colnames(data) <- c("Claims", "Unempl")

head(data)
# In January 1990, the unemployment rate was 5.4%
tail(data)
# In January 2024, the unemployment rate was 3.7%

# Predicting changes in the unemployment rate using jobless claims is a good 
# strategy because claims reflect a flow variable, capturing the immediate influx 
# of individuals filing for unemployment benefits each week or month.

# By tracking the flow of jobless claims, policymakers and economists can anticipate 
# changes in the labor market before they reflect in the stock variable of the unemployment rate

# ---- Model 1: Do changes in unemployment this month move with the number of initial unemployment claims? 
mod1 = dynlm( diff(Unempl) ~ L(Claims,0),   data=data)
summary(mod1)
# Initial unemployment claims are a strong and statistically significant predictor 
# of changes in the unemployment rate explaining about 37% of the variation in monthly unemployment changes.


# ---- Model 2: Do current unemployment claims and last month’s claims together explain changes in unemployment?
mod2 = dynlm( diff(Unempl) ~ L(Claims,0:1), data=data)
summary(mod2)
# As claims increase this month, unemployment increases.
# Yet, as claims increase last month, unemploymnet decreases this month.
  # This could suggest corrections/reversals. But the models R-squared increases 
  # from the last model, from 37% to 63%.

# ---- Model 3: Can current and the past two months' unemployment claims predict this month's change in unemployment?
mod3 = dynlm( diff(Unempl) ~ L(Claims,0:2), data=data)
summary(mod3)
# This model explains 77% of unemployment changes, showing that new claims cause 
# an immediate spike while past claims lead to a reversal.It suggests that the initial 
# shock of job losses is followed by a stabilizing period over the next two months.


#  --- Model 1B: Does last month's unemployment change plus current claims predict this month's unemployment change?
mod1 = dynlm( diff(Unempl) ~ L(diff(Unempl),1) + L(Claims,0),   data=data)
summary(mod1)
# The lagged change has a negative coefficient (-0.162), suggesting mean reversion, 
# while current claims positively predict unemployment increases; however, this model 
# only explains 40% of variation (R² = 0.40).

#  --- Model 2B: Does adding both current and lagged claims, plus the autoregressive term, improve predictions?
mod2 = dynlm( diff(Unempl) ~ L(diff(Unempl),1) + L(Claims,0:1), data=data)
summary(mod2)
# This specification  improves performance (R² = 0.68), and the lagged 
# unemployment change coefficient flips positive (+0.285), suggesting effects 
# once we control for the claims pattern; current claims increase unemployment while last month's claims decrease it.

#  --- Model 2B: Does extending to two lags of claims with the autoregressive term capture the full dynamic relationship?
mod3 = dynlm( diff(Unempl) ~ L(diff(Unempl),1) + L(Claims,0:2), data=data)
summary(mod3)
# This achieves the best fit yet (R² = 0.78), with the lagged unemployment change 
# returning to negative (-0.246, mean reversion), though the middle claims lag (t-1) 
# becomes marginally insignificant (p = 0.098) while current and two-month-old claims remain highly 
# significant with the expected positive/negative pattern.



