-- Actualizar la columna 'price' en la tabla 'orderdetail' con el precio actual de 'products' considerando un incremento del 2% anual
UPDATE orderdetail AS od
SET price = p.price * POWER(1.02, EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM o.orderdate))
FROM products AS p, orders AS o
WHERE od.prod_id = p.prod_id AND od.orderid = o.orderid;

