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

--DROP FUNCTION updInventoryAndCustomerFunction;
--DROP TRIGGER updInventoryAndCustomer ON orders;