# -*- coding: utf-8 -*-

import os
import sys, traceback, time

from sqlalchemy import create_engine, text
from pymongo import MongoClient

# configurar el motor de sqlalchemy
db_engine = create_engine("postgresql://alumnodb:alumnodb@localhost/si1", echo=False, execution_options={"autocommit":False})

# Crea la conexión con MongoDB
mongo_client = MongoClient()

def getMongoCollection(mongoDB_client):
    mongo_db = mongoDB_client.si1
    return mongo_db.topUK

def mongoDBCloseConnect(mongoDB_client):
    mongoDB_client.close()

def dbConnect():
    return db_engine.connect()

def dbCloseConnect(db_conn):
    db_conn.close()
  
def delState(state, bFallo, bSQL, duerme, bCommit):
    
    # Array de trazas a mostrar en la página
    dbr=[]

    # TODO: Ejecutar consultas de borrado
    # - ordenar consultas según se desee provocar un error (bFallo True) o no
    # - ejecutar commit intermedio si bCommit es True
    # - usar sentencias SQL ('BEGIN', 'COMMIT', ...) si bSQL es True
    # - suspender la ejecución 'duerme' segundos en el punto adecuado para forzar deadlock
    # - ir guardando trazas mediante dbr.append()
    
    try:
        # TODO: ejecutar consultas
        pass
    except Exception as e:
        # TODO: deshacer en caso de error
        pass
    else:
        # TODO: confirmar cambios si todo va bien
        pass
        
    return dbr

def delCity(city, bFallo, bSQL, duerme, bCommit):
    
    # Array de trazas a mostrar en la página
    dbr=[]
    
    queries_in_order = []
    
    transaction = None
    
    if bFallo:
        dbr.append("Error provocado en la ejecución de las consultas")
        queries_in_order.append(f"DELETE FROM orderdetail od WHERE od.orderid IN (SELECT o.orderid FROM orders o JOIN customers c ON c.customerid = o.customerid WHERE c.city = '{city}');")
        queries_in_order.append(f"DELETE FROM customers WHERE city = '{city}';")
        queries_in_order.append(f"DELETE FROM orders WHERE customerid IN (SELECT customerid FROM customers WHERE city = '{city}');")
        
    else:
        dbr.append("Ejecución de consultas en el orden correcto")
        queries_in_order.append(f"DELETE FROM orderdetail od WHERE od.orderid IN (SELECT o.orderid FROM orders o JOIN customers c ON c.customerid = o.customerid WHERE c.city = '{city}');")
        queries_in_order.append(f"DELETE FROM orders WHERE customerid IN (SELECT customerid FROM customers WHERE city = '{city}');")
        queries_in_order.append(f"DELETE FROM customers WHERE city = '{city}';")
    
    try:
        db_conn = dbConnect()

        if bSQL:
            db_conn.execute(text("BEGIN;"))
        else:
            transaction = db_conn.begin()

        for i, query in enumerate(queries_in_order):
            dbr.append("Ejecutando: " + str(query))         
            if i == 1 and bCommit:
                if bSQL:
                    dbr.append("Ejecutando commit intermedio")
                    db_conn.execute(text("COMMIT;"))
                    db_conn.execute(text("BEGIN;"))
                else:
                    transaction.commit()
                    transaction = db_conn.begin()
                dbr.append("Ejecutando commit")
                dbr.append("Comenzando nueva transacción")
            elif i == 2:
                dbr.append(f"Duerme {str(duerme)} segundos")
                time.sleep(float(duerme))
            db_conn.execute(text(query))
    except Exception as e:
        dbr.append(f"Error: {str(e)}")
        if bSQL:
            db_conn.execute(text("ROLLBACK;"))

        else:
            transaction.rollback()
        dbr.append("Ejecutando rollback")
    else:
        if bSQL:
            db_conn.execute(text("COMMIT;"))
            
        else:
            transaction.commit()
        dbr.append("Ejecutando commit")
    finally:
        dbCloseConnect(db_conn)
        
    return dbr
    