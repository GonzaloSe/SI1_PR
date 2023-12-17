import os
import sys, traceback, time

from datetime import datetime, date

from decimal import Decimal

from sqlalchemy import create_engine, MetaData, select
from sqlalchemy.orm import sessionmaker
from pymongo import MongoClient

from collections import defaultdict
from IPython.display import display, clear_output

# Configuración de la conexión a PostgreSQL
postgres_username = 'alumnodb'
postgres_password = 'alumnodb'
postgres_host = 'localhost'
postgres_port = '5432'
postgres_database = 'si1'

# Configuración de la conexión a MongoDB
mongodb_host = 'localhost'
mongodb_port = 27017
mongodb_database = 'si1'
mongodb_collection = 'france'

def create_mongodb_from_postgres():
    # Conexión a PostgreSQL
    postgres_uri = f'postgresql://{postgres_username}:{postgres_password}@{postgres_host}:{postgres_port}/{postgres_database}'
    postgres_engine = create_engine(postgres_uri)
    Session = sessionmaker(bind=postgres_engine)
    session = Session()

    # Obtener metadatos de las tablas en PostgreSQL
    metadata = MetaData()
    metadata.reflect(bind=postgres_engine)

    # Connect to MongoDB
    mongodb_client = MongoClient(mongodb_host, mongodb_port)
    mongodb_db = mongodb_client[mongodb_database]

    # Define a dictionary to store data instead of separate lists
    data = {
        'movies': [],
        'actors': [],
        'actormovies': [],
        'moviecountries': [],
        'directors': [],
        'directormovies': [],
        'moviegenres': [],
    }

    tables_to_process = ['imdb_actormovies', 'imdb_actors', 'imdb_movies', 'imdb_moviecountries', 'imdb_directors', 'imdb_moviegenres', 'imdb_directormovies']

    # Collect data in a dictionary instead of separate lists
    for table_name, table in metadata.tables.items():
        if table_name not in tables_to_process:
            continue
        print(f'Processing {table_name}...')
        records = session.query(table).all()
        if table_name == 'imdb_actors':
            data['actors'] = [{'actorid': record.actorid, 'actorname': record.actorname} for record in records]
        elif table_name == 'imdb_movies':
            data['movies'] = [{'movieid': record.movieid, 'movietitle': record.movietitle.rsplit('(', 1)[0].strip(), 'year': record.year} for record in records if record.movietitle is not None]
        elif table_name == 'imdb_actormovies':
            data['actormovies'] = [{'actorid': record.actorid, 'movieid': record.movieid} for record in records]
        elif table_name == 'imdb_moviecountries':
            data['moviecountries'] = [{'movieid': record.movieid, 'country': record.country} for record in records]
        elif table_name == 'imdb_directors':
            data['directors'] = [{'directorid': record.directorid, 'directorname': record.directorname} for record in records]
        elif table_name == 'imdb_directormovies':
            data['directormovies'] = [{'directorid': record.directorid, 'movieid': record.movieid} for record in records]
        elif table_name == 'imdb_moviegenres':
            data['moviegenres'] = [{'movieid': record.movieid, 'genre': record.genre} for record in records]
        else:
            print(f'Unknown table {table_name}')
            continue
        print(f'{table_name} processed.')

    # Convert actormovies to a dictionary for faster access
    actormovies_dict = defaultdict(set)
    for am in data['actormovies']:
        actormovies_dict[am['movieid']].add(am['actorid'])

    # Process movies
    mongodb_movies = []

    for movie in data['movies']:
        clear_output(wait=True)
        display(f'Progress: {data["movies"].index(movie) + 1}/{len(data["movies"])}')
        
        country_records = [item['country'] for item in data['moviecountries'] if item['movieid'] == movie['movieid']]
        if 'France' not in country_records:
            continue

        movie_genres = [item['genre'] for item in data['moviegenres'] if item['movieid'] == movie['movieid']]
        movie_directors = [item['directorname'] for item in data['directors'] if item['directorid'] in [dm['directorid'] for dm in data['directormovies'] if dm['movieid'] == movie['movieid']]]
        movie_actors = [item['actorname'] for item in data['actors'] if item['actorid'] in actormovies_dict.get(movie['movieid'], set())]

        most_related_movies = []
        if len(movie_genres) >= 1:
            for other_movie in data['movies']:
                other_movie_genres = [item['genre'] for item in data['moviegenres'] if item['movieid'] == other_movie['movieid']]
                if set(movie_genres) == set(other_movie_genres) and other_movie['movieid'] != movie['movieid']:
                    most_related_movies.append({'title': other_movie['movietitle'], 'year': other_movie['year']})
                if len(most_related_movies) >= 10:
                    break
            most_related_movies = sorted(most_related_movies, key=lambda x: x['year'], reverse=True)[:10]

        related_movies = []
        if len(movie_genres) > 1:
            for other_movie in data['movies']:
                other_movie_genres = [item['genre'] for item in data['moviegenres'] if item['movieid'] == other_movie['movieid']]
                if len(set(movie_genres).intersection(set(other_movie_genres))) / len(set(movie_genres)) >= 0.5 and other_movie['movieid'] != movie['movieid'] and other_movie not in most_related_movies:
                    related_movies.append({'title': other_movie['movietitle'], 'year': other_movie['year']})
                if len(related_movies) >= 10:
                    break
            related_movies = sorted(related_movies, key=lambda x: x['year'], reverse=True)[:10]

        mongodb_movies.append({
            'title': movie['movietitle'],
            'genres': movie_genres,
            'year': movie['year'],
            'directors': movie_directors,
            'actors': movie_actors,
            'most_related_movies': most_related_movies,
            'related_movies': related_movies
        })
        
    # Insert movies into MongoDB
    mongodb_db[mongodb_collection].insert_many(mongodb_movies)
    
    # Close the session and client
    session.close()
    mongodb_client.close()
    

if __name__ == "__main__":
   create_mongodb_from_postgres()
