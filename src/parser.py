import xml.sax
import csv
import os
import html

class xmlparser(xml.sax.ContentHandler):
    def __init__(self, pub_writer, author_writer, author_pub_writer, 
                 jrnls_writer, conf_writer, editors_writer, editor_pub_writer, publisher_writer, batch_size=None):
        super().__init__()
        self.batch_size = batch_size
        self.current_element = ""
        self.current_data = {}
        self.records = []
        self.authors = []
        self.editors = []
        self.current_author_name = ""
        self.current_author_orcid = ""
        self.current_editor_name = ""
        self.current_editor_orcid = ""
        self.file_count = 0
        self.pub_writer = pub_writer
        self.author_writer = author_writer
        self.author_pub_writer = author_pub_writer
        self.jrnls_writer = jrnls_writer
        self.conf_writer = conf_writer
        self.editors_writer = editors_writer
        self.publisher_writer = publisher_writer
        self.editor_pub_writer = editor_pub_writer
        self.current_pub_data = None

    
    def startElement(self, tag, attrs):
        self.current_element = tag

        # return super().startElement(name, attrs)
        if tag in ['proceedings', 'inproceedings', 'article',
                   'book', 'incollection', 'phdthesis', 'mastersthesis',
                   'www', 'data', 'person']:
            
            
            if self.current_pub_data:
                self.pub_writer.writerow(self.current_pub_data) # write the current publication data to the csv file

            self.current_pub_data = {
                "type": tag, # publication type
                "pub_id": attrs.get("key", ""), # publication id
                "mdate": attrs.get("mdate",""), # publication date
                "title": "", # publication title
                "year": "", # publication year
                "key_source": attrs.get("key", "").split("/")[0] if len(attrs.get("key", "").split("/")) > 0 else "", # publication source
                "key_name": "/".join(attrs.get("key", "").split("/")[1:]) if len(attrs.get("key", "").split("/")) > 0 else "", # publication name
                "volume": "", # publication volume
                "publisher": "", # publication publisher
                "journal": "", # publication journal
                "number": "", # publication number
                "url": "", # dblp link
                "ee": "", # eletronic version link
            }
            self.authors = []
            self.editors = []
        
        if tag == "author":
            self.current_author_orcid = attrs.get("orcid", "")
            self.current_author_name = ""
            self.current_author_data = {
                "author_id": self.current_author_orcid,
                "name": self.current_author_name,
                }
        
        if tag == "editor":
            self.current_editor_orcid = attrs.get("orcid", "")
            self.current_editor_name = ""
            self.current_editor_data = {
                "editor_id": self.current_editor_orcid,
                "name": self.current_editor_name,
                }
        
        if tag == "journal":

            self.current_journal_data = {
                "journal_id": "",
                "name": "",
            }
        
        
        if tag == "publisher":
            self.current_publisher_data = {
                "publisher_id": "",
                "name": "",
            }

            
    def endElement(self, tag):
        if self.current_data is None:
            return
            
        if tag == "author":
            author_name = html.unescape(self.current_author_name)
            self.current_author_data["name"] = author_name

            self.author_writer.writerow(self.current_author_data)

            self.author_pub_writer.writerow({
                "author_id": self.current_author_orcid,
                "author_name": self.current_author_data["name"],
                "pub_id": self.current_pub_data["pub_id"]
            })
        
        if tag == "editor":
            editor_name = html.unescape(self.current_editor_name)
            self.current_editor_data["name"] = editor_name

            self.editors_writer.writerow(self.current_editor_data)

            self.editor_pub_writer.writerow({
                "editor_id": self.current_editor_orcid,
                "editor_name": self.current_editor_data["name"],
                "pub_id": self.current_pub_data["pub_id"]
            })

        if tag == "journal":
            self.current_journal_data["name"] = html.unescape(self.current_data)
            self.jrnls_writer.writerow(self.current_journal_data)
            self.current_pub_data["journal"] = self.current_journal_data["name"]
        
        if tag == "publisher":
            self.current_publisher_data["name"] = html.unescape(self.current_data)
            self.publisher_writer.writerow(self.current_publisher_data)
            self.current_pub_data["publisher"] = self.current_publisher_data["name"]
        
        elif tag in self.current_pub_data:
            self.current_pub_data[tag] = self.content

    def characters(self, content):
        self.content = content.strip()

        if self.current_element == "author":
            self.current_author_name = content.strip()
        elif self.current_element == "editor":
            self.current_editor_name = content.strip()
        elif self.current_element == "journal":
            self.current_data = content.strip()
        elif self.current_element == "publisher":
            self.current_data = content.strip()
        

