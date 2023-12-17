-- Crear la nueva columna "promo" en la tabla "customers"
ALTER TABLE customers
ADD COLUMN IF NOT EXISTS promo DECIMAL(5, 2);

-- Inicializar el campo a 0 para operar
UPDATE customers
SET promo = 0;


-- Modificar el trigger para agregar un sleep en el momento adecuado
CREATE OR REPLACE FUNCTION trg_UpdatePromo_Discount()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar si la columna "promo" ha cambiado
    IF NEW.promo <> OLD.promo THEN
        -- Realizar una pausa de 5 segundos antes de la actualización
        PERFORM pg_sleep(5);

        -- Actualizar el descuento en los productos de las órdenes
        UPDATE products
        SET price = price * (1 - (NEW.promo / 100))
        FROM orderdetails od
        WHERE products.product_id = od.product_id
          AND od.order_id IN (SELECT order_id FROM orders WHERE customer_id = NEW.customer_id);

        RAISE NOTICE 'Descuento aplicado correctamente en los productos de las órdenes para el cliente %.', NEW.customer_id;

        -- Realizar otra pausa de 5 segundos después de la actualización
        PERFORM pg_sleep(5);
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


-- Crear uno o varios carritos (status a NULL)
UPDATE orders
SET status = NULL
WHERE customerid = 123;
