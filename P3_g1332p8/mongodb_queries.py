<<<<<<< HEAD
import pymongo

# Conexión a la base de datos MongoDB
client = pymongo.MongoClient("mongodb://localhost:27017")  # Actualiza con la URL de tu base de datos
db = client["nombre_de_tu_base_de_datos"]  # Actualiza con el nombre de tu base de datos
collection = db["nombre_de_tu_coleccion"]  # Actualiza con el nombre de tu colección

# Consulta A: Películas de ciencia ficción entre 1994 y 1998
query_a = {
    "genre": "Science Fiction",
    "year": {"$gte": 1994, "$lte": 1998}
}

result_a = collection.find(query_a)
print("Consulta A:")
for movie in result_a:
    print(movie)

# Consulta B: Dramas del año 1998 que empiezan con "The"
query_b = {
    "genre": "Drama",
    "year": 1998,
    "title": {"$regex": "^The"}
}

result_b = collection.find(query_b)
print("\nConsulta B:")
for movie in result_b:
    print(movie)

# Consulta C: Películas en las que Faye Dunaway y Viggo Mortensen han compartido reparto
query_c = {
    "$and": [
        {"cast": {"$in": ["Faye Dunaway"]}},
        {"cast": {"$in": ["Viggo Mortensen"]}}
    ]
}

result_c = collection.find(query_c)
print("\nConsulta C:")
for movie in result_c:
    print(movie)
=======
from pymongo import MongoClient

mongodb_host = 'localhost'
mongodb_port = 27017
mongodb_database = 'si1'
mongodb_collection_name = 'france'

def scifi_from_1994_to_1998(mongodb_collection):
    query = {'year': {'$gte': 1994, '$lte': 1998}, 'genres': 'Sci-Fi'}
    print("Sci-Fi from 1994 to 1998 Query:", query)
    movies = mongodb_collection.find(query)
    for movie in movies:
        print(movie)


def dramas_from_1998_the(mongodb_collection):
    query = {'year': 1998, 'genres': 'Drama', 'movietitle': {'$regex': '^The'}}
    movies = mongodb_collection.find(query)
    for movie in movies:
        print(movie)
  

def faye_dunaway_and_vigo_mortensen(mongodb_collection):
    query = {'actors': {'$all': ['Faye Dunaway', 'Viggo Mortensen']}}
    movies = mongodb_collection.find(query)
    for movie in movies:
        print (movie)

if __name__ == '__main__':
    mongodb_client = MongoClient(mongodb_host, mongodb_port)
    mongodb_db = mongodb_client[mongodb_database]
    mongodb_collection = mongodb_db[mongodb_collection_name]
    
    print('Sci-Fi movies from 1994 to 1998:')
    scifi_from_1994_to_1998(mongodb_collection)
    
    print('\nDramas from 1998 starting with "The":')
    dramas_from_1998_the(mongodb_collection)
    
    print('\nMovies with Faye Dunaway and Viggo Mortensen:')
    faye_dunaway_and_vigo_mortensen(mongodb_collection)
    
    mongodb_client.close()
>>>>>>> fffe5faa (mongo hecho)
