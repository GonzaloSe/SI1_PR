from sqlalchemy import create_engine


def main():
    # engine is an instance of AsyncEngine
    engine = create_engine(
        "postgresql://alumnodb:password@:::5432/si1",
        echo=True,
    )

    conection = engine.connect()
    
    result = conection.execute("SELECT * FROM orders LIMIT 10")

    for row in result:
        print(row)

    conection.close()
    engine.dispose()


if __name__ == "__main__":
    main()
