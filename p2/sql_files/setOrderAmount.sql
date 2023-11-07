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
    ),
    totalamount = (
        SELECT SUM(od.price) * 1.1
        FROM orderdetail AS od
        WHERE od.orderid = o.orderid
    )
    WHERE netamount IS NULL;

END;
$$ LANGUAGE plpgsql;


-- Llamar al procedimiento almacenado para realizar la carga inicial en la tabla 'orders'
SELECT setOrderAmount();
