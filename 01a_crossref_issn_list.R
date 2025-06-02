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
getCrossref_low <- function(ISSN){
  res <- cr_journals_(issn = ISSN,
                     parse = TRUE) #%>%
  
  #.$message %>%
  #.$items
  
  return(res)
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
                           .default = 0)) 
  
  #NB some titles have > 1 of a specific issn-type (print or electronic)
  #so #pivot_wider will result in list column -> not done for now
  
  return(data)
}

#------------------------------------------------------------------------------

#set date
date <- Sys.Date()
#date <- "2023-01-11"
#create output directory
path <- file.path("data",date) 
dir.create(path)

# get source issns from csv
source <- read_csv("input data/pkp_cr_issn_member.csv") %>%
  select(cr_issn) %>%
  head(10)

test2 <- source %>%
  map("cr_issn", getCrossref_low)

# query crossref api (journal route)
res <- map(s, getCrossref_low) %>%
  flatten()

#get number of journals
res <- cr_journals(limit=0)
total <- res$meta$total_results
#n=149312

#set vector of offset values
c <- seq(0, total, by=1000)

#set parameter for progress bar
pb <- progress_estimated(length(c))

#get API results, flatten into 1 list
res <- map(c, getCrossref_low) %>%
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


res_json <- getCrossref_low()