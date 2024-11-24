SELECT 
    c.conf_name as conference_name, p.year as year_held_in_june, COUNT(pc.pub_id) as num_publications
FROM 
    conference as c
JOIN 
    publication_conferences as pc on c.conf_id = pc.conf_id
JOIN 
    publication p on pc.pub_id = p.pub_id
WHERE 
    MONTH(p.mdate) = 6 
GROUP BY 
    c.conf_name, p.year
HAVING 
    COUNT(pc.pub_id) > 100 
ORDER BY 
    c.conf_name, p.year;
