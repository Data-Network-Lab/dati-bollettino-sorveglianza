### - DISTRIBUZIONE DEI CASI E DEI DECESSI PER COVID-19 DIAGNOSTICATI 
###   IN ITALIA PER FASCIA DI ETÀ E SESSO

library(gt, quietly = T, warn.conflicts = F)
library(timetk, quietly = T, warn.conflicts = F)

## per mese
sesso_eta %>%
  clean_names() %>% 
  mutate(iss_date  = dmy(iss_date)) %>% 
  filter_by_time(.date_var = iss_date, .start_date = dmy("01/01/2021"), .end_date = today()) %>% 
  summarise_by_time(.date_var = iss_date, 
                    .by = "month",
                    casi_cumulativi = sum(casi_cumulativi))
  group_by(age_group) %>% 
  summarise(wh)


## per settimana
sesso_eta %>%
  clean_names() %>%
  mutate(iss_date  = dmy(iss_date)) %>% 
  filter_by_time(.date_var = iss_date, .start_date = dmy("01/01/2021"), .end_date = today()) %>%
  summarise_by_time(.date_var = iss_date, .by = "week")