## Matching ISSN, member ID  and member location in Crossref

### Workflow described in this repo:

1a) Collect information on ISSNs (ISSN, journal title, publisher, doi counts) through the Crossref REST API via the journals route  
Script: [01a_crossref_issn.R](01a_crossref_issn.R)

1b) Collect information on members (member id, name, location) through the Crossref REST API via the members route. A column country is added by extracting that information from the member location.  
Script: [01b_crossref_members_location.R](01b_crossref_members_location.R)

_external step_) From information on ISSN and member ID for all individual Crossref DOIs, identify all ISSN - memberID links*. This is done using Crossref Metadata Plus data through Google Big Query, using [Curtin Open Knowledge Institute (COKI)](@Curtin-Open-Knowledge-Initiative) infrastructure.  
SQL query: [sql/COKI_GBQ_crossref_issn_member.sql](sql/COKI_GBQ_crossref_issn_member.sql)

*In some cases, ISSNs are linked to multiple members, potentially due to journal transfers. By looking at the most recent DOI record for each ISSN-memberID pair, the current member ID for each ISSN can be identified in step 2 below.

2 ) Join member information (member name, member county) to current ISSN <-> member links  
Script: [02_crossref_merge.R](02_crossref_merge.R)

### Data
All data are in the folder [data](data/), with subfolders for each sample date.

**Information on ISSNs from Crosssref API**:  
- crossref_issn_[date].csv
- crossref_issn_unique_[date].csv  

**Information on ISSNs from Crosssref API**:  
- crossref_members_location_[date].csv  

**Information on members from Crosssref API**:  
- crossref_issn_member_metadataplus_[metadata plus date].csv  

**Matched ISSN - member id - member location**:  
- crossref_issn_member_location_[date].csv  

### Known issues / limitations

- Real-time sampling of the Crossref API will give more recent results than querying the most recent Metadata Plus datadump. All information is matched to the linked issn-member pairs from the Metadata Plus data. 

- Journals with both print ISSN and eISSN in Crossref are duplicated in the final result, with one line for each ISSN. They can be deduplicated using the information on ISSNs collected in step 1a. This is currently not implemented.  


