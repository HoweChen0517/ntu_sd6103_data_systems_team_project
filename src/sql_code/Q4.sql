WITH FilteredPub AS (
    SELECT DISTINCT p.pub_id
    FROM publication as p
    LEFT JOIN publication_conferences pc on p.pub_id = pc.pub_id
    LEFT JOIN conference c on pc.conf_id = c.conf_id
    LEFT JOIN publication_journals pj on p.pub_id = pj.pub_id
    LEFT JOIN journal j on pj.journal_id = j.journal_id
    WHERE c.conf_name LIKE '%data%' or j.journal_name LIKE '%data%'
),
CoAuthors AS (
    SELECT DISTINCT X.author_id as author_id, Y.author_id as collaborator_id
    FROM author_publications as X
    JOIN author_publications as Y 
        ON X.pub_id = Y.pub_id and X.author_id != Y.author_id
    WHERE X.pub_id IN (SELECT pub_id FROM FilteredPub)
),
CollaboratorCounts AS (
    SELECT author_id, COUNT(DISTINCT collaborator_id) as num_collaborators
    FROM CoAuthors
    GROUP BY author_id
)
SELECT a.name as author_name, c.num_collaborators
FROM CollaboratorCounts as c
JOIN Authors a on c.author_id = a.author_id
ORDER BY c.num_collaborators DESC
LIMIT 1;
