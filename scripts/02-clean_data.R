#### Preamble ####
# Purpose: Cleans the raw data
# Author: Yiyi Feng
# Date: 27 November 2024
# Contact: yiyi.feng@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - The `tidyverse`, `janitor` , `arrow` , `lubridate`  package must be installed and loaded
# Any other information needed? No

#### Workspace setup ####
library(tidyverse)
library(janitor)
library(arrow)
library(lubridate)
library(stringr)

#### Clean data ####
# read the dataset
raw_data <- read_csv("data/01-raw_data/hammer-4-raw.csv")
product_data <- read_csv("data/01-raw_data/hammer-4-product.csv")

# Read the Parquet file
rain_data <- read_parquet("data/01-raw_data/rainfall_data.parquet")



#### Data Cleaning for Banana and Strawberry Data ####

# Remove rows where "banana" and "strawberry" both appear in product_name or concatted
product_data <- product_data %>%
  filter(!(str_detect(tolower(product_name), "banana") & str_detect(tolower(product_name), "strawberry")) & 
           !(str_detect(tolower(concatted), "banana") & str_detect(tolower(concatted), "strawberry")))

# Filter rows where 'product_name' contains 'banana' (case-insensitive)
product_data_banana <- product_data[grepl("banana", product_data$product_name, ignore.case = TRUE), ]

product_data_banana$category <- ifelse(
  grepl("lemonade|juice|sparkling|drink|beverage", product_data_banana$product_name, ignore.case = TRUE) | 
    grepl("lemonade|juice|sparkling|drink|beverage", product_data_banana$concatted, ignore.case = TRUE), 
  "Beverage",
  ifelse(
    grepl("yogurt", product_data_banana$product_name, ignore.case = TRUE) | 
      grepl("yogurt", product_data_banana$concatted, ignore.case = TRUE), 
    "Yogurt",
    ifelse(
      grepl("tea", product_data_banana$product_name, ignore.case = TRUE) | 
        grepl("tea", product_data_banana$concatted, ignore.case = TRUE),
      "Flavored Tea",
      ifelse(
        grepl("organic", product_data_banana$product_name, ignore.case = TRUE) | 
          grepl("organic", product_data_banana$concatted, ignore.case = TRUE), 
        "Fruit",
        ifelse(
          grepl("\\d+(ML|ml|L|l)", product_data_banana$product_name) | 
            grepl("\\d+(ML|ml|L|l)", product_data_banana$concatted), 
          "Beverage",
          ifelse(
            grepl("\\d+(g|G|kg|KG)", product_data_banana$product_name) | 
              grepl("\\d+(g|G|kg|KG)", product_data_banana$concatted), 
            "Solid Snacks",
            "Fruit"  # default to "Fruit" if no category is found
          )
        )
      )
    )
  )
)

# View the updated data
head(product_data_banana)

# Remove the specified columns from the dataset
product_data_banana <- product_data_banana %>%
  select(-concatted, -units, -brand, -detail_url, -sku, -upc)


# Create product_data_strawberry with rows that contain 'strawberry' in product_name
product_data_strawberry <- product_data %>%
  filter(grepl("strawberry", product_name, ignore.case = TRUE))


product_data_strawberry$category <- ifelse(
  grepl("lemonade|juice|sparkling|drink|beverage", product_data_strawberry$product_name, ignore.case = TRUE) | 
    grepl("lemonade|juice|sparkling|drink|beverage", product_data_strawberry$concatted, ignore.case = TRUE), 
  "Beverage",
  ifelse(
    grepl("yogurt", product_data_strawberry$product_name, ignore.case = TRUE) | 
      grepl("yogurt", product_data_strawberry$concatted, ignore.case = TRUE), 
    "Yogurt",
    ifelse(
      grepl("tea", product_data_strawberry$product_name, ignore.case = TRUE) | 
        grepl("tea", product_data_strawberry$concatted, ignore.case = TRUE),
      "Flavored Tea",
      ifelse(
        grepl("organic", product_data_strawberry$product_name, ignore.case = TRUE) | 
          grepl("organic", product_data_strawberry$concatted, ignore.case = TRUE), 
        "Fruit",
        ifelse(
          grepl("\\d+(ML|ml|L|l)", product_data_strawberry$product_name) | 
            grepl("\\d+(ML|ml|L|l)", product_data_strawberry$concatted), 
          "Beverage",
          ifelse(
            grepl("\\d+(g|G|kg|KG)", product_data_strawberry$product_name) | 
              grepl("\\d+(g|G|kg|KG)", product_data_strawberry$concatted), 
            "Solid Snacks",
            "Fruit"  # default to "Fruit" if no category is found
          )
        )
      )
    )
  )
)



