SELECT 
    c.conf_name
FROM 
    publication_conferences as pc
JOIN 
    conference as c ON pc.conf_id = c.conf_id
GROUP BY 
    c.conf_name, c.year
HAVING 
    COUNT(pc.pub_id) > 800;
