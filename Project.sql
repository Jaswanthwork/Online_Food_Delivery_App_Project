use restaurants;
SELECT table_name
FROM information_schema.tables
WHERE table_schema = DATABASE();

select* from restaurants; 
select* from customers;
select* from orders;
select* from order_items;
select* from delivery_agents;

-- Phase 1: Exploratory Analysis
-- 1.Total Revenue Calculation
select sum(order_amount - discount) as total_revenue 
from orders;

-- 2.Total Orders per city
select city, count(*) as total_orders
from restaurants
group by city;

-- 3.Top 10 Customers by Total Spending
select c.customer_id, c.name, sum(o.order_amount - o.discount) as total_spent
from customers c
join orders o on c.customer_id = o.customer_id
group by c.customer_id, c.name
order by total_spent desc
limit 10;


-- Phase 2: Customer Segmentation

-- 4.Customer Category based on Spending(Gold, Silver, Bronze)
select c.customer_id, c.name,
sum(o.order_amount-o.discount) as Total_Spending,
case
    when sum(o.order_amount-o.discount) >= 1000 then 'Gold'
    when sum(o.order_amount-o.discount) >= 500 then 'Silver'
    else 'Bronze'
end as Customer_Category
from customers c
join orders o on c.customer_id = o.customer_id
group by c.customer_id, c.name;


-- Phase 3: Restaurant Performance Analysis

-- 5. Top 10 Restaurants by Total Revenue
select r.restaurant_id, r.restaurant_name, sum(o.order_amount - o.discount) as total_revenue
from restaurants r
join orders o on r.restaurant_id = o.restaurant_id
group by r.restaurant_id, r.restaurant_name
order by total_revenue desc
limit 10;

-- 6. Average Rating vs Revnue
select r.restaurant_id, r.restaurant_name, 
sum(o.order_amount - o.discount) as Total_Revenue,
avg(rating) as Average_Rating
from restaurants r
join orders o on r.restaurant_id = o.restaurant_id
group by r.restaurant_id, r.restaurant_name
order by total_revenue desc;


-- Phase 4: Delivery Performance Analysis

-- 7. Average Delivery Time per Restaurant
select  r.city,
avg(o.delivery_time) as average_delivery_time
from restaurants r
join orders o on r.restaurant_id = o.restaurant_id
group by r.city;


-- 8. Late Deliveries (above 45 Minutes)
select r.restaurant_id, r.restaurant_name, o.order_id, o.delivery_time as Late_Deliveries
from restaurants r
join orders o on r.restaurant_id = o.restaurant_id
where o.delivery_time > 45;

-- Phase 5: Payment & Discount Analysis

-- 9. Payment Method Distribution
select payment_method, count(*) as count
from orders
group by payment_method;

-- 10. Discount impact on revenue
select r.restaurant_id, r.restaurant_name,
sum(o.order_amount) as Total_Revenue_Before_Discount,
sum(o.order_amount - o.discount) as Total_Revenue_After_Discount
from restaurants r
join orders o on r.restaurant_id = o.restaurant_id
group by r.restaurant_id, r.restaurant_name;


-- Phase 6: Advance SQL 

-- 11. Monthly Revenue using CTE
with monthly_revenue as (
    select month(order_date) as month,
    sum(order_amount-discount) as revenue
    from orders
    group by month
    order by month
)
select month, revenue
from monthly_revenue;

-- 12. Rank Restaurants by Revenue using Window Functions

with restaurant_revenue as(
    select r.restaurant_id, r.restaurant_name,
    sum(o.order_amount - o.discount) as total_revenue
    from restaurants r
    join orders o on r.restaurant_id = o.restaurant_id
    group by r.restaurant_id, r.restaurant_name
)
select restaurant_id, restaurant_name, total_revenue,
rank() over(order by total_revenue desc) as revenue_rank
from restaurant_revenue
order by revenue_rank;

-- 13. Restaurants with Above Average Revenue
select restaurant_id, restaurant_name, total_revenue
from (
    select r.restaurant_id, r.restaurant_name,
    sum(o.order_amount - o.discount) as total_revenue
    from restaurants r
    join orders o on r.restaurant_id = o.restaurant_id
    group by r.restaurant_id, r.restaurant_name
) as restaurant_revenue
where total_revenue > (
    select avg(total_revenue) from (
        select sum(o.order_amount - o.discount) as total_revenue
        from restaurants r
        join orders o on r.restaurant_id = o.restaurant_id
        group by r.restaurant_id, r.restaurant_name
    ) as avg_revenue
);


