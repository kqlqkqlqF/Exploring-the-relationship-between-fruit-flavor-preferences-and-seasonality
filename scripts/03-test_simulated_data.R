#### Preamble ####
# Purpose: Tests the structure and validity of the simulated data
  #electoral divisions dataset.
# Author: Bo Tang, Yiyi Feng, Mingjing Zhan
# Date: 2 November 2024
# Contact: qinghe.tang@mail.utoronto.ca, yiyi.feng@mail.utoronto.ca, mingjin.zhan@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
  # - The `tidyverse` package must be installed and loaded
  # - 00-simulate_data.R must have been run
# Any other information needed? Make sure you are in the `Insights and Predictions for the U.S. Election` rproj


#### Workspace setup ####
library(tidyverse)

analysis_data <- read_parquet("data/00-simulated_data/simulated_data.parquet")

# Test if the data was successfully loaded
if (exists("analysis_data")) {
  message("Test Passed: The dataset was successfully loaded.")
} else {
  stop("Test Failed: The dataset could not be loaded.")
}


#### Test data ####

# Check if the dataset has 1000 rows
if (nrow(analysis_data) == 1000) {
  message("Test Passed: The dataset has 1000 rows.")
} else {
  stop("Test Failed: The dataset does not have 1000 rows.")
}

# Check if the dataset has 10 columns
if (ncol(analysis_data) == 10) {
  message("Test Passed: The dataset has 10 columns.")
} else {
  stop("Test Failed: The dataset does not have 10 columns.")
}

# Check if all values in the 'division' column are unique
if (n_distinct(analysis_data$poll_id) == nrow(analysis_data)) {
  message("Test Passed: All values in 'poll_id' are unique.")
} else {
  stop("Test Failed: The 'poll_id' column contains duplicate values.")
}

# Check if the 'state' column contains only valid Australian state names
valid_states <- c("AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA","HI","ID",
                  "IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS",
                  "MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK"
                  ,"OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV",
                  "WI","WY")

if (all(analysis_data$state %in% valid_states)) {
  message("Test Passed: The 'state' column contains only valid U.S state names.")
} else {
  stop("Test Failed: The 'state' column contains invalid state names.")
}

# Check if the 'party' column contains only valid party names
valid_name <- c("Trump", "Harris")

if (all(analysis_data$candidate_name %in% valid_name)) {
  message("Test Passed: The 'candidate_name' column contains only valid candidate names.")
} else {
  stop("Test Failed: The 'candidate_name' column contains invalid candidate names.")
}

# Check if there are any missing values in the dataset
if (all(!is.na(analysis_data))) {
  message("Test Passed: The dataset contains no missing values.")
} else {
  stop("Test Failed: The dataset contains missing values.")
}

# Check if there are no empty strings in 'division', 'state', and 'party' columns
if (all(analysis_data$poll_id != "" & analysis_data$state != "" & analysis_data$candidate_name != "")) {
  message("Test Passed: There are no empty strings in 'poll_id', 'state', or 'candidate_name'.")
} else {
  stop("Test Failed: There are empty strings in one or more columns.")
}

# Check if sample size are in range [500,2000]
if (all(analysis_data$sample_size >= 500 & analysis_data$sample_size <= 2000)) {
  message("Test passed: They are valid sample sizes")
} else {
  stop("Test Failed: They are not valid sample sizes")
}

# Check if numeric grade are in range [0,3]
if  (all(analysis_data$numeric_grade >= 0 & analysis_data$numeric_grade <= 3)) {
  message("Test passed: They are valid numeric grades")
} else {
  stop("Test Failed: They are not within the valid range")
}

# Check if pollscore are in range [-2,0]
if (all(analysis_data$pollscore >= -2 & analysis_data$pollscore <= 0)){
  message("Test passed: They are valid pollscore")
} else {
  stop("Test Failed: They are not within the valid range")
} 
  