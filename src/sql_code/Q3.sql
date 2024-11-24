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