def main(xml_file, pub_csv, author_csv, author_pub_csv, jrnls_csv, conf_csv, editors_csv, editor_pub_csv, publisher_csv):

    parser = xml.sax.make_parser()
    parser.setFeature(xml.sax.handler.feature_namespaces, 0)

    with open(pub_csv, mode='w', newline="", encoding='utf-8') as pub_f, \
            open(author_csv, mode='w', newline="", encoding='utf-8') as author_f, \
            open(author_pub_csv, mode='w', newline="", encoding='utf-8') as author_pub_f, \
            open(jrnls_csv, mode='w', newline="", encoding='utf-8') as jrnls_f, \
            open(conf_csv, mode='w', newline="", encoding='utf-8') as conf_f, \
            open(editors_csv, mode='w', newline="", encoding='utf-8') as editors_f, \
            open(editor_pub_csv, mode='w', newline="", encoding='utf-8') as editor_pub_f, \
            open(publisher_csv, mode='w', newline="", encoding='utf-8') as publisher_f:
        
        pub_fileds = ['type','pub_id','mdate','title','year','key_source','key_name','volume','publisher','journal','number','url','ee']
        author_fileds = ['author_id', 'name']
        author_pub_fileds = ['author_id', 'author_name', 'pub_id']
        jrnls_fileds = ['journal_id', 'name']
        conf_fileds = ['conf_id', 'name']
        editors_fileds = ['editor_id', 'name']
        editor_pub_fileds = ['editor_id', 'editor_name', 'pub_id']
        publisher_fileds = ['publisher_id', 'name']

        pub_writer = csv.DictWriter(pub_f, fieldnames=pub_fileds)
        author_writer = csv.DictWriter(author_f, fieldnames=author_fileds)
        author_pub_writer = csv.DictWriter(author_pub_f, fieldnames=author_pub_fileds)
        jrnls_writer = csv.DictWriter(jrnls_f, fieldnames=jrnls_fileds)
        conf_writer = csv.DictWriter(conf_f, fieldnames=conf_fileds)
        editors_writer = csv.DictWriter(editors_f, fieldnames=editors_fileds)
        editor_pub_writer = csv.DictWriter(editor_pub_f, fieldnames=editor_pub_fileds)
        publisher_writer = csv.DictWriter(publisher_f, fieldnames=publisher_fileds)

        pub_writer.writeheader()
        author_writer.writeheader()
        author_pub_writer.writeheader()
        jrnls_writer.writeheader()
        conf_writer.writeheader()
        editors_writer.writeheader()
        editor_pub_writer.writeheader()
        publisher_writer.writeheader()
        
        handler = xmlparser(pub_writer, author_writer, author_pub_writer, jrnls_writer, conf_writer, editors_writer, editor_pub_writer, publisher_writer)
        parser.setContentHandler(handler)

        with open(xml_file, 'r', encoding='utf-8') as f:
            parser.parse(f)

if __name__ == "__main__":

    # print('current_working_directory', os.getcwd())
    if os.getcwd().endswith('src'):
        os.chdir('..')
    print('current working directory:', os.getcwd())

    xml_file_path = "../ntu_sd6103_team_project_data/dblp.xml"
    pub_csv_path = "../ntu_sd6103_team_project_data/csv_files/publications.csv"
    author_csv_path = "../ntu_sd6103_team_project_data/csv_files/authors.csv"
    author_pub_csv_path = "../ntu_sd6103_team_project_data/csv_files/author_publications.csv"
    jrnls_csv_path = "../ntu_sd6103_team_project_data/csv_files/journals.csv"
    conf_csv_path = "../ntu_sd6103_team_project_data/csv_files/conferences.csv"
    editors_csv_path = "../ntu_sd6103_team_project_data/csv_files/editors.csv"
    editors_pub_csv_path = "../ntu_sd6103_team_project_data/csv_files/editor_publications.csv"
    publisher_csv_path = "../ntu_sd6103_team_project_data/csv_files/publishers.csv"
    
    main(xml_file=xml_file_path, pub_csv=pub_csv_path,
         author_csv=author_csv_path, author_pub_csv=author_pub_csv_path,
         jrnls_csv=jrnls_csv_path, conf_csv=conf_csv_path,
         editors_csv=editors_csv_path, editor_pub_csv=editors_pub_csv_path,
         publisher_csv=publisher_csv_path)

#%%
# import pandas as pd
# import os

# if os.getcwd().endswith('src'):
#         os.chdir('..')
# print('current working directory:', os.getcwd())
# pub_csv_path = "../ntu_sd6103_team_project_data/csv_files/publications.csv"
# author_csv_path = "../ntu_sd6103_team_project_data/csv_files/authors.csv"
# author_pub_csv_path = "../ntu_sd6103_team_project_data/csv_files/author_publications.csv"
# jrnls_csv_path = "../ntu_sd6103_team_project_data/csv_files/journals.csv"
# conf_csv_path = "../ntu_sd6103_team_project_data/csv_files/conferences.csv"
# editors_csv_path = "../ntu_sd6103_team_project_data/csv_files/editors.csv"
# publisher_csv_path = "../ntu_sd6103_team_project_data/csv_files/publishers.csv"
# pub_df = pd.read_csv(pub_csv_path)
# au_pub_df = pd.read_csv(author_pub_csv_path)
# print(pub_df.head())
# print(pub_df.shape)
# # print(pub_df['author_name'].nunique(), pub_df['pub_id'].nunique())
# print(au_pub_df.head())
# print(au_pub_df.shape)
# print(au_pub_df['author_name'].nunique(), au_pub_df['pub_id'].nunique())