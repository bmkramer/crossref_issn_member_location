# crossref_issn_member_location
##Matching ISSN, member ID  and member location in Crossref

###Workflow described in this repo:

1a) Collect information on ISSNs (ISSN, journal title, publisher, doi counts) through the Crossref REST API via the journals route 
Script: 01a_crossref_issn.R

1b) Collect information on members (member id, name, location) through the Crossref REST API via the members route
Script: 01b_crossref_members_location.R

external step) From information on ISSN and member ID from all individual Crossref DOIs, identify all existing ISSN - memberID links. This is done using Crossref metadata Plus data through Google Big Query, using Curtin Open Knowledge Institute (COKI) infrastructure. 
SQL query: sql/COKI_GBQ_crossref_issn_member.sql

2) Join member information (member name, member location) to ISSN-member links
Script: 02_crossref_merge.R

All data are in the folder data, with subfolders for each sample date.

### Known issues / limitations

- Real-time sampling of the Crossref API will give more recent results than querying the most recent Metadata Plus datadump. All information is matched to the linked issn-member pairs from the Metadata Plus data. 

- In some cases, ISSNs are linked to multiple members, potentially due to journal transfers. One way around this (esp. when mostly interested in the current situation), could be to look at the most recent DOI record for each ISSN. This is currently not implemented. 

- Journals with both print ISSN and eISSN in Crossref are duplicated in the final result, with one line for each ISSN. They can be deduplicated using the information on ISSNs collected in step 1a. This is currently not implemented.  


