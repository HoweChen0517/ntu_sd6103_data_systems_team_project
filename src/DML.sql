-- Active: 1732075506913@@127.0.0.1@3306@DBLP
-- -- Test Example
-- SELECT ap.author_id, ap.pub_id, a.name, p.year, p.title
-- FROM DBLP.author_publications as ap
-- LEFT JOIN DBLP.authors as a
-- ON ap.author_id = a.author_id
-- LEFT JOIN DBLP.publication as p
-- ON ap.pub_id = p.pub_id
-- WHERE a.name = 'Dacheng Tao'
-- LIMIT 10;

-- 1. For each type of publication, count the total number of publications of that type between 2014- 2023. 
-- Your query should return a set of (publication-type, count) pairs. 
-- For example, (article, 20000), (inproceedings, 30000), ...
SELECT type, COUNT(pub_id) as count
FROM DBLP.publication
WHERE year >= 2014 AND year <=2023
GROUP BY type;

-- 2. Find all the conferences that have ever published more than 800 papers in one year. 
-- Note that one conference may be held every year 
-- (e.g., KDD runs many years, and each year the conference has a number of papers).
SELECT pc.conf_id, c.conf_name, c.year, COUNT(pc.pub_id) as count
FROM DBLP.publication_conferences pc
LEFT JOIN DBLP.conference c
ON pc.conf_id = c.conf_id
GROUP BY pc.conf_id, c.year
HAVING COUNT(pc.pub_id) >= 800;

-- 3. For each 10 consecutive years starting from 1974, i.e., [1974, 1983], [1984, 1993],…, [2014, 2023], 
-- compute the total number of conference publications in DBLP in that 10 years. 
-- Hint: for this query you may want to compute a temporary table with all distinct years.
WITH DistinctYears AS (
    SELECT DISTINCT year
    FROM conference
    WHERE year >= 1974 and year < 2024
),
YearRanges AS (
    SELECT FLOOR((year - 1974) / 10) as range_group, MIN(year) as start_year, MAX(year) as end_year
    FROM DistinctYears
    GROUP BY FLOOR((year - 1974) / 10)
)
SELECT 
    CONCAT(yr.start_year, '-', yr.end_year) as year_range, COUNT(pc.pub_id) as total_publications
FROM YearRanges as yr
LEFT JOIN conference c on c.year between yr.start_year and yr.end_year
LEFT JOIN publication_conferences pc on pc.conf_id = c.conf_id
GROUP BY yr.start_year, yr.end_year
ORDER BY yr.start_year;

