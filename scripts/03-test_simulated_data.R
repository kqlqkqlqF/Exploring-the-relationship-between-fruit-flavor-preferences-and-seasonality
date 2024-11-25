#### Preamble ####
# Purpose: Tests the structure and validity of the simulated data
# Author: Yiyi Feng
# Date: 27 November 2024
# Contact: yiyi.feng@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
  # - The `tidyverse` and `arrow` package must be installed and loaded
  # - 00-simulate_data.R must have been run
# Any other information needed? No


#### Workspace setup ####
library(tidyverse)
library(arrow)

test_banana_data <- read_parquet("data/00-simulated_data/simulated_banana_data.parquet")
test_rain_data <- read_parquet("data/00-simulated_data/simulated_rain_data.parquet")
test_strawberry_data <- read_parquet("data/00-simulated_data/simulated_strawberry_data.parquet")


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

test_unique_ids(test_banana_data, test_strawberry_data)


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

test_valid_vendors(test_banana_data)
test_valid_vendors(test_strawberry_data)


# Test: Check column count for product_data_banana
if (ncol(test_banana_data) == 10) {
  cat("Test Passed: product_data_banana has 10 columns.")
} else {
  stop(paste("Test Failed: product_data_banana has", ncol(test_banana_data), "columns; expected 10 columns."))
}

# Test: Check column count for product_data_strawberry
if (ncol(test_strawberry_data) == 10) {
  cat("Test Passed: product_data_strawberry has 10 columns.")
} else {
  stop(paste("Test Failed: product_data_strawberry has", ncol(test_strawberry_data), "columns; expected 10 columns."))
}


# Map product_name to category
category_mapping_strawberry <- c(
  "Fresh strawberry" = "fruit",
  "strawberry Flavored Drink" = "beverage",
  "strawberry Flavored Candy" = "solid snack",
  "strawberry Popsicle" = "solid snack",
  "strawberry Juice" = "beverage",
  "Large Red strawberry" = "fruit",
  "strawberry Sorbet" = "solid snack",
  "strawberry Jam" = "solid snack",
  "strawberry Granola Bar" = "solid snack",
  "strawberry Cake" = "solid snack",
  "strawberry Smoothie" = "beverage"
)

# Map product_name to category
category_mapping_banana <- c(
  "Seedless Sweet Baby Mini banana" = "fruit",
  "banana Flavored Tea Drink" = "beverage",
  "banana Flavored Gummy" = "solid snack",
  "banana Popsicle" = "solid snack",
  "banana Apple Flavored Juice" = "beverage",
  "banana Slices" = "fruit",
  "banana Candy" = "solid snack",
  "Sparkling banana Beverage" = "beverage",
  "banana Sorbet" = "solid snack",
  "banana Cake" = "solid snack",
  "banana Jam" = "solid snack"
)


# Test: Product names map correctly to categories
test_product_category_mapping <- function(data, category_mapping) {
  incorrect_mappings <- data %>%
    filter(category != category_mapping[product_name]) %>%
    select(id, product_name, category)
  if (nrow(incorrect_mappings) == 0) {
    cat("Test passed: All product names map correctly to categories.\n")
  } else {
    stop("Test failed: Incorrect product name-category mappings found.")
  }
}

test_product_category_mapping(test_banana_data, category_mapping_banana)
test_product_category_mapping(test_strawberry_data, category_mapping_strawberry)


# Test: Average prices are within range or NA
test_avg_prices <- function(data) {
  price_cols <- grep("^avg_price_", names(data), value = TRUE)
  invalid_prices <- data %>%
    select(all_of(price_cols)) %>%
    filter(if_any(everything(), ~ !is.na(.) & (. < 1 | . > 20)))
  if (nrow(invalid_prices) == 0) {
    cat("Test passed: All average prices are within the valid range or NA.\n")
  } else {
    stop("Test failed: Invalid average prices found.")
  }
}

test_avg_prices(test_banana_data)
test_avg_prices(test_strawberry_data)


#### Test for Rain Data ####

# Test: Check if the dataset has 6 rows and 4 columns
if (nrow(test_rain_data) == 6 && ncol(test_rain_data) == 4) {
  cat("Test Passed: test_rain_data has 6 rows and 4 columns.")
} else {
  stop(paste("Test Failed: test_rain_data has", nrow(test_rain_data), "rows and", ncol(test_rain_data), "columns; expected 6 rows and 4 columns."))
}

# Test: Check if the 'month' column contains 6, 7, 8, 9, 10, and 11
expected_months <- 6:11
if (all(sort(test_rain_data$month) == expected_months)) {
  cat("Test Passed: test_rain_data 'month' column contains the expected months: 6, 7, 8, 9, 10, 11.")
} else {
  stop(paste("Test Failed: test_rain_data 'month' column does not contain the expected months. Found:", paste(sort(unique(test_rain_data$month)), collapse = ", "), "."))
}

# Test: Check if `total_rainfall / num_data` equals `avg_rainfall` for each row
calculated_avg_rainfall <- round(test_rain_data$total_rainfall / test_rain_data$num_data, 2)
if (all(round(test_rain_data$avg_rainfall, 2) == calculated_avg_rainfall)) {
  cat("Test Passed: avg_rainfall values are correctly calculated as total_rainfall / num_data.")
} else {
  stop("Test Failed: avg_rainfall values are not correctly calculated as total_rainfall / num_data.")
}

# Test: Check if there are any NA values in the dataset
if (all(!is.na(test_rain_data))) {
  cat("Test Passed: test_rain_data has no NA values.")
} else {
  stop("Test Failed: test_rain_data contains NA values.")
}


  