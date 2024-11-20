-- Test Example
SELECT ap.author_id, ap.pub_id, a.name, p.year, p.title
FROM DBLP.author_publications as ap
LEFT JOIN DBLP.authors as a
ON ap.author_id = a.author_id
LEFT JOIN DBLP.publication as p
ON ap.pub_id = p.pub_id
WHERE a.name = 'Dacheng Tao'
LIMIT 10;