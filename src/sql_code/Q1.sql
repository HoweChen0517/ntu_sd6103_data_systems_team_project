SELECT  X.type as publication_type, count(*) as count
FROM ( SELECT * FROM publication as p WHERE p.year>=2013 and p.year<=2024 ) as X
GROUP BY X.type