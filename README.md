<!-- README.md is generated from README.Rmd. Please edit that file -->
The California Department of Education in R
===========================================

![](https://upload.wikimedia.org/wikipedia/commons/4/40/Seal_of_the_California_Department_of_Education.jpg)

The California Department of Education provides ample data. Now, that data is available in R.

Installation
------------

``` r
devtools::install_github("daranzolin/rCAEDDATA")
library(rCAEDDATA)
```

Available Datasets
------------------

-   [Cohort Outcome Data ("cohorts")](http://www.cde.ca.gov/ds/sd/sd/filescohort.asp) -- California Longitudinal Pupil Achievement Data System (CALPADS) cohort outcome data reported by race/ethnicity, program participation, and gender.

-   [Dropouts by Race and Gender ("dropouts")](http://www.cde.ca.gov/ds/sd/sd/filesdropouts.asp) -- Data for grade seven through twelve dropouts and enrollment by race/ethnic designation and gender by school.

-   [English Learners by Grade and Language ("english\_learners")](http://www.cde.ca.gov/ds/sd/sd/fileselsch.asp) -- Data for English learners (ELs) by grade, language, and school.

-   [Enrollment by School ("enrollments")](http://www.cde.ca.gov/ds/sd/sd/filesenr.asp) -- Data for school-level enrollment by racial/ethnic designation, gender, and grade.

-   [Student Poverty FRPM ("frpm")](http://www.cde.ca.gov/ds/sd/sd/filessp.asp) -- Data for students eligible for Free or Reduced Price Meals (FRPM).

-   [Graduates by Race and Gender ("graduates")](http://www.cde.ca.gov/ds/sd/sd/filesgrads.asp) -- Data for graduates and graduates meeting University of California (UC)/California State University (CSU) entrance requirements by race/ethnic designation and gender by school.

-   [Primary and Short-Term Enrollment ("primary\_and\_short\_term")](http://www.cde.ca.gov/ds/sd/sd/filesenrps.asp) -- Data for primary and short-term school-level enrollment by racial/ethnic designation, gender, and grade.

Examples
--------

### Graduates

``` r
library(rCAEDDATA)
library(tidyverse)
#> Loading tidyverse: ggplot2
#> Loading tidyverse: tibble
#> Loading tidyverse: tidyr
#> Loading tidyverse: readr
#> Loading tidyverse: purrr
#> Loading tidyverse: dplyr
#> Conflicts with tidy packages ----------------------------------------------
#> filter(): dplyr, stats
#> lag():    dplyr, stats
data("graduates")
graduates %>% 
  group_by(YEAR) %>% 
  summarize(total_grads = sum(GRADS),
            Yes = sum(UC_GRADS),
            No = total_grads - Yes) %>%
  select(-total_grads) %>% 
  gather(Eligibility, Graduates, -YEAR) %>% 
  ggplot(aes(YEAR, Graduates, fill = Eligibility)) +
  geom_bar(stat = "identity", color = "black") +
  labs(x = "Year",
       y = "Graduates",
       title = "California High School Graduates, 1992-2016",
       fill = "UC Eligible?") +
  scale_y_continuous(labels = scales::comma) +
  scale_fill_manual(values = c("yellow", "lightblue")) +
  theme_minimal() 
```

![](README-unnamed-chunk-3-1.png)

### Dropouts

``` r
data("dropouts")
dropouts %>% 
  select(GENDER, matches("D[0-9]{1,2}")) %>% 
  gather(GRADE, DROPOUTS, -GENDER) %>% 
  mutate(GRADE = as.numeric(stringr::str_replace(GRADE, "D", ""))) %>% 
  group_by(GENDER, GRADE) %>% 
  summarize(DROPOUTS = sum(DROPOUTS)) %>% 
  ggplot(aes(GRADE, DROPOUTS, fill = GENDER)) +
  geom_bar(stat = "identity", position = "fill") +
  scale_x_continuous(breaks = c(7:12)) +
  labs(x = "Grade",
       y = "",
       title = "Proportion of Student Dropouts by Gender, Grades 7-12",
       fill = "Gender") +
  theme_minimal()
```

![](README-unnamed-chunk-4-1.png)

### Enrollments

``` r
enrollments %>% 
  mutate(ETHNIC = case_when(
    ETHNIC == 0 ~ "Not Reported",
    ETHNIC == 1 ~ "American Indian",
    ETHNIC == 2 ~ "Asian",
    ETHNIC == 3 ~ "Pacific Islander",
    ETHNIC == 4 ~ "Filipino",
    ETHNIC == 5 ~ "Hispanic",
    ETHNIC == 6 ~ "African American",
    ETHNIC == 7 ~ "White",
    ETHNIC == 9 | ETHNIC == 8 ~ "Two or More")
    ) %>% 
  filter(DISTRICT %in% c("Santa Clara Unified",
                         "Milpitas Unified",
                         "San Jose Unified",
                         "Fremont Union High",
                         "Mountain View-Los Altos Union High",
                         "Cupertino Union",
                         "Campbell Union", 
                         "Cambrian",
                         "Palo Alto Unified")
  ) %>% 
  select(DISTRICT, YEAR, ETHNIC, starts_with("GR_")) %>% 
  gather(GRADE, STUDENTS, -DISTRICT, -YEAR, -ETHNIC) %>% 
  group_by(DISTRICT, YEAR, ETHNIC) %>% 
  summarize(TOTAL_STUDENTS = sum(STUDENTS)) %>% 
  ggplot(aes(YEAR, TOTAL_STUDENTS, fill = ETHNIC)) +
  geom_bar(stat = "identity", position = "fill") +
  facet_wrap(~DISTRICT, nrow = 3) +
  labs(x = "Year",
       y = "",
       title = "Ethnic Diversity in Silicon Valley, 2007-2017",
       subtitle = "Santa Clara Districts",
       fill = "Ethnicity") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

![](README-unnamed-chunk-5-1.png)
