library(httr)
library(jsonlite)
library(tidyverse)
library(janitor)

# text to show when running in scheduler
cat("Now getting Data..\n")

# api pull for general ontario vaccine data
dat_api <- fromJSON(
  "https://data.ontario.ca/api/3/action/datastore_search?resource_id=8a89caa9-511c-4568-af89-7f2174b4378c&limit=1000")

# clean api data in data frame
data <- as.data.frame(dat_api$result$records) %>% 
  mutate(across(everything(), ~replace_na(.x, 0))) %>% 
  mutate(report_date = as.Date(report_date)) %>% 
  mutate(total_individuals_at_least_one = as.numeric(total_individuals_at_least_one)) %>% 
  mutate(total_doses_in_fully_vaccinated_individuals = as.numeric(total_doses_in_fully_vaccinated_individuals)) %>% 
  mutate(total_individuals_fully_vaccinated = as.numeric(total_individuals_fully_vaccinated))

# api pull for age group ontario vaccine data
age_api <- fromJSON(
  "https://data.ontario.ca/api/3/action/datastore_search?resource_id=775ca815-5028-4e9b-9dd4-6975ff1be021&limit=1000000")

# clean api data into a data frame
age_data <- as.data.frame(age_api$result$records) %>% 
  mutate(across(everything(), ~replace_na(.x, 0))) %>% 
  filter(Agegroup !="Undisclosed_or_missing") %>% 
  mutate(Date = as.Date(Date)) %>% 
  rename(one_dose_cumulative = "At least one dose_cumulative") %>% 
  rename(second_dose_cumulative = "Second_dose_cumulative") %>% 
  rename(total_population = "Total population") %>% 
  rename(percent_at_least_one_dose = "Percent_at_least_one_dose") %>% 
  rename(percent_fully_vaccinated = "Percent_fully_vaccinated") %>% 
  mutate(one_dose_cumulative = as.numeric(one_dose_cumulative),
         second_dose_cumulative = as.numeric(second_dose_cumulative),
         total_population = as.numeric(total_population),
         percent_at_least_one_dose = as.numeric(percent_at_least_one_dose),
         percent_fully_vaccinated = as.numeric(percent_fully_vaccinated)) %>% 
  mutate(Agegroup = str_replace(Agegroup, "Adults_18plus", "18+"))

# text to show when running in scheduler
cat("Now writing Data..\n")

# Write file to csv
write.csv(data,
          file = "ontVaccineData.csv",
          row.names = F)

write.csv(age_data,
          file = "ageGroupOntVaccineData.csv",
          row.names = F)

# text to show when running in scheduler
cat("done..\n")

  
