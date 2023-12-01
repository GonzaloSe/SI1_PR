import os
import sys, traceback, time

from datetime import datetime, date

from decimal import Decimal

from sqlalchemy import create_engine, MetaData
from sqlalchemy.orm import sessionmaker
from pymongo import MongoClient

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

    # Conexión a MongoDB
    mongodb_client = MongoClient(mongodb_host, mongodb_port)
    mongodb_db = mongodb_client[mongodb_database]
    mongodb_col = mongodb_db[mongodb_collection]

    # Obtener metadatos de las tablas en PostgreSQL
    metadata = MetaData()
    metadata.reflect(bind=postgres_engine)

    # Iterar sobre las tablas y copiar datos a MongoDB
    for table_name, table in metadata.tables.items():
        # Obtener todos los registros de la tabla
        print(f'Copiando datos de la tabla {table_name}...')
        records = session.query(table).all()

        # Insertar registros en la colección de MongoDB
        for record in records:
            print(f'Insertando registro {record}...')
            document = record._asdict()

            # Convertir datetime.date a datetime.datetime
            for key, value in document.items():
               if isinstance(value, date):
                     document[key] = datetime(value.year, value.month, value.day)
               if isinstance(value, Decimal):
                     document[key] = float(value)
               

            mongodb_col.insert_one(document)

    # Cerrar conexiones
    session.close()
    mongodb_client.close()

if __name__ == "__main__":
   mongodb_client = MongoClient(mongodb_host, mongodb_port)
   mongodb_db = mongodb_client[mongodb_database]
   mongodb_col = mongodb_db[mongodb_collection]
   mongodb_col.drop()
   mongodb_client.close()
   create_mongodb_from_postgres()







# CHATGPTEADA PADRE
import psycopg2
from pymongo import MongoClient

# Conexión a la Base de Datos PostgreSQL
postgres_conn = psycopg2.connect(
    dbname="nombre_de_tu_base_de_datos",
    user="tu_usuario",
    password="tu_contraseña",
    host="tu_host",
    port="tu_puerto"
)

postgres_cursor = postgres_conn.cursor()

# Conexión a la Base de Datos MongoDB
mongo_client = MongoClient("mongodb://localhost:27017")  # Actualiza con la URL de tu base de datos
mongo_db = mongo_client["nombre_de_tu_base_de_datos_mongo"]  # Nombre de tu base de datos en MongoDB
mongo_collection = mongo_db["peliculas_francesas"]  # Nombre de la colección en MongoDB

# Consulta para obtener películas francesas de la Base de Datos PostgreSQL
postgres_cursor.execute("""
    SELECT
        title,
        genres,
        year,
        directors,
        actors
    FROM
        movies
    WHERE
        country = 'France' OR collaboration = 'France'
""")

movies = postgres_cursor.fetchall()

# Crear documentos y añadir a la colección en MongoDB
for movie in movies:
    document = {
        "title": movie[0].rsplit(' ', 1)[0],  # Eliminar el año del título
        "genres": movie[1],
        "year": movie[2],
        "directors": movie[3],
        "actors": movie[4],
        "most_related_movies": [],
        "related_movies": []
    }

    # Agregar documentos a la colección en MongoDB
    mongo_collection.insert_one(document)

# Cerrar conexiones
postgres_cursor.close()
postgres_conn.close()
mongo_client.close()
