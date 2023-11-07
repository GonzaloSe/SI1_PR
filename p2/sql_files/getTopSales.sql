-- Crear la función getTopSales con la firma requerida
CREATE OR REPLACE FUNCTION getTopSales(year1 INT, year2 INT, OUT Year INT, OUT Film CHAR, OUT sales bigint)
RETURNS SETOF record AS $$
DECLARE
    year_value INT;
    film_value VARCHAR;
    sales_value bigint;
BEGIN
    -- Consulta para obtener las películas más vendidas por año entre los dos años dados
    FOR year_value IN year1..year2 LOOP
        SELECT INTO film_value, sales_value
            m.movietitle, COUNT(od.orderid)
            FROM orders o
            JOIN orderdetail od ON o.orderid = od.orderid
            JOIN imdb_movies m ON od.prod_id  = m.movieid
            WHERE EXTRACT(YEAR FROM o.orderdate) = year_value
            GROUP BY m.movietitle
            ORDER BY COUNT(od.orderid) DESC
            LIMIT 1;
        
        Year := year_value;
        Film := film_value;
        sales := sales_value;
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Llamar a la función getTopSales con los años deseados (por ejemplo, de 2020 a 2022)
SELECT * FROM getTopSales(1800, 2020);

