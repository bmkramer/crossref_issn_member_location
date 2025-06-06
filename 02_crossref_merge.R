#install.packages("tidyverse")
#install.packages("rcrossref")
library(tidyverse)


#set date to date of data collection
#date <- Sys.Date()
date <- "2022-02-01"

#set path
path <- file.path("data",date) 

#Use COKI instance of Crossref metadata to link issns to member id
#Include date of most recently created record, to be able to only keep current member id
#Include date instance of Crossref metadata file in output filename
#Script: sql/COKI_GBQ_crossref_issn_member.sql
#Data: data/[path]/crossref_issn_member_metadata_plus_xxxx-xx-xx.csv

date_metadata_plus <- "2021-12-07"

#Read files
cr_issn <- read_csv(paste0(path,"/crossref_issn_",date,".csv"))
cr_members <- read_csv(paste0(path, "/crossref_members_location_",date,".csv"))
cr_link <- read_csv(paste0(path, "/crossref_issn_member_metadata_plus_",date_metadata_plus,".csv"))


#keep most recent issn-member pairs (based on latest created_date from Crossref records)
cr_link_current <- cr_link %>%
  group_by(issn) %>%
  arrange(desc(created_date)) %>%
  slice(1) %>%
  ungroup() %>%
  select(-created_date)

#join issn and member data to issn_member links
cr_joined <- cr_link_current %>%
  left_join(cr_members, by = c("member" = "member_id")) %>%
  #remove member location, only keep member country
  select(-member_location)

filename <- paste0("crossref_issn_member_location_",date,".csv")
filepath <- file.path(path, filename)
write_csv(cr_joined, filepath)





