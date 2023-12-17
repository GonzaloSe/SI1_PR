from pymongo import MongoClient

mongodb_host = 'localhost'
mongodb_port = 27017
mongodb_database = 'si1'
mongodb_collection_name = 'france'

def scifi_from_1994_to_1998(mongodb_collection):
    query = {'$and': [{'year': {'$gte': '1994', '$lte': '1998'}}, {'genres': {'$all': ['Sci-Fi']}}]}
    movies = mongodb_collection.find(query)
    for movie in movies:
        print(movie)


def dramas_from_1998_the(mongodb_collection):
    query = {'$and': [{'year': '1998'}, {'genres': 'Drama'}, {'title': {'$regex': 'The$'}}]}
    movies = mongodb_collection.find(query)
    for movie in movies:
        print(movie)
  
def faye_dunaway_and_viggo_mortensen(mongodb_collection):
    query = {'$and': [{'actors': {'$regex': 'Dunaway, Faye'}}, {'actors': {'$regex': 'Mortensen, Viggo'}}]}
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
    faye_dunaway_and_viggo_mortensen(mongodb_collection)
    
    mongodb_client.close()
