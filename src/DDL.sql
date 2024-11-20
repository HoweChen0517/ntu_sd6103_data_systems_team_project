-- Active: 1732092631226@@127.0.0.1@3306@dblp
CREATE DATABASE IF NOT EXISTS DBLP 
DEFAULT CHARACTER SET = 'utf8mb4' 
DEFAULT COLLATE = 'utf8mb4_general_ci';

CREATE TABLE IF NOT EXISTS DBLP.publisher (
    publisher_id INT PRIMARY KEY NOT NULL,
    name VARCHAR(200)
);
CREATE TABLE IF NOT EXISTS DBLP.journal (
    journal_id INT PRIMARY KEY NOT NULL,
    name VARCHAR(100)
);
CREATE TABLE IF NOT EXISTS DBLP.conference (
    conf_id INT PRIMARY KEY NOT NULL,
    conf_name VARCHAR(50),
    year INT
);
CREATE TABLE IF NOT EXISTS DBLP.publication (
    pub_id VARCHAR(100) PRIMARY KEY NOT NULL,
    type VARCHAR(15),
    title VARCHAR(1000),
    year INT,
    mdate DATE,
    publisher VARCHAR(200),
    publisher_id INT,
    journal VARCHAR(100),
    journal_id INT,
    volume VARCHAR(50),
    number VARCHAR(50),
    url VARCHAR(500),
    ee VARCHAR(500),
    FOREIGN KEY (publisher_id) REFERENCES DBLP.publisher(publisher_id),
    FOREIGN KEY (journal_id) REFERENCES DBLP.journal(journal_id)
);
CREATE TABLE IF NOT EXISTS DBLP.conference_publisher (
    conf_id INT NOT NULL,
    conf_name VARCHAR(50),
    publisher_id INT NOT NULL,
    publisher VARCHAR(200),
    year INT,
    PRIMARY KEY (conf_id, publisher_id),
    FOREIGN KEY (conf_id) REFERENCES DBLP.conference(conf_id),
    FOREIGN KEY (publisher_id) REFERENCES DBLP.publisher(publisher_id)
);
CREATE TABLE IF NOT EXISTS DBLP.publication_conferences (
    pub_id VARCHAR(100) NOT NULL,
    conf_id INT NOT NULL,
    conf_name VARCHAR(50),
    year INT,
    PRIMARY KEY (pub_id, conf_id),
    FOREIGN KEY (pub_id) REFERENCES DBLP.publication(pub_id),
    FOREIGN KEY (conf_id) REFERENCES DBLP.conference(conf_id)
);
CREATE TABLE IF NOT EXISTS DBLP.publication_journals (
    pub_id VARCHAR(100) NOT NULL,
    journal_id INT NOT NULL,
    journal_name VARCHAR(100),
    year INT,
    PRIMARY KEY (pub_id, journal_id),
    FOREIGN KEY (pub_id) REFERENCES DBLP.publication(pub_id),
    FOREIGN KEY (journal_id) REFERENCES DBLP.journal(journal_id)
);

CREATE TABLE IF NOT EXISTS DBLP.authors(
    author_id CHAR(19) PRIMARY KEY NOT NULL,
    name VARCHAR(100)
);
CREATE TABLE IF NOT EXISTS DBLP.author_publications(
    author_id CHAR(19) NOT NULL,
    pub_id VARCHAR(100) NOT NULL,
    author_name VARCHAR(100),
    PRIMARY KEY (author_id, pub_id),
    FOREIGN KEY (author_id) REFERENCES DBLP.authors(author_id),
    FOREIGN KEY (pub_id) REFERENCES DBLP.publication(pub_id)
);
CREATE TABLE IF NOT EXISTS DBLP.editors(
    editor_id CHAR(19) PRIMARY KEY NOT NULL,
    name VARCHAR(100)
);
CREATE TABLE IF NOT EXISTS DBLP.editor_publications(
    editor_id CHAR(19) NOT NULL,
    pub_id VARCHAR(100) NOT NULL,
    editor_name VARCHAR(100),
    PRIMARY KEY (editor_id, pub_id),
    FOREIGN KEY (editor_id) REFERENCES editors(editor_id),
    FOREIGN KEY (pub_id) REFERENCES DBLP.publication(pub_id)
);
SHOW VARIABLES LIKE 'secure_file_priv';
SHOW VARIABLES LIKE 'local_infile';
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE DBLP.publisher;
TRUNCATE TABLE DBLP.journal;
TRUNCATE TABLE DBLP.conference;
TRUNCATE TABLE DBLP.publication;
TRUNCATE TABLE DBLP.authors;
TRUNCATE TABLE DBLP.author_publications;
SET FOREIGN_KEY_CHECKS = 1;

