# Load necessary libraries and data
library(readxl)
cps_data <- read_excel("cps09mar.xlsx")

# Inspect the structure and summary of the dataset
str(cps_data)

# Create the lwage column by taking the logarithm of earnings
cps_data$lwage <- log(cps_data$earnings)

# Calculate labor market experience (exper) using age
cps_data$exper <- cps_data$age - cps_data$education

# Create binary indicator for African-American (black) individuals
cps_data$black <- ifelse(cps_data$race == 2, 1, 0)




# Define design matrix X and response vector y
X <- model.matrix(~ education + exper + I(exper^2) + female + black, data = cps_data)
y <- log(cps_data$lwage)  # Logarithm of hourly wage

# Estimate coefficients using OLS
beta_hat <- solve(t(X) %*% X) %*% t(X) %*% y


# Define matrix X1 (predictors) and vector y1 (response)
X1 <- model.matrix(~ education + exper + I(exper^2) + black, data = cps_data)
y1 <- cps_data$female

# Estimate coefficients for 'female'
beta1 <- solve(t(X1) %*% X1) %*% t(X1) %*% y1
predicted_female <- X1 %*% beta1
residuals_female <- y1 - predicted_female



# Define matrix X2 (predictors) excluding 'female' and vector y2 (response)
X2 <- model.matrix(~ education + exper + I(exper^2) + black, data = cps_data)
X2_excl_female <- X2[, -which(colnames(X2) == "(Intercept)female")]
y2 <- log(cps_data$lwage)

# Estimate coefficients for 'lwage' without 'female'
beta2 <- solve(t(X2_excl_female) %*% X2_excl_female) %*% t(X2_excl_female) %*% y2
predicted_lwage_excl_female <- X2_excl_female %*% beta2
residuals_lwage_excl_female <- y2 - predicted_lwage_excl_female


# Define vectors of residuals
e1 <- residuals_lwage

