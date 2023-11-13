-- Agregar una clave foránea a la tabla 'orders' que referencia la tabla 'customers' y configurarla para actualizar en cascada
ALTER TABLE orders
ADD CONSTRAINT fk_customer FOREIGN KEY (customerid) REFERENCES customers(customerid) ON DELETE CASCADE;

-- Agregar una restricción UNIQUE a la columna 'username' en la tabla 'customers'
-- Agregar un campo 'balance' en la tabla 'customers'
-- Aumentar el tamaño del campo 'password' en la tabla 'customers'
ALTER TABLE customers
ADD balance NUMERIC(10, 2), 
ALTER COLUMN password TYPE VARCHAR(96); 

-- Crear una nueva tabla 'ratings' para guardar las valoraciones
CREATE TABLE ratings (
  rating_id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES customers(customerid),
  movie_id INTEGER REFERENCES imdb_movies(movieid),
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  UNIQUE (user_id, movie_id) -- Evita que un usuario valore la misma película dos veces
);


-- Agregar dos campos a la tabla 'imdb_movies' para contener la valoración media y el número de valoraciones
ALTER TABLE imdb_movies
ADD ratingmean NUMERIC(3, 2), -- Ajusta el tipo y la precisión según tus necesidades
ADD ratingcount INTEGER;



-------------------------------------------------TRIGGERS--------------------------------------------------------------------
-- Crear un trigger para actualizar el saldo del cliente cuando se inserta una nueva orden
CREATE OR REPLACE FUNCTION update_balance_on_order_insert()
RETURNS TRIGGER AS $$
BEGIN
  -- Lógica para actualizar el saldo, por ejemplo, deducir el costo de la orden
  UPDATE customers
  SET balance = balance - NEW.totalamount
  WHERE customerid = NEW.customerid;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_balance_trigger
AFTER INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION update_balance_on_order_insert();

-- Crear un trigger para calcular y actualizar la valoración media de una película cuando se inserta una nueva valoración
CREATE OR REPLACE FUNCTION update_ratingmean_on_rating_insert()
RETURNS TRIGGER AS $$
BEGIN
  -- Lógica para calcular la valoración media, por ejemplo, promediar las valoraciones de una película
  UPDATE imdb_movies
  SET ratingmean = (SELECT AVG(rating) FROM ratings WHERE movie_id = NEW.movie_id)
  WHERE movie_id = NEW.movie_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_ratingmean_trigger
AFTER INSERT ON ratings
FOR EACH ROW
EXECUTE FUNCTION update_ratingmean_on_rating_insert();



-------------------------------------------------PROCEDIMIENTOS--------------------------------------------------------------------
-- Crear un procedimiento para inicializar el campo 'balance' de 'customers' con un valor aleatorio
CREATE OR REPLACE FUNCTION setCustomersBalance(IN initialBalance bigint)
RETURNS VOID AS $$
DECLARE
    randomBalance bigint;
BEGIN
    -- Generar un número aleatorio entre 0 y N (en este caso, N = 200)
    randomBalance := floor(random() * (initialBalance + 1));
    
    -- Actualizar el campo 'balance' para todos los registros en la tabla 'customers' con el valor aleatorio
    UPDATE customers
    SET balance = randomBalance;
END;
$$ LANGUAGE plpgsql;



-- Llamar al procedimiento para inicializar el campo 'balance' de 'customers' con un número aleatorio entre 0 y 200
--SELECT setCustomersBalance(200);



-- Agregar clave foránea a imdb_moviecountries
ALTER TABLE imdb_moviecountries
    ADD FOREIGN KEY (movieid) REFERENCES imdb_movies(movieid) ON DELETE CASCADE;

-- Agregar clave foránea a imdb_moviegenres
ALTER TABLE imdb_moviegenres
    ADD FOREIGN KEY (movieid) REFERENCES imdb_movies(movieid) ON DELETE CASCADE;

-- Agregar clave foránea a imdb_movielanguages
ALTER TABLE imdb_movielanguages
    ADD FOREIGN KEY (movieid) REFERENCES imdb_movies(movieid) ON DELETE CASCADE;