-- Phase 7: Database Objects

-- 14. Create Revenue View
create view restaurant_revenue_view as
select r.restaurant_id, r.restaurant_name,
sum(o.order_amount-o.discount) as total_revenue
from restaurants r
join orders o on r.restaurant_id = o.restaurant_id
group by r.restaurant_id, r.restaurant_name;

use restaurants;

-- 15. Stored Procedure: Get Top N Restaurants by Revenue

create procedure Get_Topn_Restaurants(IN top_N int)
begin
    set @sql = concat(
        'select restaurant_id, restaurant_name, total_revenue ',
        'from ( ',
        'select r.restaurant_id, r.restaurant_name, ',
        'sum(o.order_amount - o.discount) as total_revenue ',
        'from restaurants r ',
        'join orders o on r.restaurant_id = o.restaurant_id ',
        'group by r.restaurant_id, r.restaurant_name ',
        ') as revenue_sub ',
        'order by total_revenue desc ',
        'limit ', top_N, ';'
    );
    prepare stmt from @sql;
    execute stmt;
    deallocate prepare stmt;
end;

call Get_Topn_Restaurants(5);

-- phase 8: Optimization & Indexing

-- 16. Create Index on Order date
create INDEX idx_order_date on orders(order_date);

-- 17. Create Index on Customer_name
create INDEX idx_customer_name on customers(name(100));

-- 18. Create Index on Restaurant_name
create INDEX idx_restaurant_name on restaurants(restaurant_name(100));

-- phase 9: Automation Logic

-- 19. Trigger- Prevent Negative Discount

-- auto log high value orders

create table high_value_orders_log (
    log_id int auto_increment primary key,
    order_id int,
    customer_id int,
    restaurant_id int,
    order_amount decimal(10,2),
    log_date datetime default current_timestamp
);

-- Trigger to log high value orders above 1000
create trigger trg_high_value_orders
after insert on orders
for each row
begin
    if new.order_amount > 1000 then
        insert into high_value_orders_log (order_id, customer_id, restaurant_id, order_amount)
        values (new.order_id, new.customer_id, new.restaurant_id, new.order_amount);
    end if;
end;


-- Test the trigger by inserting a high value order
insert into orders (order_id, customer_id, restaurant_id, order_amount, discount, order_date, delivery_time, payment_method)
values 
(1002, 232, 202, 800.00, 50.00, '2024-01-16', 40, 'Cash'),
(1003, 233, 203, 1500.00, 200.00, '2024-01-17', 25, 'Online Payment');


-- Create Trigger to prevent negative discount
create trigger trg_prevent_negative_discount
before insert on orders
for each row
begin
    if new.discount < 0 then
        set new.discount = 0;
    end if;
end;


-- Test the trigger by inserting an order with negative discount
insert into orders (order_id, customer_id, restaurant_id, order_amount, discount, order_date, delivery_time, payment_method)
values (1004, 234, 204, 500.00, -20.00, '2024-01-18', 30, 'Online Payment');

-- Verify that the discount was set to 0
select * from orders where order_id = 1004;


-- Delivery Delay warning
create table delivery_delay_log (
    log_id int auto_increment primary key,
    order_id int,
    customer_id int,
    restaurant_id int,
    delivery_time int,
    created_at timestamp default current_timestamp
);

-- Trigger to log delivery delays above 45 minutes
create trigger trg_delivery_delay
after insert on orders
for each row
begin
    if new.delivery_time > 45 then
        insert into delivery_delay_log (order_id, customer_id, restaurant_id, delivery_time)
        values (new.order_id, new.customer_id, new.restaurant_id, new.delivery_time);
    end if;
end;

-- Test the trigger by inserting an order with delivery time above 45 minutes
insert into orders (order_id, customer_id, restaurant_id, order_amount, discount, order_date, delivery_time, payment_method)    
values(1008, 238, 208, 600.00, 30.00, '2024-01-19', 50, 'Cash'),
(1009, 239, 209, 700.00, 40.00, '2024-01-20', 60, 'Online Payment');

-- Verify that the delivery delay was logged
select * from delivery_delay_log where order_id in (1008, 1009);