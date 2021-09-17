library(rvest, warn.conflicts = F, quietly = T)
library(stringr, warn.conflicts = F, quietly = T)
library(httr, warn.conflicts = F, quietly = T)
library(glue, warn.conflicts = F, quietly = T)
library(here, warn.conflicts = F, quietly = T)
library(readr, warn.conflicts = F, quietly = T)
library(tidyr, warn.conflicts = F, quietly = T)
library(dplyr, warn.conflicts = F, quietly = T)
library(purrr, warn.conflicts = F, quietly = T)
library(pins, warn.conflicts = F, quietly = T)
library(tabulizer, warn.conflicts = F, quietly = T)
library(lubridate, warn.conflicts = F, quietly = T)


## TODO
## - entrare nella tabella FATTO
## - scrappare info FATTO
## - mettere dati su github con pins ~
## - fare trycatches ~
## - utilizzare purrr o furrr ~
## - tests in uscita ~
## - 


## prima si tirano fuoti tutti i links:
url_aggiornamenti = "https://www.epicentro.iss.it/coronavirus/aggiornamenti"

baseurl = "https://www.epicentro.iss.it/coronavirus/"

href_df = url_aggiornamenti %>% 
  read_html() %>% 
  html_elements(css = "p") %>%
  html_elements(css = "a") %>% 
  html_attr("href") %>% 
  tibble() %>% 
  rename(href_bollettino = ".") %>% 
  filter(str_detect(href_bollettino, "Bollettino-sorveglianza-integrata")) %>% 
  mutate(href_bollettino = paste0(baseurl, href_bollettino),
         data_bollettino = str_extract(href_bollettino, pattern = "\\_(.*?)\\."),
         ## perfectize regex
         data_bollettino = str_remove(data_bollettino, "_|."),
         data_bollettino = )


read_table = function(hrefs) {
  
  hrefs %>% 
    extract_tables()
  
}

## 18-agosto-2021
sample_href = href_df[1] %>% sample_n(1) %>%  pull

## tabella pagina 13
distr_casi_table = extract_tables(file = sample_href, 
               method = "decide",
               output = "data.frame") 

map(distr_casi_table, grep(distr_casi_table ,"del totale deceduti"))



grep(distr_casi_table, "N. casi") %>%  View()


lapply(distr_casi_table,function(x)(str_detect(x, "del totale deceduti")))

distr_casi_table_pluck = extract_tables(file = sample_href, 
                                  method = "decide",
                                  output = "data.frame")  %>% 
  pluck(5)



check_soggetti_maschili = grepl("Soggetti.di.sesso.maschile", names(distr_casi_table_pluck), ignore.case = T)
check_soggetti_femminili = grepl("Soggetti.di.sesso.femminile", names(distr_casi_table_pluck), ignore.case = T)
check_casi_totali = grepl("Casi.totali", names(distr_casi_table_pluck), ignore.case = T)

if(any(check_soggetti_maschili) && any(check_soggetti_femminili) && any(check_casi_totali)){
  print("alleluja")
}

search_within_df = function(list_element) {
  
  check_soggetti_maschili = grepl("Soggetti.di.sesso.maschile", names(list_element), ignore.case = T)
  check_soggetti_femminili = grepl("Soggetti.di.sesso.femminile", names(list_element), ignore.case = T)
  check_casi_totali = grepl("Casi.totali", names(list_element), ignore.case = T)
  
  if (any(check_soggetti_maschili,check_soggetti_femminili,check_casi_totali) ) {
    return(TRUE)
  }
}


map(distr_casi_table, search_within_df)

## separate each df 
## by content (this time pluck 5)
select_table = function(table_list) {
  table_list %>% 
    pluck()
  
}


## parse table done
distr_casi_table_pluck %>%
  slice(7:21) %>% 
  tibble() %>%
  separate(
    Soggetti.di.sesso.maschile,
    sep ="  ",
    into = c("n. casi (uomini)",  "% casi totali (uomini)", "n. deceduti (uomini)", "% del totale deceduti (uomini)") 
    )  %>%
  rename("Letalità % (uomini)" = "X.2") %>% 
  separate(
    Soggetti.di.sesso.femminile,
    sep ="  ", 
    into = c("n. casi (donne)", "% casi totali (donne)", "n. deceduti (donne)", "% del totale deceduti (donne)")
  ) %>% 
  select(-X.1) %>%
  rename("Letalità % (donne)" = "X.3") %>%
  ## correct "Età non nota row"
  drop_na() %>% 
  rename(
    "n. casi (totali)"               = "X.4",
    "% casi totali (totali)"         = "X.5",
    "n. deceduti (totali)"           = "Casi.totali",
    "% del totale deceduti (totali)" = "X.6",
    "Letalità % (totale)"            = "X.7"
  ) 
  


