#### Preamble ####
# Purpose: Simulates a dataset of Australian electoral divisions, including the 
  #state and party that won each division.
# Author: Bo Tang, Yiyi Feng, Mingjing Zhan
# Date: 2 November 2024
# Contact: qinghe.tang@mail.utoronto.ca, yiyi.feng@mail.utoronto.ca, mingjin.zhan@mail.utoronto.ca
# License: MIT
# Pre-requisites: The `tidyverse`, arrow` package must be installed
# Any other information needed? Make sure you are in the `Insights and Predictions for the U.S. Election` rproj


#### Workspace setup ####
library(tidyverse)
library(arrow)

set.seed(333)


#### Simulate data ####
#observation numbers
n <- 1000

#simulating poll_id
poll_id <- 1:1000

#simulating pollster_id
pollster_id <- sample(1:100, 1000, replace = TRUE)

#simulating numeric_grade and pollscore
pollster_score <- data.frame(
  pollster_id = 1:100,
  numeric_grade = round(runif(100, min = 0, max = 3), 1),
  pollscore = round(runif(100, min = -2, max = 0), 1)
)


# State names
states <- c(
  "Alabama" = "AL", "Alaska" = "AK", "Arizona" = "AZ", "Arkansas" = "AR",
  "California" = "CA", "Colorado" = "CO", "Connecticut" = "CT", "Delaware" = "DE",
  "Florida" = "FL", "Georgia" = "GA", "Hawaii" = "HI", "Idaho" = "ID",
  "Illinois" = "IL", "Indiana" = "IN", "Iowa" = "IA", "Kansas" = "KS",
  "Kentucky" = "KY", "Louisiana" = "LA", "Maine" = "ME", "Maryland" = "MD",
  "Massachusetts" = "MA", "Michigan" = "MI", "Minnesota" = "MN", "Mississippi" = "MS",
  "Missouri" = "MO", "Montana" = "MT", "Nebraska" = "NE", "Nevada" = "NV",
  "New Hampshire" = "NH", "New Jersey" = "NJ", "New Mexico" = "NM", "New York" = "NY",
  "North Carolina" = "NC", "North Dakota" = "ND", "Ohio" = "OH", "Oklahoma" = "OK",
  "Oregon" = "OR", "Pennsylvania" = "PA", "Rhode Island" = "RI", "South Carolina" = "SC",
  "South Dakota" = "SD", "Tennessee" = "TN", "Texas" = "TX", "Utah" = "UT",
  "Vermont" = "VT", "Virginia" = "VA", "Washington" = "WA", "West Virginia" = "WV",
  "Wisconsin" = "WI", "Wyoming" = "WY"
)

#simulating states
state <- sample(states, n, replace = TRUE)

#simulating start
start_date <- sample(seq(as.Date('2021-01-01'),as.Date('2024-10-27'),by='day')
                     , n, replace = TRUE)

#simulating sample_size
sample_size <- sample(500:2000, n, replace = TRUE)

#simulating candidate_names
candidate_names <- sample(c('Trump', 'Harris'), n, replace = TRUE)

#simulating pct
pct <- round(runif(n, min = 10, max = 90), 1)

# Create a dataset
simulated_data <- tibble(
  poll_id = poll_id,
  pollster_id = pollster_id,
  state = state,
  start_date = start_date,
  end_date = start_date + sample(1:7, n, replace = TRUE),
  sample_size = sample_size,
  candidate_name = candidate_names,
  pct = pct
)

simulated_data <- merge(simulated_data, pollster_score, by = 'pollster_id')

simulated_data <- simulated_data[order(simulated_data$start_date, decreasing = TRUE),]

simulated_data <- simulated_data %>% 
  select(poll_id, pollster_id , numeric_grade, pollscore, start_date,
         end_date, state, sample_size, 
         candidate_name, pct)

#### Save data ####

# Save data as a Parquet file
write_parquet(simulated_data, "data/00-simulated_data/simulated_data.parquet")

