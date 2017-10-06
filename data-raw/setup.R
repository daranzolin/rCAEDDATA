library(rvest)
library(stringr)
library(tidyverse)

url <- "http://www.cde.ca.gov/ds/sd/sd/index.asp"
files <- url %>%
  read_html() %>%
  html_nodes("h3+ ul a") %>%
  html_attr("href")

file_paths <- paste0("http://www.cde.ca.gov/ds/sd/sd/", files)

get_text_urls <- function(page) {
  page %>%
    read_html() %>%
    html_nodes("td:nth-child(2) a") %>%
    html_attr("href")
}

all_files <- map(file_paths, function(x) {
  message("Sleeping...")
  Sys.sleep(2)
  get_text_urls(x)
})

file_names <- flatten_chr(all_files)
usable_file_names <- file_names[!str_detect(file_names, ".exe|.dbf")]

download_ca_file <- function(url) {
  destfile_name <- url %>%
    str_replace("http://dq.cde.ca.gov/dataquest/dlfile/dlfile.aspx?", "") %>%
    str_replace("ftp://ftp.cde.ca.gov/demo/", "") %>%
    str_replace("http://www.cde.ca.gov/ds/sd/sd/documents/", "") %>%
    str_replace("http://dq.cde.ca.gov/dataquest/", "") %>%
    str_replace("\\?cLevel=School&", "") %>%
    str_replace_all("=", "_")
  destfile_name <- case_when(!grepl(".txt$", destfile_name) & !grepl(".xls$", destfile_name) ~ paste0(destfile_name, ".txt"),
            TRUE ~ destfile_name)
  safely(download.file(url, destfile = paste0("CA_eddata/", destfile_name)))
}

for (url in usable2) {
  download_ca_file(url)
  Sys.sleep(2)
}

year_levels <- c(
  "9091", "9192", "9293", "9394", "9495", "9596", "9697", "9798", "9899", "9900",
  "0001", "0102", "0203", "0304", "0405", "0506", "0607", "0708", "0809", "0910",
  "1011", "1112", "1213", "1314", "1415", "1516", "1617"
)

# Downloadable data files for graduates and graduates meeting
# University of California (UC)/California State University (CSU)
# entrance requirements by race/ethnic designation and gender by school.
graduates <- dir() %>%
  keep(str_detect(., "filesgrads.txt")) %>%
  map(read_tsv) %>%
  map_df(mutate, YEAR = factor(YEAR, year_levels))
saveRDS(graduates, "graduates.rds")

# Downloadable data files pertaining to students eligible for
# Free or Reduced Price Meals (FRPM).
frpm <- dir() %>%
  keep(str_detect(., "frpm")) %>%
  map(read_xls, sheet = 2, col_names = FALSE) %>%
  map_df(function(x) {
    header <- unlist(x[1,])
    d <- x[-c(1:2),]
    names(d) <- header
    d
  })
saveRDS(frpm, "frpm.rds")


# California Longitudinal Pupil Achievement Data System (CALPADS) cohort
# outcome data reported by race/ethnicity, program participation, and gender.
cohorts <- dir() %>%
  keep(str_detect(., "filescohort.txt")) %>%
  map(read_tsv) %>%
  map_df(mutate, Year = factor(Year, year_levels))
saveRDS(cohorts, "cohorts.rds")

#Downloadable data files pertaining to the California Longitudinal Pupil Achievement Data System (CALPADS)
# UPC Source File for grades K-12.

calpads <- dir() %>%
  keep(str_detect(., "cupc[0-9]{4}.xls")) %>%
  map(read_xls)

# Downloadable data files for school-level enrollment by
# racial/ethnic designation, gender, and grade.

read_and_mutate_with_year <- function(file) {
  year <- str_extract(file, "[0-9]{4}-[0-9]{2}|[0-9]{4}")
  read_tsv(file) %>%
    mutate(YEAR = year)
}

enrollments <- dir() %>%
  keep(str_detect(., "filesenr.asp.txt")) %>%
  map(read_and_mutate_with_year) %>%
  map_df(mutate, CDS_CODE = as.character(CDS_CODE)) %>%
  mutate(YEAR = factor(YEAR, levels = c("9495", "9596", "9697", "9798", "9899", "9900",
                                        "0001", "0102", "0203", "0304", "0405", "0506", "0607", "2007-08", "2008-09", "2009-10",
                                        "2010-11", "2011-12", "2012-13", "2013-14", "2014-15", "2015-16", "2016-17")))
saveRDS(enrollments, "enrollments.rds")

# Downloadable data files for primary and short-term school-level enrollment
# by racial/ethnic designation, gender, and grade.

primary_and_short_term <- dir() %>%
  keep(str_detect(., "filesenrps.asp.txt")) %>%
  map(read_tsv) %>%
  map_df(mutate, YEAR = factor(YEAR, year_levels))
saveRDS(primary_and_short_term, "primary_and_short_term.rds")

# Downloadable data files for grade seven through twelve dropouts and enrollment
# by race/ethnic designation and gender by school.

dropouts <- dir() %>%
  keep(str_detect(., "filesdropouts.txt")) %>%
  map(read_tsv) %>%
  map_df(mutate, YEAR = factor(YEAR, year_levels))
saveRDS(dropouts, "dropouts.rds")

# Downloadable data files for English learners (ELs) by grade, language, and school.

english_leaners <- dir() %>%
  keep(str_detect(., "fileselsch.txt")) %>%
  map_df(read_and_mutate_with_year)
saveRDS(english_leaners, "english_learners.rds")

library(devtools)

use_data(cohorts)
use_data(dropouts)
use_data(english_learners)
use_data(enrollments)
use_data(frpm)
use_data(graduates)
use_data(primary_and_short_term)