# Remove the specified columns
product_data_strawberry <- product_data_strawberry %>%
  select(-concatted, -units, -brand, -detail_url, -sku, -upc)

# Filter rows in raw_data where product_id is contained in the 'id' column of either product_data_banana or product_data_strawberry
raw_data <- raw_data %>%
  filter(product_id %in% c(product_data_banana$id, product_data_strawberry$id))

raw_data <- raw_data %>%
  filter(!is.na(price_per_unit))

# Convert 'nowtime' to Date format, keeping only the date part
raw_data$nowtime <- as.Date(raw_data$nowtime)

# Remove specified columns from raw_data
raw_data <- raw_data[, !colnames(raw_data) %in% c("old_price", "price_per_unit", "other")]

# Rank rows by nowtime for each product_id
raw_data <- raw_data %>%
  group_by(product_id) %>%
  arrange(product_id, nowtime) %>%
  mutate(rank = row_number()) %>%
  ungroup()

raw_data <- raw_data %>% 
  select(-rank)

raw_data <- raw_data %>% distinct()

# Function to fill missing dates for each product_id
fill_missing_dates <- raw_data %>%
  group_by(product_id) %>%
  # Generate a sequence of all dates between the min and max dates for each product_id
  complete(nowtime = seq(min(nowtime), max(nowtime), by = "day")) %>%
  # Fill 'current_price' with the last known price
  arrange(product_id, nowtime) %>%
  fill(current_price, .direction = "down") %>%
  ungroup()


fill_missing_dates$current_price <- as.numeric(fill_missing_dates$current_price)

fill_missing_dates <- na.omit(fill_missing_dates)

# List of months from June to November
months <- 6:11
month_names <- c("June", "July", "August", "September", "October", "November")

# Step 4: Loop through each month and calculate the average price for each product_id
for(i in 1:length(months)) {
  month_num <- months[i]
  month_name <- month_names[i]
  
  # Calculate the average price for the specific month
  avg_price_month <- fill_missing_dates %>%
    filter(month(nowtime) == month_num) %>%
    group_by(product_id) %>%
    summarise(!!paste0("avg_price_", month_name) := mean(current_price, na.rm = TRUE)) %>%
    ungroup()
  
  # Step 5: Merge the calculated average price for the month into product_data_banana
  product_data_banana <- product_data_banana %>%
    left_join(avg_price_month, by = c("id" = "product_id"))
}


# Step 4: Loop through each month and calculate the average price for each product_id
for(i in 1:length(months)) {
  month_num <- months[i]
  month_name <- month_names[i]
  
  # Calculate the average price for the specific month
  avg_price_month <- fill_missing_dates %>%
    filter(month(nowtime) == month_num) %>%
    group_by(product_id) %>%
    summarise(!!paste0("avg_price_", month_name) := mean(current_price, na.rm = TRUE)) %>%
    ungroup()
  
  # Step 5: Merge the calculated average price for the month into product_data_strawberry
  product_data_strawberry <- product_data_strawberry %>%
    left_join(avg_price_month, by = c("id" = "product_id"))
}

# For product_data_banana
product_data_banana <- product_data_banana %>%
  # Remove rows where all avg_price columns are NA
  filter(rowSums(is.na(select(., avg_price_June:avg_price_November))) < ncol(select(., avg_price_June:avg_price_November)))

