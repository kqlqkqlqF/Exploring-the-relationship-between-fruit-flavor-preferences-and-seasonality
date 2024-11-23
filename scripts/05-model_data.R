#### Preamble ####
# Purpose: Build all models needed for predicting the 2024 US Presidential Election
# Author: Bo Tang, Yiyi Feng, Mingjing Zhan
# Date: 2 November 2024
# Contact: qinghe.tang@mail.utoronto.ca, yiyi.feng@mail.utoronto.ca, mingjin.zhan@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - The `tidyverse` and rstanarm` package must be installed and loaded
# - 02-clean_data.R must have been run
# Any other information needed? Make sure you are in the `Insights and Predictions for the U.S. Election` rproj


#### Workspace setup ####
library(tidyverse)
library(rstanarm)

#### Read data ####
analysis_data <- read_parquet("data/02-analysis_data/cleaned_data.parquet")

### Model data ####
model1 <- lm(pct ~ sample_size + pollscore + numeric_grade + state, 
                   data = analysis_data)

model2 <- lm(pct ~ sample_size + pollscore + numeric_grade + recency_weight + 
                   state, data = analysis_data)

model3 <- lm(pct ~ candidate_name + sample_size + pollscore + numeric_grade + 
                   recency_weight + state,
                   data = analysis_data)

model4 <- lm(pct ~ candidate_name * state + recency_weight + sample_size + 
                   pollscore + numeric_grade,
                   data = analysis_data)

model5 <- lm(pct ~ candidate_name * recency_weight * state + sample_size + 
                   pollscore + numeric_grade,
                   data = analysis_data)

#### Save model ####
saveRDS(model1, file = "models/model1.rds")
saveRDS(model2, file = "models/model2.rds")
saveRDS(model3, file = "models/model3.rds")
saveRDS(model4, file = "models/model4.rds")
saveRDS(model5, file = "models/model5.rds")



