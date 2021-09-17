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


## TODO
## - pagination
## - entrare nella tabella
## - scrappare info
## - mettere dati su github con pins
## - fare trycatches 
## - utilizzare purrr o furrr 
## - tests in uscita
## - 


## prima si tirano fuoti tutti i links:

url_aggiornamenti = "https://www.epicentro.iss.it/coronavirus/aggiornamenti"
baseurl = "https://www.epicentro.iss.it/coronavirus/"

href_df = url_aggiornamenti %>% 
  read_html() %>% 
  html_elements(css = "p") %>%
  html_elements(css = "a") %>% 
  html_attr("href") %>% 
  tibble(.name_repair = "unique") %>% 
  rename(href_bollettino = ".") %>% 
  filter(str_detect(href_bollettino, "Bollettino-sorveglianza-integrata")) %>% 
  mutate(href_bollettino = paste0(baseurl, href_bollettino),
         data_bollettino = str_extract(href_bollettino, pattern = "\\_(.*?)\\."),
         ## perfectize regex
         data_bollettino = str_remove(data_bollettino, "_|."))

read_table = function(variables) {
  
}


