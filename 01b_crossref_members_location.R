#install.packages("tidyverse")
#install.packages("rcrossref")
library(tidyverse)
library(rcrossref)

#set email in Renviron
#file.edit("~/.Renviron")
#add email address to be shared with Crossref:
#crossref_email = name@example.com
#save the file and restart your R session
  
#Use high level API that gives df as output
#includes location info, which is sufficient for this purpose

getCrossref_high <- function(offset){
  res <- cr_members(offset = offset,
                     limit = 1000) %>%
    .$data %>%
    select(id, primary_name, location)
}

#add progress bar to function
getCrossref_high_progress <- function(offset){
  pb$tick()$print()
  result <- getCrossref_high(offset)
  
  return(result)
}


#------------------------------------------------------------------------------

#set date to date of sampling
date <- Sys.Date()
#date <- "2022-02-01"
#set output directory
path <- file.path("data",date) 


#get number of members
res <- cr_members(limit=0)
total <- res$meta$total_results
#n=21089


#set vector of offset values
c <- seq(0, total, by=1000)

#set parameter for progress bar
pb <- progress_estimated(length(c))

#get API results
res <- map_dfr(c, getCrossref_high_progress)

#post-processing
data <- res %>%
  rename(member_id = id,
         member_primary_name = primary_name,
         member_location = location) %>%
  mutate(member_country = str_remove(member_location, ".*, "))

filename <- paste0("crossref_members_location_",date,".csv")
filepath <- file.path(path, filename)
write_csv(data, filepath)

