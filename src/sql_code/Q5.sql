SELECT a.name as author_name, COUNT(ap.pub_id) as num_publications
FROM author_publications ap
JOIN publication p on ap.pub_id = p.pub_id
LEFT JOIN publication_conferences pc on p.pub_id = pc.pub_id
LEFT JOIN conference c on pc.conf_id = c.conf_id
LEFT JOIN publication_journals pj on p.pub_id = pj.pub_id
LEFT JOIN journal j on pj.journal_id = j.journal_id
JOIN Authors as a on ap.author_id = a.author_id
WHERE (c.conf_name LIKE '%Data%' or j.journal_name LIKE '%Data%')
    and p.year BETWEEN 2019 and 2023
GROUP BY ap.author_id, a.name
ORDER BY num_publications DESC
LIMIT 10;
