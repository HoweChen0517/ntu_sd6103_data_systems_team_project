SELECT c.conf_name as conference_name, p.name as publisher_name
FROM conference as c
JOIN conference_publisher cp on c.conf_id = cp.conf_id
JOIN Publisher p on cp.publisher_id = p.publisher_id;
