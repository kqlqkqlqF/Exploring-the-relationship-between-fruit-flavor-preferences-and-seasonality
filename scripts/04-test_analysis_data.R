#### Preamble ####
# Purpose: Tests the structure and validity of the analysis data
# Author: Yiyi Feng
# Date: 27 November 2024
# Contact: yiyi.feng@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - The `tidyverse` and `arrow` package must be installed and loaded
# - 02-clean_data.R must have been run
# Any other information needed? No


#### Workspace setup ####
library(tidyverse)
library(arrow)

analysis_banana_data <- read_parquet("data/02-analysis_data/banana_data.parquet")
analysis_rain_data <- read_parquet("data/02-analysis_data/average_rain_data.parquet")
analysis_strawberry_data <- read_parquet("data/02-analysis_data/strawberry_data.parquet")


#### Test for banana and strawberry Data ####

# Test: No overlapping IDs
test_unique_ids <- function(banana_data, strawberry_data) {
  common_ids <- intersect(banana_data$id, strawberry_data$id)
  if (length(common_ids) == 0) {
    cat("Test passed: No overlapping IDs between banana and strawberry data.\n")
  } else {
    stop("Test failed: Overlapping IDs found.")
  }
}

test_unique_ids(analysis_banana_data, analysis_strawberry_data)


# Test: Vendor values are valid
test_valid_vendors <- function(data) {
  allowed_vendors <- c("Voila", "Loblaws", "Metro", "Walmart", "NoFrills", "SaveOnFoods")
  invalid_vendors <- setdiff(unique(data$vendor), allowed_vendors)
  if (length(invalid_vendors) == 0) {
    cat("Test passed: All vendors are valid.\n")
  } else {
    stop(paste("Test failed: Invalid vendors found:", paste(invalid_vendors, collapse = ", ")))
  }
}

test_valid_vendors(analysis_banana_data)
test_valid_vendors(analysis_strawberry_data)


# Test: Check column count for product_data_banana
if (ncol(analysis_banana_data) == 10) {
  cat("Test Passed: analysis_data_banana has 10 columns.")
} else {
  stop(paste("Test Failed: analysis_data_banana has", ncol(analysis_banana_data), "columns; expected 10 columns."))
}

# Test: Check column count for product_data_strawberry
if (ncol(analysis_strawberry_data) == 10) {
  cat("Test Passed: analysis_data_strawberry has 10 columns.")
} else {
  stop(paste("Test Failed: analysis_data_strawberry has", ncol(analysis_strawberry_data), "columns; expected 10 columns."))
}


# Test: Average prices are within range or NA
test_avg_prices <- function(data) {
  price_cols <- grep("^avg_price_", names(data), value = TRUE)
  invalid_prices <- data %>%
    select(all_of(price_cols)) %>%
    filter(if_any(everything(), ~ !is.na(.) & (. < 0.1 | . > 100)))
  if (nrow(invalid_prices) == 0) {
    cat("Test passed: All average prices are within the valid range or NA.\n")
  } else {
    stop("Test failed: Invalid average prices found.")
  }
}

test_avg_prices(analysis_banana_data)
test_avg_prices(analysis_strawberry_data)


#### Test for Rain Data ####

# Test: Check if the dataset has 6 rows and 4 columns
if (nrow(analysis_rain_data) == 6 && ncol(analysis_rain_data) == 4) {
  cat("Test Passed: analysis_rain_data has 6 rows and 4 columns.")
} else {
  stop(paste("Test Failed: analysis_rain_data has", nrow(test_rain_data), "rows and", ncol(test_rain_data), "columns; expected 6 rows and 4 columns."))
}

# Test: Check if the 'month' column contains 6, 7, 8, 9, 10, and 11
expected_months <- 6:11
if (all(sort(analysis_rain_data$month) == expected_months)) {
  cat("Test Passed: analysis_rain_data 'month' column contains the expected months: 6, 7, 8, 9, 10, 11.")
} else {
  stop(paste("Test Failed: analysis_rain_data 'month' column does not contain the expected months. Found:", paste(sort(unique(test_rain_data$month)), collapse = ", "), "."))
}

# Test: Check if `total_rainfall / num_data` equals `avg_rainfall` for each row
calculated_avg_rainfall <- round(analysis_rain_data$total_rainfall / analysis_rain_data$num_data, 2)
if (all(round(analysis_rain_data$avg_rainfall, 2) == calculated_avg_rainfall)) {
  cat("Test Passed: avg_rainfall values are correctly calculated as total_rainfall / num_data.")
} else {
  stop("Test Failed: avg_rainfall values are not correctly calculated as total_rainfall / num_data.")
}

# Test: Check if there are any NA values in the dataset
if (all(!is.na(analysis_rain_data))) {
  cat("Test Passed: analysis_rain_data has no NA values.")
} else {
  stop("Test Failed: analysis_rain_data contains NA values.")
}



