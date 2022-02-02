#install.packages("tidyverse")
#install.packages("rcrossref")
library(tidyverse)
library(rcrossref)

#set email in Renviron
#file.edit("~/.Renviron")
#add email address to be shared with Crossref:
#crossref_email = name@example.com
#save the file and restart your R session
  
#Use low level API to get issn_type and issn_value (but still not member ID)
#set parse = FALSE to get JSON, parse = TRUE to get list output
getCrossref_low <- function(offset){
  res <- cr_journals_(offset = offset,
                     limit = 1000,
                     parse = TRUE) %>%
  
  .$message %>%
  .$items
  
  return(res)
}

#add progress bar to function
getCrossref_low_progress <- function(offset){
  pb$tick()$print()
  result <- getCrossref_low(offset)
  
  return(result)
}

#extract relevant variables with pluck
extractData <- function(x){
  data <- tibble(
    title = map_chr(x, "title", .default = NA_character_),
    publisher = map_chr(x, "publisher", .default = NA_character_),
    issn = map(x, "issn-type", .default = NULL),
    dois_current = map_dbl(x, 
                           list("counts",
                                "current-dois"),
                                 .default = 0),
    dois_backfile = map_dbl(x, 
                           list("counts",
                               "backfile-dois"),
                           .default = 0),
    dois_total = map_dbl(x, 
                           list("counts",
                                "total-dois"),
                           .default = 0)) %>%
    #unnest ISSNs
    unnest(issn, keep_empty = TRUE) %>%
    unnest_wider(issn) %>%
    rename(issn = value,
           issn_type = type)
  
  #NB some titles have > 1 of a specific issn-type (print or electronic)
  #so #pivot_wider will result in list column -> not done for now
  
  return(data)
}

#------------------------------------------------------------------------------

#set date
date <- Sys.Date()
date <- "2022-02-01"
#create output directory
path <- file.path("data",date) 
dir.create(path)


#get number of journals
res <- cr_journals(limit=0)
total <- res$meta$total_results
#n=99778

#set vector of offset values
c <- seq(0, total, by=1000)

#set parameter for progress bar
pb <- progress_estimated(length(c))

#get API results, flatten into 1 list
res <- map(c, getCrossref_low_progress) %>%
  flatten()

#extract data
data <- extractData(res) %>%
  distinct()

filename <- paste0("crossref_issn_",date,".csv")
filepath <- file.path(path, filename)
write_csv(data, filepath)

#list of unique issns
unique_issn <- data %>%
  select(issn) %>%
  distinct() %>%
  mutate(in_Crossref = "Crossref")

filename <- paste0("crossref_issn_unique_",date,".csv")
filepath <- file.path(path, filename)
write_csv(unique_issn, filepath)


