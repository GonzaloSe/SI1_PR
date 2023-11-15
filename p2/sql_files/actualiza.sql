-- Agregar una clave foránea a la tabla 'orders' que referencia la tabla 'customers' y configurarla para actualizar en cascada
ALTER TABLE orders
ADD CONSTRAINT fk_customer FOREIGN KEY (customerid) REFERENCES customers(customerid) ON DELETE CASCADE;
CREATE INDEX idx_orders_orderid ON orders(orderid);
CREATE INDEX idx_orderdetail_orderid ON orderdetail(orderid);


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

   
--Función para cambios en el pedido
CREATE OR REPLACE FUNCTION updOrdersFunction()
RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'UPDATE') THEN 
	  UPDATE orders
	  SET netamount = netamount + (NEW.price * (NEW.quantity - OLD.quantitity)), totalamount = netamount * 1.1
	  WHERE orderid = OLD.orderid;
	  RETURN NEW;
  ELSIF (TG_OP = 'INSERT') THEN 
	  UPDATE orders
	  SET netamount = netamount + (NEW.price * NEW.quantity), totalamount = netamount * 1.1
	  WHERE orderid = OLD.orderid;
	  RETURN NEW;
  ELSIF (TG_OP = 'DELETE') THEN 
	  UPDATE orders
	  SET netamount = netamount - (OLD.price * OLD.quantity), totalamount = netamount * 1.1
	  WHERE orderid = OLD.orderid;
	  RETURN OLD;
  END IF;
END;
$$ LANGUAGE plpgsql;
							   
--Trigger para cambios en el pedido							   
CREATE OR REPLACE TRIGGER updOrders
AFTER INSERT OR DELETE OR UPDATE ON orderdetail
FOR EACH ROW
EXECUTE FUNCTION updOrdersFunction();

--DROP FUNCTION updOrdersFunction;
--DROP TRIGGER updOrders ON orderdetail;



--Función para cambios en la valoración
CREATE OR REPLACE FUNCTION updRatingsFunction()
RETURNS TRIGGER AS $$
DECLARE
    mean_value numeric(3,2);
    count_value integer;
BEGIN
    IF (TG_OP = 'UPDATE' OR TG_OP = 'INSERT') THEN
        SELECT COUNT(rating_id) INTO count_value FROM ratings
        WHERE movie_id = NEW.movie_id;
        SELECT AVG(rating) INTO mean_value FROM ratings
        WHERE movie_id = NEW.movie_id;
        
        UPDATE imdb_movies
        SET ratingmean = mean_value, ratingcount = count_value
        WHERE movieid = NEW.movie_id;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN 
        SELECT COUNT(rating_id) INTO count_value FROM ratings
        WHERE movie_id = OLD.movie_id;
        SELECT AVG(rating) INTO mean_value FROM ratings
        WHERE movie_id = OLD.movie_id;
        
        UPDATE imdb_movies
        SET ratingmean = mean_value, ratingcount = count_value
        WHERE movieid = OLD.movie_id;
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;
							   
--Trigger para cambios en la valoración							   
CREATE OR REPLACE TRIGGER updRatings
AFTER INSERT OR DELETE OR UPDATE ON ratings
FOR EACH ROW
EXECUTE FUNCTION updRatingsFunction();




--Función para pagos de pedidos
CREATE OR REPLACE FUNCTION updInventoryAndCustomerFunction()
RETURNS TRIGGER AS $$
DECLARE
    total_price_paid numeric(10, 2);
BEGIN
    -- Verificar si el pedido cambió al estado "Paid"
    IF NEW.status = 'Paid' AND OLD.status <> 'Paid' THEN
        -- Actualizar la tabla inventory 
        UPDATE inventory
        SET stock = stock - (SELECT SUM(quantity) FROM orderdetail WHERE orderid = NEW.orderid)
        WHERE prod_id IN (SELECT prod_id FROM orderdetail WHERE orderid = NEW.orderid);

		
        -- Descuentar el precio total en la tabla customers
        SELECT totalamount INTO total_price_paid FROM orders
        WHERE orderid = NEW.orderid; 
		
        UPDATE customers
        SET balance = balance - total_price_paid
        WHERE customerid = NEW.customerid; 
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para pagos de pedidos
CREATE OR REPLACE TRIGGER updInventoryAndCustomer
AFTER UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION updInventoryAndCustomerFunction();



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



-- Crear un procedimiento para añadir una valoración a una película
CREATE OR REPLACE FUNCTION addRating(IN r_rating integer, IN r_movie_id integer, IN r_user_id integer)
RETURNS VOID AS $$
BEGIN
    INSERT INTO ratings (rating, movie_id, user_id) VALUES (r_rating, r_movie_id, r_user_id);
END;
$$ LANGUAGE plpgsql;

----------------------------------------------------------------------------------------------
--SELECT addRating(3, 103, 4);
--DELETE FROM ratings WHERE movie_id = 103 AND user_id = 4;


--DROP FUNCTION addRating;


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
	
	
--SELECT * FROM orderdetail od 
--WHERE od.orderid = 3

--SELECT orderid, SUM(price) FROM orderdetail od 
--WHERE od.orderid = 3
--GROUP BY orderid

--DELETE FROM orderdetail od
--WHERE od.prod_id=1467 AND od.orderid = 3
--1766

  
  
  
-- Ver el estado antes de la actualización
--SELECT * FROM inventory WHERE prod_id=1;
--SELECT * FROM customers WHERE customerid = 2132;
--UPDATE customers SET balance = 300 WHERE customerid = 2132;

--SELECT *
--FROM orders
--WHERE orderid IN (SELECT orderid FROM orderdetail WHERE prod_id = 1);

--SELECT *
--FROM orders o
--JOIN orderdetail od ON o.orderid = od.orderid
--JOIN inventory i ON od.prod_id = i.prod_id
--WHERE o.customerid = 2132 AND od.prod_id = 1;



-- Actualizar el estado del pedido a 'Paid' para probar el trigger
--UPDATE orders SET status = 'Paid' WHERE orderid = 27872;



