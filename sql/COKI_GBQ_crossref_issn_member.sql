SELECT 

issn.value as issn,
member,
publisher

FROM `academic-observatory.crossref.crossref_metadata20211207`,
UNNEST (issn_type) AS issn

GROUP BY issn, member, publisher 