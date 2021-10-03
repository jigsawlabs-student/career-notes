# Import necessary libraries
import pandas as pd
import numpy as np
from bs4 import BeautifulSoup as bs
import requests
import matplotlib.pyplot as plt

header = {
  "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.75 Safari/537.36",
  "X-Requested-With": "XMLHttpRequest"
}

# read search terms from csv into a list
technologies = ['2 years', '1 year', '3 years', '5 years', '7 years', 'AWS', 'Airflow', 'Alteryx', 'Azure', 'Bayes', 'BigQuery', ' C ', 'C#', 'C++', 'Caffe', 'Calculus', 'Cassandra', 'D3', 'Communication', 'Databricks', 'Django', 'Data Lake', 'Data Pipeline', 'Deep Learning', 'Docker', 'Excel', 'ETL', 'EMR', 'Fastai', 'Flask', 'GCP', 'Git', 'Google Cloud', 'Hadoop', 'Hbase', 
 'Hive','Java', 'Javascript','Kafka', 'Keras', 'Kubernetes', 'KPI',  'Linux', 'Matlab', 'MongoDB','Masters', 'MySQL', 'Linear Algebra', 'Metric', 'Natural Language Processing', 'Neural Networks', 'NLP', 'NoSQL','NumPy', 'OOP', 'Object Oriented', 'Probability', 'Pandas', 'Perl', 'Phd',  'Pig', 'Project Management', 'PyTorch', 'Pyspark', 'Python', 'Random Forests', ' R ', 'Regression', 'Redshift', 'SAS', 'Sklearn', 'SPSS', 'SQL', 'Scala', 'Scikit', 'Shell', 'Spark', 'Spacy', 'Stakeholder', 'Statistics', 'Tableau', 'Testing', 'test driven', 'TDD',
 'TensorFlow', 'postgresql', 'Visualization', 'XGboost', 'Catboost', 'Kaggle']

def get_job_cards(index, position = 'data engineer', location = 'United States', start = 0):
    url = 'https://www.indeed.com/jobs'
    params = {'q': position, 'l': location, 'explvl':'entry_level', 'start': index}
    response = requests.get(url, params = params, headers=header, timeout=10)
    soup = bs(response.text, 'html.parser')
    cards = soup.find_all('div', {"class": "jobsearch-SerpJobCard"})
    return cards

def get_title_and_desc(card):
    id_string = card['data-jk']
    title = card.find('a', {'class': 'jobtitle'}).text[1:]
    desc_string = f"https://www.indeed.com/rpc/jobdescs?jks={id_string}"
    desc_response = requests.get(desc_string, headers=header)
    description_response = desc_response.json()
    desc = description_response[id_string]
    return id_string, title, desc

def title_and_description_from(cards):
    return pd.DataFrame(data = [get_title_and_desc(card) for card in cards], 
                        columns = ['id_string', 'title', 'desc'])

def tech_tags(idx, requirements_df):
    requirement_row = requirements_df.iloc[idx]
    return [(idx, requirement_row['listing_id'], technology) for technology in technologies 
             if technology.lower() in requirement_row['detail'].lower()]

def extract_requirements_from(idx, card_row):
    requirements = []
    row_id_string = card_row['id_string']
    uls = bs(card_row['desc'], 'html.parser').find_all('ul')
    for ul in uls:
        if ul.find_previous():
            label_text = ul.find_previous().text
        else:
            label_text = 'no label'
        requirements += [(idx, label_text[:30], li.text) for li in ul.find_all('li')]
    return pd.DataFrame(requirements, columns = ['listing_id', 'tag', 'detail'])