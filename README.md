# Labor Market Dynamics: Predicting Unemployment with Jobless Claims

This project analyzes the relationship between Initial Insurance Claims (ICSA) and the Monthly Unemployment Rate. 
Using time-series econometrics in R, I demonstrate that weekly jobless claims are a strong flow variable that can accurately forecast shifts in the stock variable of unemployment.

Goal: To determine if high-frequency claims data can provide early warnings for monthly unemployment changes.
Methodology: Autoregressive Distributed Lag (ADL) models using the `dynlm` package.
Validation: Out-of-Sample testing (training on 1990–2005 data; testing on 2006–2024).

Findings
1. Initial claims alone explain up to 77% of the monthly variation in the unemployment rate.
2. The model captures a dynamic pattern—current claims drive unemployment up immediately, while claims from two months prior have a stabilizing downward pressure.
3. In out-of-sample testing, a 2-lag claims model outperformed more complex autoregressive models, achieving the lowest RMSE (0.3847).
4. The model projected a decline in the unemployment rate from 3.8% to 3.72.

R Packages:`fredr`, `dynlm`, `timetk`, `zoo`
Techniques: Time-series differencing, Lagged variables, OLS Regression, Out-of-Sample validation, RMSE calculation.


How to Run
1. Obtain an API key from [FRED](https://fred.stlouisfed.org/docs/api/api_key.html).
2. Replace `'Your Authentification Code'` in the script with your key.
3. Run the script to generate the RMSE table and final forecast.




# Urban Labor & Macroeconomic Analytics

## Overview
This repository contains a suite of labor market analyses focusing on both micro-dynamics and national macroeconomic forecasting.

### Project 1: National Unemployment Forecasting (FRED)
A time-series project using Initial Jobless Claims to predict the US Unemployment Rate.
* **Methodology:** Distributed Lag Models & Out-of-Sample RMSE Validation.

### Project 2: NYC Census Analysis (CPS)
An investigation into the Education Premium and labor market stability for NYC residents. Replicates the BLS framework using weighted microdata.
* **Visuals:** [Education vs. Earnings/Unemployment](visuals/nyc_education_premium_comparison.png)

---
## Featured Results

### The Stability Premium of Higher Education (NYC)
![NYC Education Premium](visuals/nyc_education_premium_comparison.png)

### NYC Unemployment Trend (2015-2025)
![NYC Unemployment Trend](visuals/nyc_unemployment_trend_2015_2025.png)

---

## Tech Stack
* **R:** `tidyverse`, `srvyr`, `dynlm`, `plm`, `Hmisc`
* **APIs:** IPUMS-CPS, FRED (Federal Reserve)
* **Visuals:** High-resolution (300 DPI) exports via `ggplot2` and `gridExtra`.

---
**Author:** Haya Adleh
