#### Preamble ####
# Purpose: Build all models needed 
# Author: Yiyi Feng
# Date: 27 November 2024
# Contact: yiyi.feng@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - The `tidyverse`, `randomForest` and `arrow` package must be installed and loaded
# - 02-clean_data.R must have been run
# Any other information needed? No

#### Workspace setup ####
library(tidyverse)
library(randomForest)
library(arrow)


#### Read data ####
model_data <- read_parquet("data/02-analysis_data/combined_model_data.parquet")


# 1. Preprocess the data: Ensure categorical variables are factors
model_data <- model_data %>%
  mutate(
    vendor = as.factor(vendor),
    category = as.factor(category),
    flavor = as.factor(flavor),
    month = as.factor(month)  # Month as a factor for modeling
  )

# 2. Create the target variable: Change in average price (monthly_avg_price - previous month's price)
# Sort by id and month
model_data <- model_data %>%
  arrange(id, month)

# Calculate the change in price (current month - previous month) for each product
model_data <- model_data %>%
  group_by(id) %>%
  mutate(price_change = monthly_avg_price - lag(monthly_avg_price)) %>%
  ungroup()

# We need to remove rows where price_change is NA (because there's no previous month for those)
model_data <- model_data %>%
  filter(!is.na(price_change))

# 3. Train the Random Forest model to predict the change in average price
# We'll use vendor, category, month, and rainfall (avg_rainfall) as predictors

rf_model <- randomForest(price_change ~ vendor + category + month + avg_rainfall, 
                         data = model_data, 
                         na.action = na.roughfix,   # Automatically handles NAs by imputing
                         importance = TRUE)


# 1. Train a linear regression model
lm_model_1 <- lm(price_change ~ vendor + category  + month + avg_rainfall, data = model_data)

# 1. Train a linear regression model
lm_model_2 <- lm(price_change ~ vendor + category  * month + avg_rainfall, data = model_data)

# 1. Train a linear regression model
lm_model_3 <- lm(price_change ~ vendor + category  + month * avg_rainfall, data = model_data)

# 1. Train a linear regression model
lm_model_4 <- lm(price_change ~ vendor + month + category  * avg_rainfall, data = model_data)

# 1. Train a linear regression model
lm_model_5 <- lm(price_change ~ vendor * category  + month + avg_rainfall, data = model_data)

#### Save model ####
saveRDS(rf_model, file = "models/model_rf.rds")
saveRDS(lm_model_1, file = "models/model_linear_1.rds")
saveRDS(lm_model_2, file = "models/model_linear_2.rds")
saveRDS(lm_model_3, file = "models/model_linear_3.rds")
saveRDS(lm_model_4, file = "models/model_linear_4.rds")
saveRDS(lm_model_5, file = "models/model_linear_5.rds")



