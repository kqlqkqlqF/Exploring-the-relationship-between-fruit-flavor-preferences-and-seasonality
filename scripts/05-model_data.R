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


# use vendor, category, month, and rainfall (avg_rainfall) as predictors

rf_model <- randomForest(price_change ~ vendor + category + month + avg_rainfall + flavor, 
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



