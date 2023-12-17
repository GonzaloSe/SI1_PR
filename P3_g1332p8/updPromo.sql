-- Crear la nueva columna "promo" en la tabla "customers"
ALTER TABLE customers
ADD COLUMN IF NOT EXISTS promo DECIMAL(5, 2);




-- Modificar el trigger trg_UpdatePromo_Discount para incluir una pausa (sleep)
CREATE OR REPLACE FUNCTION trg_UpdatePromo_Discount()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar si la columna "promo" ha cambiado
    IF NEW.promo <> OLD.promo THEN
        -- Agregar una pausa de 5 segundos 
        PERFORM pg_sleep(5);

        UPDATE orderdetail
        SET total_amount = p.price * (1 - (NEW.promo / 100))
        FROM orders o
        JOIN products p ON o.product_id = p.product_id
        WHERE o.customer_id = NEW.customer_id;

        RAISE NOTICE 'Descuento aplicado correctamente en la orden para el cliente %.', NEW.customer_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Vincular el trigger a la tabla "customers"
CREATE TRIGGER trg_UpdatePromo_Discount
AFTER UPDATE
ON customers
FOR EACH ROW
EXECUTE FUNCTION trg_UpdatePromo_Discount();




-- Modificar la lógica de eliminación con una pausa
CREATE OR REPLACE FUNCTION deleteCity(city_id INT)
RETURNS VOID AS $$
BEGIN
    -- Iniciar la transacción
    BEGIN;
    
    -- Realizar la pausa de 5 segundos 
    PERFORM pg_sleep(5);
    
    -- Realizar la eliminación
    DELETE FROM cities WHERE id = city_id;

    -- Hacer un COMMIT o ROLLBACK según sea necesario
    -- COMMIT;

    RAISE NOTICE 'Ciudad eliminada correctamente.';
END;
$$ LANGUAGE plpgsql;





-- Crear nuevas órdenes (carritos) estableciendo el estado (status) a NULL con UPDATE
UPDATE orders
SET status = NULL
WHERE customer_id IN (SELECT customer_id FROM customers WHERE customer_id < 10); -- Es un ejemplo porque no especifica nada



-- CREO QUE ESTE ESTA MAL
-- Acceder a la página que borra una ciudad con un cliente con un pedido en curso
DELETE FROM cities WHERE city_id = 123; -- Reemplaza 123 con el ID de la ciudad a borrar


-- Realizar un update en la columna promo del mismo cliente
UPDATE customers SET promo = 10.0 WHERE customer_id = 123;
---------------------------
