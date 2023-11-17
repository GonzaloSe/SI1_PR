from sqlalchemy import create_engine, text, func


def main():
    # engine is an instance of AsyncEngine
    engine = create_engine(
        "postgresql://alumnodb:password@localhost:5432/si1",
        echo=True,
    )

    conection = engine.connect()

    result = conection.execute(text("SELECT getTopSales(2018, 2021) AS resultado;"))
    resultados = result.fetchall()

    # Imprime todos los resultados
    for resultado in resultados:
        print(resultado)

    conection.close()
    engine.dispose()


if __name__ == "__main__":
    main()
