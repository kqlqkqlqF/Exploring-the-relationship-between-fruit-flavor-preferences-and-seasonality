#### Preamble ####
# Purpose: Tests the cleaned analysis data
# Author: Bo Tang, Yiyi Feng, Mingjing Zhan
# Date: 2 November 2024
# Contact: qinghe.tang@mail.utoronto.ca, yiyi.feng@mail.utoronto.ca, mingjin.zhan@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - The `tidyverse` package must be installed and loaded
# - 02-clean_data.R must have been run
# Any other information needed? Make sure you are in the `Insights and Predictions for the U.S. Election` rproj

#### Workspace setup ####
data <- read_parquet("data/02-analysis_data/cleaned_data.parquet")
library(tidyverse)
library(testthat)


#### Test data ####
# Test that the dataset has 4740 rows
test_that("dataset has 4740 rows", {
  expect_equal(nrow(data), 4740)
})

# Test that the dataset has 12 columns
test_that("dataset has 12 columns", {
  expect_equal(ncol(data), 12)
})

# Test that the 'pollster' column is character type
test_that("'pollster' is character", {
  expect_type(data$pollster, "character")
})

# Test that the 'candidate name' column is character type
test_that("'candidate_name' is character", {
  expect_type(data$candidate_name, "character")
})

# Test that the 'state' column is character type
test_that("'state' is character", {
  expect_type(data$state, "character")
})

# Test that the 'Pct' column is numeric type
test_that("Pct column is numeric", {
  expect_true(is.numeric(data$pct))
})

# Test that there are no missing values in the dataset
test_that("no missing values in dataset", {
  expect_true(all(!is.na(data)))
})

# Test that 'state' contains only valid Australian state or territory names
valid_states <- c( "California", "New York", "Illinois", "New Jersey", "Massachusetts",
                   "Maryland", "Washington", "Oregon", "Connecticut", "Hawaii",
                   "Rhode Island", "Vermont", "Delaware", "New Mexico", "Colorado",
                   "Virginia", "Maine", "Maine CD-1", "Maine CD-2", "Minnesota", "Texas", "Alabama", "Mississippi", "Oklahoma", "Kentucky",
                   "Tennessee", "West Virginia", "South Carolina", "Louisiana",
                   "Arkansas", "Missouri", "Indiana", "Kansas", "Nebraska", "Nebraska CD-2",
                   "South Dakota", "North Dakota", "Idaho", "Montana", "Utah", "Wyoming", "Alaska","Florida", "Ohio", "Iowa", "Pennsylvania", "Michigan", "Wisconsin",
                   "North Carolina", "Arizona", "Georgia", "Nevada", "New Hampshire","National")
test_that("'state' contains valid U.S state names", {
  expect_true(all(data$state %in% valid_states))
})

# Test that there are no empty strings in 'pollster', 'candidate name', or 'state' columns
test_that("no empty strings in 'pollster', 'candidate name', or 'state' columns", {
  expect_false(any(data$pollster == "" | data$candidate_name == "" | data$state == ""))
})

# Test that the 'poll id' column contains at least 2 unique values
test_that("'poll id' column contains at least 2 unique values", {
  expect_true(length(unique(data$poll_id)) >= 2)
})

# Test that the 'numeric grade' , 'pollscore' ,'sample size', 'number vote','pct' in the valid range
test_that("the 'numeric grade' , 'pollscore' ,'recency weight', 'sample size', 'number vote','pct' in the valid range",{
  expect_true(all(data$numeric_grade >= 2 & data$numeric_grade <= 3 
                  & data$recency_weight >= 0 & data$recency_weight <= 1 & 
                    data$sample_size >= 0 & data$num_vote >= 0 & data$pct >=0 
                  & data$pct <= 100 & data$pollscore >= -2))
})


