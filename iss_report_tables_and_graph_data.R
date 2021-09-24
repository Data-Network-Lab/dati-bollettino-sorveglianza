### - DISTRIBUZIONE DEI CASI E DEI DECESSI PER COVID-19 DIAGNOSTICATI 
###   IN ITALIA PER FASCIA DI ETÀ E SESSO

library(gt, quietly = T, warn.conflicts = F)
library(timetk, quietly = T, warn.conflicts = F)

## per mese

sesso_eta = readRDS(here("data", "sesso_eta_data", "data.Rds"))
sesso_eta %>%
  clean_names() %>% 
  mutate(
    iss_date  = dmy(iss_date),
    deceduti = ifelse(deceduti == "<5", 2, deceduti),
    casi_cumulativi = ifelse(casi_cumulativi == "<5", 2, casi_cumulativi),
    mutate(across(c("deceduti", "casi_cumulativi"), as.numeric))
         ) %>%
  group_by(iss_date, sesso, age_group) %>% 
  summarise_by_time(
    .date_var = iss_date, 
    .by       = "month",
    casi_cumulativi  = last(casi_cumulativi),
    deceduti         = sum(deceduti)
  ) %>%
  filter_by_time(
    .date_var = iss_date,
    .start_date = dmy("01/01/2021"),
    .end_date = today()
  ) 


## per settimana
## assumption: quando è minor di 5 (.e. "<5") metto 2.
sesso_eta %>%
  clean_names() %>%
  mutate(iss_date  = dmy(iss_date),
         deceduti = ifelse(deceduti == "<5", 2, deceduti),
         casi_cumulativi = ifelse(casi_cumulativi == "<5", 2, casi_cumulativi),
         mutate(across(c("deceduti", "casi_cumulativi"), as.numeric))
         )  %>% 
  group_by(iss_date, sesso, age_group) %>% 
  summarise_by_time(
    .date_var = iss_date, 
    .by       = "week",
    casi_cumulativi  = last(casi_cumulativi),
    deceduti         = sum(deceduti)
    ) %>%
  filter_by_time(
      .date_var = iss_date,
      .start_date = dmy("01/01/2021"),
      .end_date = today()
    ) 
