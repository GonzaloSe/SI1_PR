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
