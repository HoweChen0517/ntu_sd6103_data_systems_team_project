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