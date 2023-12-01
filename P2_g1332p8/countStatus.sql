select customerid
from customers
where customerid not in (
 select customerid
 from orders
 where status='Paid'
);

select customerid
from (
 select customerid
 from customers
 union all
 select customerid
 from orders
 where status='Paid'
) as A
group by customerid
having count(*) =1;

select customerid
from customers
except
 select customerid
 from orders
 where status='Paid';

----------------------------------------------

select count(*)
from orders
where status is null;

select count(*)
from orders
where status ='Shipped';

-- status index
create index idx_orders_status on orders(status);

-- analyze
analyze orders;

select count(*)
from orders
where status ='Paid';

select count(*)
from orders
where status ='Processed';