# For product_data_strawberry
product_data_strawberry <- product_data_strawberry %>%
  # Remove rows where all avg_price columns are NA
  filter(rowSums(is.na(select(., avg_price_June:avg_price_November))) < ncol(select(., avg_price_June:avg_price_November)))

# Save product_data_banana as a Parquet file
write_parquet(product_data_banana, "data/02-analysis_data/banana_data.parquet")
# Save product_data_strawberry as a Parquet file
write_parquet(product_data_strawberry, "data/02-analysis_data/strawberry_data.parquet")

#### Cleaning Rain Data ####

# Keep only the 'date' and 'airfall' columns
rain_data <- rain_data %>%
  select(date, rainfall)

# Convert the 'date' column to date format
rain_data$date <- as.Date(rain_data$date)

# Filter rows for dates between June 2024 and November 2024
rain_data_filtered <- rain_data %>%
  filter(date >= "2024-06-01" & date <= "2024-11-30")

# Extract month and year
rain_data_filtered$month <- month(rain_data_filtered$date)
rain_data_filtered$year <- year(rain_data_filtered$date)

# Filter for months between June and November 2024
rain_data_filtered <- rain_data_filtered %>%
  filter(year == 2024 & month >= 6 & month <= 11)

# Calculate the average rainfall for each month
average_rainfall <- rain_data_filtered %>%
  group_by(month) %>%
  summarise(
    total_rainfall = sum(rainfall, na.rm = TRUE),
    num_data = n(),
    avg_rainfall = total_rainfall / num_data
  )


# Save data_rain as a Parquet file
write_parquet(average_rainfall, "data/02-analysis_data/average_rain_data.parquet")


#### Modeling data ####

# Add the Flavor column and assign "banana" to all rows
product_data_banana$flavor <- "banana"

# Add the Flavor column and assign "banana" to all rows
product_data_strawberry$flavor <- "strawberry"

# Combine
product_data_combined <- rbind(product_data_banana, product_data_strawberry)

# Pivot the combined dataset to long format
product_data_long <- product_data_combined %>%
  pivot_longer(
    cols = starts_with("avg_price_"),       # Select columns for monthly average prices
    names_to = "month",                    # New column to store month names
    values_to = "monthly_avg_price"        # New column to store average price values
  ) %>%
  mutate(
    month = gsub("avg_price_", "", month)  # Clean up month names by removing "avg_price_"
  )

# Create a mapping of month names to numeric values
month_mapping <- c("June" = 6, "July" = 7, "August" = 8, "September" = 9,
                   "October" = 10, "November" = 11)

# Convert month names to numeric values
product_data_long$month <- month_mapping[product_data_long$month]

# Select only the necessary columns from average_rainfall
average_rainfall_subset <- average_rainfall %>%
  select(month, avg_rainfall)

# Merge the avg_rainfall column into product_data_long based on the month
product_data_long <- product_data_long %>%
  left_join(average_rainfall_subset, by = "month")

# 1. Preprocess the data: Ensure categorical variables are factors
product_data_long <- product_data_long %>%
  mutate(
    vendor = as.factor(vendor),
    category = as.factor(category),
    flavor = as.factor(flavor),
    month = as.factor(month)  # Month as a factor for modeling
  )

# 2. Create the target variable: Change in average price (monthly_avg_price - previous month's price)
# Sort by id and month
product_data_long <- product_data_long %>%
  arrange(id, month)

# Calculate the change in price (current month - previous month) for each product
product_data_long <- product_data_long %>%
  group_by(id) %>%
  mutate(price_change = monthly_avg_price - lag(monthly_avg_price)) %>%
  ungroup()

# We need to remove rows where price_change is NA (because there's no previous month for those)
product_data_long <- product_data_long %>%
  filter(!is.na(price_change))

# Save data_rain as a Parquet file
write_parquet(product_data_long, "data/02-analysis_data/combined_model_data.parquet")


