# Query Requirements

1. For each type of publication, count the total number of publications of that type between 2014- 2023. Your query should return a set of (publication-type, count) pairs. For example, (article, 20000), (inproceedings, 30000), ...
2. Find all the conferences that have ever published more than 800 papers in one year. Note that one conference may be held every year (e.g., KDD runs many years, and each year the conference has a number of papers).
3. For each 10 consecutive years starting from 1974, i.e., [1974, 1983], [1984, 1993],…, [2014, 2023], compute the total number of conference publications in DBLP in that 10 years. Hint: for this query you may want to compute a temporary table with all distinct years.
4. Find the most collaborative authors who published in a conference or journal whose name contains “data” (e.g., ACM SIGKDD International Conference on Knowledge Discovery and Data Mining). That is, for each author determine its number of collaborators, and then find the author with the most number of collaborators. Hint: for this question you may want to compute a temporary table of coauthors.
5. Data analytics and data science are very popular topics. Find the top 10 authors with the largest number of publications that are published in conferences and journals whose titles contain word “Data” in the last 5 years (2019 - 2023).
6. List the name of the conferences such that it has ever been held in June, and the corresponding proceedings (in the year where the conference was held in June) contain more than 100 publications.
7. (a) Find authors who have published at least 1 paper every year in the last 30 years (1994 - 2023), and whose family name start with ‘H’. (b) Find the names and number of publications for authors who have the earliest publication record in DBLP.
8. Design a join query that is not in the above list.

# Design plan

1. **Publications** table

    - Description: Stores basic information of all types of publications (articles, books, conference papers, etc.).
    - Fields:
        - pub_id (primary key): unique identifier of publication.
        - title: title of publication.
        - year: year of publication.
        - type: publication type (such as "article", "inproceedings", "book").
        - journal_id (foreign key, references Journals table): journal or conference ID (reference Journals or Conferences table based on type).
        - pages: page range.
        - volume: volume number (applicable to journals).
        - number: issue number (applicable to journals).
        - url: DBLP link.
        - ee: electronic version link (such as DOI link).
        - publisher_id (foreign key, references Publishers table): publisher ID.

2. **Authors** table

    - Description: Stores author information.
    - Fields:
        - author_id (primary key): unique identifier of author.
        - name: author name.

3. **Authors_Publications** table (many-to-many relationship)

    - Description: Establishes a many-to-many relationship between authors and publications.

    - Fields:
        - author_id (foreign key, references Authors table): author ID.
        - pub_id (foreign key, references Publications table): publication ID.

4. **Journals** table

    - Description: Stores journal information.
    - Fields:
        - journal_id (primary key): journal unique identifier.
        - name: journal name.

5. **Conferences** table

    - Description: Stores conference information.
    - Fields:
        - conference_id (primary key): conference unique identifier.
        - name: conference name.
        - location: conference location.
        - year: conference year.

6. **Editors** table

    - Description: Stores editor information for conferences or books.
    - Fields:
        - editor_id (primary key): editor unique identifier.
        - name: editor name.

7. **Publishers** table

    - Description: Stores publisher information.
    - Fields:
        - publisher_id (primary key): publisher unique identifier.
        - name: publisher name.

8. **Citations** table (if applicable)

    - Description: Establish citation relationship.
    - Fields:
        - citing_pub_id (foreign key, citing Publications table): publication ID that cites other publications.
        - cited_pub_id (foreign key, citing Publications table): cited publication ID.

Relationship diagram

    - Publications and Authors are many-to-many relationships, connected by the Authors_Publications table.
    - Publications and Journals, Conferences are one-to-many relationships.
    - Publications and Publishers are many-to-one relationships.
    - Publications can form self-citation relationships (cite other publications) through the Citations table.

Note: We can query and analyze data in many ways, such as by author, year, journal or conference, and also supports citation queries.