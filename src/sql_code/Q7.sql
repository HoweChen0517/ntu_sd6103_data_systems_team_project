-- (a)
SELECT a.name as author_name
FROM Authors as a
JOIN 
    author_publications as ap on a.author_id = ap.author_id
JOIN 
    publication p on ap.pub_id = p.pub_id
WHERE a.name LIKE 'H%' and p.year between 1994 and 2023
GROUP BY a.author_id, a.name
HAVING COUNT(DISTINCT p.year) = 30; 

-- (b)
SELECT a.name as author_name, COUNT(ap.pub_id) as num_publications, MIN(p.year) as first_publication_year
FROM Authors as a
JOIN 
    author_publications ap on a.author_id = ap.author_id
JOIN 
    publication p on ap.pub_id = p.pub_id
WHERE 
    p.year = ( SELECT MIN(p.year) as earliest_year from publication p ) 
GROUP BY a.author_id, a.name
ORDER BY num_publications DESC;
