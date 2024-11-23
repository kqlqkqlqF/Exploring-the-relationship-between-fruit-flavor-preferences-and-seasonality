#### Preamble ####
# Purpose: Cleans the raw election data
# Author: Bo Tang, Yiyi Feng, Mingjing Zhan
# Date: 2 November 2024
# Contact: qinghe.tang@mail.utoronto.ca, yiyi.feng@mail.utoronto.ca, mingjin.zhan@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - The `tidyverse`, `janitor` , `arrow` , `lubridate`  package must be installed and loaded
# Any other information needed? Make sure you are in the `Insights and Predictions for the U.S. Election` rproj

#### Workspace setup ####
library(tidyverse)
library(janitor)
library(arrow)
library(lubridate)

#### Clean data ####
# read the dataset
raw_data <- read_csv("data/01-raw_data/president_polls.csv")

# set the election day
election_day <- as.Date("2024-11-05")

# create a new column showing the weight as time approach to election day
cleaned_data <- raw_data %>% distinct() %>%
  mutate(end_date = mdy(end_date), start_date = mdy(start_date)) %>%
  mutate(days_until_election_start = as.numeric(election_day - start_date),
         days_until_election_end = as.numeric(election_day - end_date),
         weight_start = 1 - (days_until_election_start / max(days_until_election_start)),
         weight_end = 1 - (days_until_election_end / max(days_until_election_end)),
         recency_weight = (weight_start + weight_end) / 2
  )

# clean the dataset with select the columns, choose over 2 numeric grade,
#set na state to national, set Biden to Harris and drop nas
cleaned_data <- cleaned_data %>% select(
  poll_id,
  pollster,
  numeric_grade,
  pollscore,
  state,
  start_date,
  end_date,
  sample_size,
  candidate_name,
  pct,
  recency_weight) %>% 
  filter(numeric_grade >= 2.0) %>% 
  mutate(state = ifelse(is.na(state),"National",state)) %>%
  mutate(candidate_name = ifelse(
    candidate_name == "Joe Biden", "Kamala Harris", candidate_name)) %>%
  drop_na()

# select only Trump and Harris and create new column showing the number of votes
cleaned_data <- cleaned_data %>% 
  filter(candidate_name %in% c("Donald Trump" ,"Kamala Harris")) %>%
  mutate(num_vote = round((pct / 100) * sample_size, 0))

# reorder data
cleaned_data_1 <- cleaned_data %>% 
  select(recency_weight,
         pct, pollster, state, start_date, end_date, pollscore,numeric_grade,sample_size)

cleaned_data <- cleaned_data %>% 
  select(poll_id, pollster, numeric_grade, pollscore, start_date,
         end_date, recency_weight, state, sample_size, 
         candidate_name, num_vote, pct)  
#### Save data ####
write_parquet(cleaned_data_1, "data/02-analysis_data/analysis_data.parquet")
write_parquet(cleaned_data, "data/02-analysis_data/cleaned_data.parquet")


