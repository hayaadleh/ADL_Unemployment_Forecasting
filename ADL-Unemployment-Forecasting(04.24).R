rm(list=ls())
library(fredr)
library(dynlm)
library(timetk)

# Authenticate with the FRED API using a personal access key
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

# ---- Perform Out-of-Sample Validation to see how well the models actually predict future data.

# Use the first 15 years to build (estimate) the models
data1 = window(data, start = "1990-01-01", end = "2005-12-01")
# Use the remaining years to test how well the models predict unseen data
data2 = window(data, start = "2006-01-01", end = "2024-03-01")

# Models 01-03: Only use Claims (with 0, 1, or 2 lags)
mod01 = dynlm( diff(Unempl) ~ L(Claims,0),   data=data1)
mod02 = dynlm( diff(Unempl) ~ L(Claims,0:1), data=data1)
mod03 = dynlm( diff(Unempl) ~ L(Claims,0:2), data=data1)

# Models 11-13: Use Claims PLUS the previous month's Unemployment change (AR term)
mod11 = dynlm( diff(Unempl) ~ L(diff(Unempl),1) + L(Claims,0),   data=data1)
mod12 = dynlm( diff(Unempl) ~ L(diff(Unempl),1) + L(Claims,0:1), data=data1)
mod13 = dynlm( diff(Unempl) ~ L(diff(Unempl),1) + L(Claims,0:2), data=data1)

# Y is the target we are trying to predict
Y  = diff(data2$Unempl)
# X1 creates a matrix of current and lagged claims for the test period
X1 = merge(lag(data2$Claims,0), lag(data2$Claims,-1), lag(data2$Claims,-2))
# X2 adds the lagged unemployment change to the matrix
X2 = merge(lag(diff(data2$Unempl),-1), X1)

# Clean and format matrices for prediction
YX = merge(Y, X2)
YX = as.matrix(window(YX, start = "2006-01-01", end = "2024-03-01"))
y  = YX[,1]             # Column 1: The actual observed unemployment change
X1 = cbind(1, YX[,3:5]) # Matrix for models without AR term (Intercept + Claims lags)
X2 = cbind(1, YX[,2:5]) # Matrix for models with AR term (Intercept + AR + Claims lags)

# Multiply the historical coefficients by the new data to see what the model expects
pred01 = X1 %*% c(mod01$coef, 0, 0)
pred02 = X1 %*% c(mod02$coef, 0)
pred03 = X1 %*% c(mod03$coef)
pred11 = X2 %*% c(mod11$coef, 0, 0)
pred12 = X2 %*% c(mod12$coef, 0)
pred13 = X2 %*% c(mod13$coef)

# ----- Calculate the forecast accuracy of models -----

# Subtract predicted values from actual values (y) to find the residuals (errors)
err01 = y-pred01
err02 = y-pred02
err03 = y-pred03

err11 = y-pred11
err12 = y-pred12
err13 = y-pred13

# Compute RMSE (Root Mean Square Error) 
# RMSE measures average forecast error; smaller values mean a more accurate model
rmse01 = sqrt( mean( err01^2, na.rm=TRUE ) )
rmse02 = sqrt( mean( err02^2, na.rm=TRUE) )
rmse03 = sqrt( mean( err03^2, na.rm=TRUE) ) # Winner: 0.384

rmse11 = sqrt( mean( err11^2, na.rm=TRUE) )
rmse12 = sqrt( mean( err12^2, na.rm=TRUE) )
rmse13 = sqrt( mean( err13^2, na.rm=TRUE) )

# Compare Results
# Organize RMSEs into a table to find the model with the lowest error
table = rbind( c(rmse01,rmse02,rmse03), c(rmse11,rmse12,rmse13) )
print(table) 
# The result 0.3847 shows that mod03 (Claims only, 2 lags) performed best out-of-sample

# Final Prediction for April 2024
# Re-estimate the winning model (mod03) on the full dataset
mod = dynlm( diff(Unempl) ~ L(Claims,0:2), data = data )

# Calculate the forecast: (Previous Month Rate) + (Predicted Change)
# Predicts a drop from 3.8% down to approx 3.72% using recent claims data
forcast = 3.8 + mod$coef %*% c(1, 211000, 213600, 209250)
print(forcast)





