import os
import sys, traceback, time

from datetime import datetime, date

from decimal import Decimal

from sqlalchemy import create_engine, MetaData, text, func
from sqlalchemy.orm import sessionmaker
from neo4j import GraphDatabase

# Configuración de la conexión a PostgreSQL
postgres_username = 'alumnodb'
postgres_password = 'alumnodb'
postgres_host = 'localhost'
postgres_port = '5432'
postgres_database = 'si1'

# Configuración de la conexión a Neo4jDB
neo4jdb_username = 'neo4j'
neo4jdb_password = 'si1-password'
neo4jdb_host = 'localhost'
neo4jdb_port = '7687'
neo4jdb_database = 'si1'

def main():
    # engine is an instance of AsyncEngine
    engine = create_engine(
        f"postgresql://{postgres_username}:{postgres_password}@{postgres_host}:{postgres_port}/{postgres_database}",
        echo=True,
    )

    postgresql_conection = engine.connect()
    neo4j_conection = GraphDatabase.driver(
        f"bolt://{neo4jdb_host}:{neo4jdb_port}",
        auth=(neo4jdb_username, neo4jdb_password),
    )

    select_movies = "SELECT p.movieid, m.movietitle, SUM(od.price*od.quantity) AS total FROM orderdetail AS od JOIN products AS p ON od.prod_id=p.prod_id JOIN imdb_movies AS m ON m.movieid=p.movieid WHERE p.movieid in (SELECT m.movieid FROM imdb_movies AS m JOIN imdb_moviecountries AS mc ON m.movieid = mc.movieid WHERE mc.country = 'USA') GROUP BY p.movieid, m.movietitle ORDER BY total DESC LIMIT 20;"
    
    #Comprobar query
    result_movieid = postgresql_conection.execute(text(select_movies))
    resultados = result_movieid.fetchall()

    # Imprime todos los resultados
    for movieid, title, _ in resultados:
        with neo4j_conection.session() as session:
            node_data = {
                "id": movieid,
                "title": title,
            }
            # Crear el nodo en la base de datos
            result = session.execute_write(lambda tx: tx.run(
                "CREATE (node:Movie {id: $id, title: $title}) RETURN node",
                **node_data
            ))
        
        select_directors = f"SELECT d.directorid, d.directorname FROM imdb_directors AS d JOIN imdb_directormovies AS dm ON d.directorid = dm.directorid WHERE dm.movieid = {movieid};"
        result_directors = postgresql_conection.execute(text(select_directors))
        directors = result_directors.fetchall()
        for directorid, directorname in directors:
            with neo4j_conection.session() as session:
                node_data = {
                    "directorid": directorid,
                    "name": directorname,
                }
                # Crear el nodo en la base de datos
                result = session.execute_write(lambda tx: tx.run(
                    "CREATE (node:Director {directorid: $directorid, name: $name}) RETURN node",
                    **node_data
                ))

            with neo4j_conection.session() as session:
                # Crear la relación entre el nodo de la película y el nodo del director
                result = session.execute_write(lambda tx: tx.run(
                    "MATCH (m:Movie {id: $movieid}), (d:Director {id: $directorid}) CREATE (m)-[r:DIRECTED]->(d) RETURN r",
                    movieid=movieid,
                    directorid=directorid
                ))

                

        select_actors = f"SELECT a.actorid, a.actorname FROM imdb_actors AS a JOIN imdb_actormovies AS am ON a.actorid = am.actorid WHERE am.movieid = {movieid};"
        result_actors = postgresql_conection.execute(text(select_actors))
        actors = result_actors.fetchall()

        for actorid, actorname in actors:
            with neo4j_conection.session() as session:
                node_data = {
                    "actorid": actorid,
                    "name": actorname,
                }
                # Crear el nodo en la base de datos
                result = session.execute_write(lambda tx: tx.run(
                    "CREATE (node:Actor {actorid: $actorid, name: $name}) RETURN node",
                    **node_data
                ))

            with neo4j_conection.session() as session:
                # Crear la relación entre el nodo de la película y el nodo del actor
                result = session.execute_write(lambda tx: tx.run(
                    "MATCH (m:Movie {id: $movieid}), (a:Actor {id: $actorid}) CREATE (m)-[r:ACTED_IN]->(a) RETURN r",
                    movieid=movieid,
                    actorid=actorid
                ))

                             

    neo4j_conection.close()
    postgresql_conection.close()
    engine.dispose()


if __name__ == "__main__":
    main()

