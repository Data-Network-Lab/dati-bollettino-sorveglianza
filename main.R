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
library(logger, warn.conflicts = F, quietly = T)


## TODO
## - entrare nella tabella FATTO
## - scrappare info FATTO
## - mettere dati su github con pins ~
## - fare trycatches ~
## - utilizzare purrr o furrr ~
## - tests in uscita ~
## - add mardown table in readme



board_register_github(repo = "Data-Network-Lab/dati-bollettino-sorveglianza")


## prima si tirano fuori tutti i links:
url_aggiornamenti <- "https://www.epicentro.iss.it/coronavirus/aggiornamenti"

baseurl <- "https://www.epicentro.iss.it/coronavirus/"

href_df <- url_aggiornamenti %>%
  read_html() %>%
  html_elements(css = "p") %>%
  html_elements(css = "a") %>%
  html_attr("href") %>%
  tibble() %>%
  rename(href_bollettino = ".") %>%
  filter(str_detect(href_bollettino, "Bollettino-sorveglianza-integrata")) %>%
  mutate(
    href_bollettino = paste0(baseurl, href_bollettino),
    data_bollettino = str_extract(href_bollettino, pattern = "(?<=\\_)(.*?)(?=\\.)")
  )


extract_href = function(target_url, url_path) {
  
  target_url %>%
    read_html() %>%
    html_elements(css = "p") %>%
    html_elements(css = "a") %>%
    html_attr("href") %>%
    tibble() %>%
    rename("href_bollettino" = ".") %>%
    filter(str_detect(href_bollettino, "Bollettino-sorveglianza-integrata")) %>%
    mutate(
      href_bollettino = paste0(url_path, href_bollettino),
      data_bollettino = str_extract(href_bollettino, pattern = "(?<=\\_)(.*?)(?=\\.)")
    ) %>% 
    return()
  
}


extract_href(url_aggiornamenti, baseurl)




######################
###### ESEMPIO #######
######################


## rand href
sample_href <- href_df[1] %>%
  sample_n(1) %>%
  pull()

## tabella pagina 13
distr_casi_table <- extract_tables(
  file = sample_href,
  method = "decide",
  output = "data.frame"
)

## il fatto è che ci sono due tabelle uguali
## e delle due va presa la prima,
## sostanzialemnte faccio un check sue names
## della tabella per verificare che sia cokrrettamente
## parsata, poi dopo vado a rimodellarla,
## ma non sto facendo il check su quale sia la tabella
## giusta da accedere


############################
####### FINE ESEMPIO #######
############################

# check_tables = function(table, name_1, name_2, name_3) {
#
#   check_soggetti_maschili = grepl(name_1, names(list_element), ignore.case = T)
#   check_soggetti_femminili = grepl(name_2, names(list_element), ignore.case = T)
#   check_casi_totali = grepl(name_3, names(list_element), ignore.case = T)
#
#   if (!any(name_1)) {
#     logger::log_error("{name_1} not found in table {names(table)}")
#     stop()
#
#   }
#   if (!any(name_2)) {
#     logger::log_error("{name_2} not found in table {names(table)}")
#     stop()
#
#   }
#   if (!any(name_3)) {
#     logger::log_error("{name_3} not found in table {names(table)}")
#     stop()
#
#   }
#   return(invisible())
#
# }

search_within_df(tables)


search_within_df <- function(list_element) {
  
  check_soggetti_maschili <- grepl("Soggetti.di.sesso.maschile", names(list_element), ignore.case = T)
  check_soggetti_femminili <- grepl("Soggetti.di.sesso.femminile", names(list_element), ignore.case = T)
  check_casi_totali <- grepl("Casi.totali", names(list_element), ignore.case = T)

  if (any(check_soggetti_maschili, check_soggetti_femminili, check_casi_totali)) {
    return(TRUE)
  }
}



### MVP

extract_table_index <- function(tables, search) {
  
 index = grep(
    map(
      tables, search
    ),
    pattern = TRUE
  )
if (length(index) == 2 | length(index) == 1) {
  index = 1
} 
 return(index)
 
 
}


#
# grep(map(distr_casi_table, search_within_df), pattern = TRUE) %>%
#   nth(-2)
#

#
#
# if(any(check_soggetti_maschili) && any(check_soggetti_femminili) && any(check_casi_totali)){
#   print("alleluja")
#


select_and_preprocess_table <- function(href, search) {
  
  tables <- extract_tables(
    file = href,
    method = "decide",
    output = "data.frame"
  )

  table_index <- extract_table_index(tables, search)

  tables %>%
    pluck(table_index) %>%
    slice(7:21) %>%
    tibble() %>%
    mutate(across(everything(), str_squish)) %>%
    {
      if (check_col_elements_length(., "Soggetti.di.sesso.maschile") == 3) {
        separate(
          .,
          Soggetti.di.sesso.maschile,
          sep = " ",
          into = c("n. casi (uomini)", "% casi totali (uomini)", "n. deceduti (uomini)", "% del totale deceduti (uomini)")
        ) %>%
          select(-X.1) %>%
          rename("Letalità % (uomini)" = "X.2") %>%
          separate(
            .,
            Soggetti.di.sesso.femminile,
            sep = " ",
            into = c("n. casi (donne)", "% casi totali (donne)", "n. deceduti (donne)", "% del totale deceduti (donne)")
          ) %>%
          ## tech debt
          drop_na() %>%
          ## tech debt
          filter(!row_number() == 11) %>%
          rename(
            "Classe di età (anni)"           = "X",
            "Letalità % (donne)"             =  "X.3",
            "n. casi (totali)"               = "X.4",
            "% casi totali (totali)"         = "X.5",
            "n. deceduti (totali)"           = "Casi.totali",
            "% del totale deceduti (totali)" = "X.6",
            "Letalità % (totale)"            = "X.7"
          )
      } else {
        separate(
          .,
          Soggetti.di.sesso.maschile,
          sep = " ",
          into = c("% casi totali (uomini)", "n. deceduti (uomini)", "% del totale deceduti (uomini)", "Letalità % (uomini)")
        ) %>%
          rename(
            "n. casi (uomini)" = "X.1"
          ) %>%
          separate(
            Soggetti.di.sesso.femminile,
            sep = " ",
            into = c("% casi totali (donne)", "n. deceduti (donne)", "% del totale deceduti (donne)")
          ) %>%
          rename(
            "n. casi (donne)" = "X.2",
            "Letalità % (donne)" = "X.3"
          ) %>%
          ## correct "Età non nota" dropped
          drop_na() %>%
          rename(
            "Classe di età (anni)"           = "X",
            "n. casi (totali)"               = "X.4",
            "% casi totali (totali)"         = "X.5",
            "n. deceduti (totali)"           = "Casi.totali",
            "% del totale deceduti (totali)" = "X.6",
            "Letalità % (totale)"            = "X.7"
          ) 
      }
    } -> parsed_table


  return(parsed_table)

  # pin(parsed_table, name = glue("table_data/bollettino_sorveglianza_integrata_30-giugno-2021"))
}


