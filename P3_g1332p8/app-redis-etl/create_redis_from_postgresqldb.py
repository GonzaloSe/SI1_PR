from sqlalchemy import create_engine, MetaData, select
from sqlalchemy.orm import sessionmaker
import random
import redis
from sqlalchemy import create_engine, MetaData, select, Table
from sqlalchemy.orm import sessionmaker

postgres_username = 'alumnodb'
postgres_password = 'alumnodb'
postgres_host = 'localhost'
postgres_port = '5432'
postgres_database = 'si1'

def increment_by_email(email):
    key = f"customers:{email}"
    r.hincrby(key, 'visits', 1)
    
def get_field_by_email(email):
    key = f"customers:{email}"
    name = r.hget(key, 'name').decode('utf-8')
    phone = r.hget(key, 'phone').decode('utf-8')
    visits = int(r.hget(key, 'visits').decode('utf-8'))
    return name, phone, visits

def get_field_by_email(email):
    key = f"customers:{email}"
    name = r.hget(key, 'name')
    phone = r.hget(key, 'phone')
    visits = r.hget(key, 'visits')
    return name, phone, visits


if __name__ == '__main__':
    # Conexión a PostgreSQL
    postgres_uri = f'postgresql://{postgres_username}:{postgres_password}@{postgres_host}:{postgres_port}/{postgres_database}'
    postgres_engine = create_engine(postgres_uri)
    Session = sessionmaker(bind=postgres_engine)
    session = Session()

    # Obtener metadatos de las tablas en PostgreSQL
    metadata = MetaData()
    metadata.reflect(bind=postgres_engine)
    tables_to_process = ['customers']
    
    r = redis.Redis(host='localhost', port=6379, db=0)

    for table_name, table in metadata.tables.items():
        if table_name not in tables_to_process:
            continue
        results = session.query(table).where(table.c.country == 'Spain').all()

    # For each customer, create a hash in Redis
    for result in results:
        key = f"customers:{result.email}"
        name = f"{result.firstname} {result.lastname}"
        phone = result.phone
        visits = random.randint(1, 99)
        r.hset(key, 'name', name)
        r.hset(key, 'phone', phone)
        r.hset(key, 'visits', visits)