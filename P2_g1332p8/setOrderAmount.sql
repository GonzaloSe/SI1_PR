-- Crear el procedimiento almacenado setOrderAmount
CREATE OR REPLACE FUNCTION setOrderAmount()
RETURNS VOID AS $$
BEGIN
    -- Actualizar las columnas netamount y totalamount en la tabla orders cuando estén en blanco
    UPDATE orders AS o
    SET netamount = (
        SELECT SUM(od.price)
        FROM orderdetail AS od
        WHERE od.orderid = o.orderid
    )
	WHERE netamount IS NULL;
	
	UPDATE orders as o
    SET totalamount = (
        o.netamount *(1 + (o.tax / 100))
    )
	WHERE totalamount IS NULL;

END;
$$ LANGUAGE plpgsql;


-- Llamar al procedimiento almacenado para realizar la carga inicial en la tabla 'orders'
SELECT setOrderAmount();

--DROP FUNCTION setOrderAmount;