-- 4. Find the most collaborative authors who published in a conference or journal whose name contains “data” 
-- (e.g., ACM SIGKDD International Conference on Knowledge Discovery and Data Mining). 
-- That is, for each author determine its number of collaborators, 
-- and then find the author with the most number of collaborators. 
-- Hint: for this question you may want to compute a temporary table of coauthors.
WITH FilteredPub AS (
    SELECT DISTINCT p.pub_id
    FROM publication as p
    LEFT JOIN publication_conferences pc on p.pub_id = pc.pub_id
    LEFT JOIN conference c on pc.conf_id = c.conf_id
    LEFT JOIN journal j on p.journal_id = j.journal_id
    WHERE c.conf_name LIKE '%data%' or j.name LIKE '%data%'
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

-- 5. Data analytics and data science are very popular topics. 
-- Find the top 10 authors with the largest number of publications that are published in conferences 
-- and journals whose titles contain word “Data” in the last 5 years (2019 - 2023).
SELECT a.name as author_name, COUNT(ap.pub_id) as num_publications
FROM author_publications ap
JOIN publication p on ap.pub_id = p.pub_id
LEFT JOIN publication_conferences pc on p.pub_id = pc.pub_id
LEFT JOIN conference c on pc.conf_id = c.conf_id
LEFT JOIN journal j on p.journal_id = j.journal_id
JOIN Authors as a on ap.author_id = a.author_id
WHERE (c.conf_name LIKE '%Data%' or j.name LIKE '%Data%')
    and p.year BETWEEN 2019 and 2023
GROUP BY ap.author_id, a.name
ORDER BY num_publications DESC
LIMIT 10;

-- 6. List the name of the conferences such that it has ever been held in June, 
-- and the corresponding proceedings (in the year where the conference was held in June)
-- contain more than 100 publications.
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

-- 7. (a)Find authors who have published at least 1 paper every year in the last 30 years (1994 - 2023), 
-- and whose family name start with ‘H’
SELECT a.name as author_name
FROM Authors as a
JOIN 
    author_publications as ap on a.author_id = ap.author_id
JOIN 
    publication p on ap.pub_id = p.pub_id
WHERE a.name LIKE 'H%' and p.year between 1994 and 2023
GROUP BY a.author_id, a.name
HAVING COUNT(DISTINCT p.year) = 30;

-- 7. (b)Find the names and number of publications for authors who have the earliest publication record in DBLP.
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

-- 8. Design a join query that is not in the above list.
SELECT c.conf_name as conference_name, p.name as publisher_name
FROM conference as c
JOIN conference_publisher cp on c.conf_id = cp.conf_id
JOIN Publisher p on cp.publisher_id = p.publisher_id;

--------------------------------------------Half--------------------------------------------

-- 1. For each type of publication, count the total number of publications of that type between 2014- 2023. 
-- Your query should return a set of (publication-type, count) pairs. 
-- For example, (article, 20000), (inproceedings, 30000), ...
SELECT type, COUNT(pub_id) as count
FROM DBLP.half_publication
WHERE year >= 2014 AND year <=2023
GROUP BY type;

-- 2. Find all the conferences that have ever published more than 800 papers in one year. 
-- Note that one conference may be held every year 
-- (e.g., KDD runs many years, and each year the conference has a number of papers).
SELECT pc.conf_id, c.conf_name, c.year, COUNT(pc.pub_id) as count
FROM DBLP.half_publication_conferences pc
LEFT JOIN DBLP.half_conference c
ON pc.conf_id = c.conf_id
GROUP BY pc.conf_id, c.year
HAVING COUNT(pc.pub_id) >= 800;

-- 3. For each 10 consecutive years starting from 1974, i.e., [1974, 1983], [1984, 1993],…, [2014, 2023], 
-- compute the total number of conference publications in DBLP in that 10 years. 
-- Hint: for this query you may want to compute a temporary table with all distinct years.
WITH DistinctYears AS (
    SELECT DISTINCT year
    FROM half_conference
    WHERE year >= 1974 and year < 2024
),
YearRanges AS (
    SELECT FLOOR((year - 1974) / 10) as range_group, MIN(year) as start_year, MAX(year) as end_year
    FROM DistinctYears
    GROUP BY FLOOR((year - 1974) / 10)
)
SELECT 
    CONCAT(yr.start_year, '-', yr.end_year) as year_range, COUNT(pc.pub_id) as total_publications
FROM YearRanges as yr
LEFT JOIN half_conference c on c.year between yr.start_year and yr.end_year
LEFT JOIN half_publication_conferences pc on pc.conf_id = c.conf_id
GROUP BY yr.start_year, yr.end_year
ORDER BY yr.start_year;

-- 4. Find the most collaborative authors who published in a conference or journal whose name contains “data” 
-- (e.g., ACM SIGKDD International Conference on Knowledge Discovery and Data Mining). 
-- That is, for each author determine its number of collaborators, 
-- and then find the author with the most number of collaborators. 
-- Hint: for this question you may want to compute a temporary table of coauthors.
WITH FilteredPub AS (
    SELECT DISTINCT p.pub_id
    FROM half_publication as p
    LEFT JOIN half_publication_conferences pc on p.pub_id = pc.pub_id
    LEFT JOIN half_conference c on pc.conf_id = c.conf_id
    LEFT JOIN half_journal j on p.journal_id = j.journal_id
    WHERE c.conf_name LIKE '%data%' or j.name LIKE '%data%'
),
CoAuthors AS (
    SELECT DISTINCT X.author_id as author_id, Y.author_id as collaborator_id
    FROM half_author_publications as X
    JOIN half_author_publications as Y 
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
JOIN half_authors a on c.author_id = a.author_id
ORDER BY c.num_collaborators DESC
LIMIT 1;

-- 5. Data analytics and data science are very popular topics. 
-- Find the top 10 authors with the largest number of publications that are published in conferences 
-- and journals whose titles contain word “Data” in the last 5 years (2019 - 2023).
SELECT a.name as author_name, COUNT(ap.pub_id) as num_publications
FROM half_author_publications ap
JOIN half_publication p on ap.pub_id = p.pub_id
LEFT JOIN half_publication_conferences pc on p.pub_id = pc.pub_id
LEFT JOIN half_conference c on pc.conf_id = c.conf_id
LEFT JOIN half_journal j on p.journal_id = j.journal_id
JOIN half_authors as a on ap.author_id = a.author_id
WHERE (c.conf_name LIKE '%Data%' or j.name LIKE '%Data%')
    and p.year BETWEEN 2019 and 2023
GROUP BY ap.author_id, a.name
ORDER BY num_publications DESC
LIMIT 10;

-- 6. List the name of the conferences such that it has ever been held in June, 
-- and the corresponding proceedings (in the year where the conference was held in June)
-- contain more than 100 publications.
SELECT 
    c.conf_name as conference_name, p.year as year_held_in_june, COUNT(pc.pub_id) as num_publications
FROM 
    half_conference as c
JOIN 
    half_publication_conferences as pc on c.conf_id = pc.conf_id
JOIN 
    half_publication p on pc.pub_id = p.pub_id
WHERE 
    MONTH(p.mdate) = 6 
GROUP BY 
    c.conf_name, p.year
HAVING 
    COUNT(pc.pub_id) > 100 
ORDER BY 
    c.conf_name, p.year;

-- 7. (a)Find authors who have published at least 1 paper every year in the last 30 years (1994 - 2023), 
-- and whose family name start with ‘H’
SELECT a.name as author_name
FROM half_authors as a
JOIN 
    half_author_publications as ap on a.author_id = ap.author_id
JOIN 
    half_publication p on ap.pub_id = p.pub_id
WHERE a.name LIKE 'H%' and p.year between 1994 and 2023
GROUP BY a.author_id, a.name
HAVING COUNT(DISTINCT p.year) = 30;

-- 7. (b)Find the names and number of publications for authors who have the earliest publication record in DBLP.
SELECT a.name as author_name, COUNT(ap.pub_id) as num_publications, MIN(p.year) as first_publication_year
FROM half_authors as a
JOIN 
    half_author_publications ap on a.author_id = ap.author_id
JOIN 
    half_publication p on ap.pub_id = p.pub_id
WHERE 
    p.year = ( SELECT MIN(p.year) as earliest_year from publication p ) 
GROUP BY a.author_id, a.name
ORDER BY num_publications DESC;

-- 8. Design a join query that is not in the above list.
SELECT c.conf_name as conference_name, p.name as publisher_name
FROM half_conference as c
JOIN half_conference_publisher cp on c.conf_id = cp.conf_id
JOIN half_Publisher p on cp.publisher_id = p.publisher_id;

--------------------------------------------Quarter--------------------------------------------
-- 1. For each type of publication, count the total number of publications of that type between 2014- 2023. 
-- Your query should return a set of (publication-type, count) pairs. 
-- For example, (article, 20000), (inproceedings, 30000), ...
SELECT type, COUNT(pub_id) as count
FROM DBLP.quarter_publication
WHERE year >= 2014 AND year <=2023
GROUP BY type;

-- 2. Find all the conferences that have ever published more than 800 papers in one year. 
-- Note that one conference may be held every year 
-- (e.g., KDD runs many years, and each year the conference has a number of papers).
SELECT pc.conf_id, c.conf_name, c.year, COUNT(pc.pub_id) as count
FROM DBLP.quarter_publication_conferences pc
LEFT JOIN DBLP.quarter_conference c
ON pc.conf_id = c.conf_id
GROUP BY pc.conf_id, c.year
HAVING COUNT(pc.pub_id) >= 800;

-- 3. For each 10 consecutive years starting from 1974, i.e., [1974, 1983], [1984, 1993],…, [2014, 2023], 
-- compute the total number of conference publications in DBLP in that 10 years. 
-- Hint: for this query you may want to compute a temporary table with all distinct years.
WITH DistinctYears AS (
    SELECT DISTINCT year
    FROM quarter_conference
    WHERE year >= 1974 and year < 2024
),
YearRanges AS (
    SELECT FLOOR((year - 1974) / 10) as range_group, MIN(year) as start_year, MAX(year) as end_year
    FROM DistinctYears
    GROUP BY FLOOR((year - 1974) / 10)
)
SELECT 
    CONCAT(yr.start_year, '-', yr.end_year) as year_range, COUNT(pc.pub_id) as total_publications
FROM YearRanges as yr
LEFT JOIN quarter_conference c on c.year between yr.start_year and yr.end_year
LEFT JOIN quarter_publication_conferences pc on pc.conf_id = c.conf_id
GROUP BY yr.start_year, yr.end_year
ORDER BY yr.start_year;

-- 4. Find the most collaborative authors who published in a conference or journal whose name contains “data” 
-- (e.g., ACM SIGKDD International Conference on Knowledge Discovery and Data Mining). 
-- That is, for each author determine its number of collaborators, 
-- and then find the author with the most number of collaborators. 
-- Hint: for this question you may want to compute a temporary table of coauthors.
WITH FilteredPub AS (
    SELECT DISTINCT p.pub_id
    FROM quarter_publication as p
    LEFT JOIN quarter_publication_conferences pc on p.pub_id = pc.pub_id
    LEFT JOIN quarter_conference c on pc.conf_id = c.conf_id
    LEFT JOIN quarter_journal j on p.journal_id = j.journal_id
    WHERE c.conf_name LIKE '%data%' or j.name LIKE '%data%'
),
CoAuthors AS (
    SELECT DISTINCT X.author_id as author_id, Y.author_id as collaborator_id
    FROM quarter_author_publications as X
    JOIN quarter_author_publications as Y 
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
JOIN quarter_authors a on c.author_id = a.author_id
ORDER BY c.num_collaborators DESC
LIMIT 1;

-- 5. Data analytics and data science are very popular topics. 
-- Find the top 10 authors with the largest number of publications that are published in conferences 
-- and journals whose titles contain word “Data” in the last 5 years (2019 - 2023).
SELECT a.name as author_name, COUNT(ap.pub_id) as num_publications
FROM quarter_author_publications ap
JOIN quarter_publication p on ap.pub_id = p.pub_id
LEFT JOIN quarter_publication_conferences pc on p.pub_id = pc.pub_id
LEFT JOIN quarter_conference c on pc.conf_id = c.conf_id
LEFT JOIN quarter_journal j on p.journal_id = j.journal_id
JOIN quarter_authors as a on ap.author_id = a.author_id
WHERE (c.conf_name LIKE '%Data%' or j.name LIKE '%Data%')
    and p.year BETWEEN 2019 and 2023
GROUP BY ap.author_id, a.name
ORDER BY num_publications DESC
LIMIT 10;

-- 6. List the name of the conferences such that it has ever been held in June, 
-- and the corresponding proceedings (in the year where the conference was held in June)
-- contain more than 100 publications.
SELECT 
    c.conf_name as conference_name, p.year as year_held_in_june, COUNT(pc.pub_id) as num_publications
FROM 
    quarter_conference as c
JOIN 
    quarter_publication_conferences as pc on c.conf_id = pc.conf_id
JOIN 
    quarter_publication p on pc.pub_id = p.pub_id
WHERE 
    MONTH(p.mdate) = 6 
GROUP BY 
    c.conf_name, p.year
HAVING 
    COUNT(pc.pub_id) > 100 
ORDER BY 
    c.conf_name, p.year;

-- 7. (a)Find authors who have published at least 1 paper every year in the last 30 years (1994 - 2023), 
-- and whose family name start with ‘H’
SELECT a.name as author_name
FROM quarter_authors as a
JOIN 
    quarter_author_publications as ap on a.author_id = ap.author_id
JOIN 
    quarter_publication p on ap.pub_id = p.pub_id
WHERE a.name LIKE 'H%' and p.year between 1994 and 2023
GROUP BY a.author_id, a.name
HAVING COUNT(DISTINCT p.year) = 30;

-- 7. (b)Find the names and number of publications for authors who have the earliest publication record in DBLP.
SELECT a.name as author_name, COUNT(ap.pub_id) as num_publications, MIN(p.year) as first_publication_year
FROM quarter_authors as a
JOIN 
    quarter_author_publications ap on a.author_id = ap.author_id
JOIN 
    quarter_publication p on ap.pub_id = p.pub_id
WHERE 
    p.year = ( SELECT MIN(p.year) as earliest_year from publication p ) 
GROUP BY a.author_id, a.name
ORDER BY num_publications DESC;

-- 8. Design a join query that is not in the above list.
SELECT c.conf_name as conference_name, p.name as publisher_name
FROM quarter_conference as c
JOIN quarter_conference_publisher cp on c.conf_id = cp.conf_id
JOIN quarter_Publisher p on cp.publisher_id = p.publisher_id;

--------------------------------------------Indexing--------------------------------------------