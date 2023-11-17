from sqlalchemy import create_engine, text, func


def main():
    # engine is an instance of AsyncEngine
    engine = create_engine(
        "postgresql://alumnodb:password@localhost:5432/si1",
        echo=True,
    )

    conection = engine.connect()

    function = func.getTopSales(2022,2023)
    
    result = conection.execute(text(f"SELECT {function} AS resultado;"))

    # Recupera el resultado
    resultado_final = result.scalar()

    # Imprime el resultado (o haz lo que necesites con él)
    print(resultado_final)

    conection.close()
    engine.dispose()


if __name__ == "__main__":
    main()
