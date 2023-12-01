
-- Section a)
SELECT COUNT(DISTINCT customers.state) AS num_states
FROM orders
JOIN customers ON orders.customerid = customers.customerid
WHERE EXTRACT(YEAR FROM orders.orderDate) = 2017
AND customers.country = 'Peru';

-- Section b), d)
EXPLAIN SELECT COUNT(DISTINCT customers.state) AS num_states
FROM orders
JOIN customers ON orders.customerid = customers.customerid
WHERE EXTRACT(YEAR FROM orders.orderDate) = 2017
AND customers.country = 'Peru';

-- Section c)
DROP INDEX IF EXISTS idx_orders_customerid_orderDate;
CREATE INDEX idx_orders_customerid_orderDate ON orders (customerid, orderDate);

/* DROP INDEX IF EXISTS idx_customers_customerid_country;
CREATE INDEX idx_customers_customerid_country ON customers(customerid, country); */

/* DROP INDEX IF EXISTS idx_customers_country;
CREATE INDEX idx_customers_country ON customers (country); */

/*
-- Section e) 
DROP INDEX IF EXISTS idx_orders_customerid_orderDate;
DROP INDEX IF EXISTS idx_customers_customerid_country;
DROP INDEX IF EXISTS idx_orders_customerid;
DROP INDEX IF EXISTS idx_customers_customerid;
DROP INDEX IF EXISTS idx_orders_orderDate;
DROP INDEX IF EXISTS idx_customers_country;


-- composite index (customerid, country)
DROP INDEX IF EXISTS idx_customers_customerid_country;
CREATE INDEX idx_customers_customerid_country ON customers(customerid, country);

-- customerid (orders)
DROP INDEX IF EXISTS idx_orders_customerid;
CREATE INDEX idx_orders_customerid ON orders (customerid);

-- customerid (customers)
DROP INDEX IF EXISTS idx_customers_customerid;
CREATE INDEX idx_customers_customerid ON customers (customerid);

-- date
DROP INDEX IF EXISTS idx_orders_orderDate;
CREATE INDEX idx_orders_orderDate ON orders (orderDate);

-- country
DROP INDEX IF EXISTS idx_customers_country;
CREATE INDEX idx_customers_country ON customers (country);

-- state
DROP INDEX IF EXISTS idx_customers_state;
CREATE INDEX idx_customers_state ON customers (state);
*/