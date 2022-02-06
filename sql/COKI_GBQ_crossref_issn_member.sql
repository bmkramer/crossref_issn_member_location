WITH table AS (
    
SELECT 
issn.value as issn,
member,
extract(DATE FROM created.date_time) as created_date
--- `issued` only has date parts, `created` has timestamp
---  `publisher` not included since not unique for each member id

FROM `academic-observatory.crossref.crossref_metadata20211207`,
UNNEST (issn_type) AS issn

GROUP BY issn, member, created_date
)

SELECT AS VALUE ARRAY_AGG(table ORDER BY created_date DESC LIMIT 1)[OFFSET(0)]
FROM table 
GROUP BY issn, member 
--- this selects the most recent created_date of each issn-member pair
--- allowing to filter on most recent member for each issn (not included in this sql query)  