-- Create publisher table
LOAD DATA LOCAL INFILE '/Users/howechen/Project/ntu_sd6103_team_project/ntu_sd6103_team_project_data/csv_files/publishers.csv'
INTO TABLE DBLP.publisher
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
-- SELECT * 
-- FROM DBLP.publisher
-- LIMIT 10;

-- Create journal table
LOAD DATA LOCAL INFILE '/Users/howechen/Project/ntu_sd6103_team_project/ntu_sd6103_team_project_data/csv_files/journals.csv'
INTO TABLE DBLP.journal
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
-- SELECT * 
-- FROM DBLP.journal
-- LIMIT 10;

-- Create conference table
LOAD DATA LOCAL INFILE '/Users/howechen/Project/ntu_sd6103_team_project/ntu_sd6103_team_project_data/csv_files/conferences.csv'
INTO TABLE DBLP.conference
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
-- SELECT COUNT(*)
-- FROM DBLP.conference;

-- Create publication table
LOAD DATA LOCAL INFILE '/Users/howechen/Project/ntu_sd6103_team_project/ntu_sd6103_team_project_data/csv_files/publications.csv'
INTO TABLE DBLP.publication
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    pub_id, type, title, year, mdate, publisher, publisher_id, journal, journal_id, volume, number, url, ee
)
SET
    publisher_id = NULLIF(publisher_id, 0),
    journal_id = NULLIF(journal_id, 0);
-- SELECT COUNT(*)
-- FROM DBLP.publication;
-- SELECT *
-- FROM DBLP.publication
-- WHERE publisher_id = 1
-- LIMIT 10;

-- Create conference_publisher table
LOAD DATA LOCAL INFILE '/Users/howechen/Project/ntu_sd6103_team_project/ntu_sd6103_team_project_data/csv_files/conference_publisher.csv'
INTO TABLE DBLP.conference_publisher
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
-- SELECT COUNT(*)
-- FROM DBLP.conference_publisher;
-- SELECT *
-- FROM DBLP.conference_publisher
-- LIMIT 10;

-- Create publication_conference table
LOAD DATA LOCAL INFILE '/Users/howechen/Project/ntu_sd6103_team_project/ntu_sd6103_team_project_data/csv_files/publication_conferences.csv'
INTO TABLE DBLP.publication_conferences
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
-- SELECT *
-- FROM DBLP.publication_conferences
-- LIMIT 10;
-- SELECT pc.conf_id, c.conf_name, COUNT(*) count
-- FROM DBLP.publication_conferences pc
-- LEFT JOIN DBLP.conference c
-- ON pc.conf_id = c.conf_id
-- GROUP BY pc.conf_id
-- ORDER BY count DESC
-- LIMIT 10;

-- Create authors table
LOAD DATA LOCAL INFILE '/Users/howechen/Project/ntu_sd6103_team_project/ntu_sd6103_team_project_data/csv_files/authors.csv'
INTO TABLE DBLP.authors
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
-- SELECT *
-- FROM DBLP.authors
-- LIMIT 10;

-- Create author_publications table
LOAD DATA LOCAL INFILE '/Users/howechen/Project/ntu_sd6103_team_project/ntu_sd6103_team_project_data/csv_files/author_publications.csv'
INTO TABLE DBLP.author_publications
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
-- SELECT *
-- FROM DBLP.author_publications
-- LIMIT 10;
-- SELECT ap.author_id,  a.name, COUNT(ap.pub_id) as count
-- FROM DBLP.author_publications ap
-- LEFT JOIN DBLP.authors a
-- ON ap.author_id = a.author_id
-- WHERE LENGTH(a.name) > 5
-- GROUP BY ap.author_id
-- ORDER BY count DESC
-- LIMIT 10;

-- Create editors table
LOAD DATA LOCAL INFILE '/Users/howechen/Project/ntu_sd6103_team_project/ntu_sd6103_team_project_data/csv_files/editors.csv'
INTO TABLE DBLP.editors
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
-- SELECT *
-- FROM DBLP.editors
-- LIMIT 10;

-- Create editor_publications table
LOAD DATA LOCAL INFILE '/Users/howechen/Project/ntu_sd6103_team_project/ntu_sd6103_team_project_data/csv_files/editor_publications.csv'
INTO TABLE DBLP.editor_publications
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
-- SELECT *
-- FROM DBLP.editor_publications
-- LIMIT 10;