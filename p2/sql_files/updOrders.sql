--Función para cambios en el pedido
CREATE OR REPLACE FUNCTION updOrdersFunction()
RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'UPDATE') THEN 
	  UPDATE orders
	  SET netamount = netamount + (NEW.price * (NEW.quantity - OLD.quantity)), totalamount = netamount *(1 + (tax / 100))
	  WHERE orderid = OLD.orderid;
	  RETURN NEW;
  ELSIF (TG_OP = 'INSERT') THEN 
	  UPDATE orders
	  SET netamount = netamount + (NEW.price * NEW.quantity), totalamount = netamount *(1 + (tax / 100))
	  WHERE orderid = OLD.orderid;
	  RETURN NEW;
  ELSIF (TG_OP = 'DELETE') THEN 
	  UPDATE orders
	  SET netamount = netamount - (OLD.price * OLD.quantity), totalamount = netamount *(1 + (tax / 100))
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