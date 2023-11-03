-- Agregar una restricción UNIQUE a la columna 'username' en la tabla 'customers'
ALTER TABLE customers
ADD CONSTRAINT uk_username UNIQUE (username);

-- Agregar una clave foránea a la tabla 'orders' que referencia la tabla 'customers'
ALTER TABLE orders
ADD CONSTRAINT fk_customer FOREIGN KEY (customerid) REFERENCES customers(customerid);

-- Configurar la clave foránea para actualizar en cascada
ALTER TABLE orders
ADD CONSTRAINT fk_customer FOREIGN KEY (customerid) REFERENCES customers(customerid) ON DELETE CASCADE;


-- Agregar un campo 'balance' en la tabla 'customers'
ALTER TABLE customers
ADD balance NUMERIC(10, 2); -- Ajusta el tipo y la precisión según tus necesidades


-- Crear una nueva tabla 'ratings' para guardar las valoraciones
CREATE TABLE ratings (
  rating_id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES customers(customerid),
  movie_id INTEGER REFERENCES imdb_movies(movie_id),
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  UNIQUE (user_id, movie_id) -- Evita que un usuario valore la misma película dos veces
);

