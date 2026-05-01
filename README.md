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
