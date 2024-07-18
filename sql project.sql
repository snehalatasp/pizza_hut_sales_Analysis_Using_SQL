use pizzahut;
-- Retrieve the total number of orders placed.
select count(order_id) as total_orders from orders;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS total_sales
FROM
   orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id;
    -- or
    SELECT 
    SUM(orders_details.quantity * pizzas.price) AS total_sales
	FROM orders_details
	JOIN pizzas
    ON pizzas.pizza_id = orders_details.pizza_id;

-- Identify the highest-priced pizza.
select max(price) from pizzas;
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC limit 1;
-- you can add the limits to more details
-- or
select max(price) from pizzas;


-- Identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS order_count
FROM pizzas
JOIN orders_details 
ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name, SUM(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- join the necessary table to find the total quantity of each pizza category ordered.
select sum(orders_details.quantity) as quantity, pizza_types.category
from pizzas
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id group by pizza_types.category;
-- or
select sum(orders_details.quantity) as quantity, pizza_types.category
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
    group by pizza_types.category order by quantity desc;
    
    
-- determine the distribution of orders by hour of the day.
select hour(order_time) as hours,count(order_id) as orders
from orders
group by hour(order_time)
order by count(order_id) desc ;

-- join relevant tables to find the category-wise distribution of pizzas.
select category,count(name) as pizza
from pizza_types
group by category;

-- group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(quantity),0) avg_orders
from (select orders.order_date, sum(orders_details.quantity) as quantity
from orders
join orders_details
on orders.order_id = orders_details.order_id
group by orders.order_date)as order_quantity;

-- determine the top 3 most ordered pizza type based on the revenue.
select orders_details.quantity, max(pizzas.price)
from pizzas
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by quantity;

select pizza_types.name,sum(orders_details.quantity * pizzas.price) as revenue
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by revenue desc limit 3;

-- calculate the percentage contribution of each pizza type to total revenune.
select pizza_types.name,round(sum(orders_details.quantity * pizzas.price) /
(select round(sum(orders_details.quantity * pizzas.price),2)
 FROM orders_details
	JOIN pizzas
    ON pizzas.pizza_id = orders_details.pizza_id) * 100 ,2) as percentage
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.name;
-- or
select pizza_types.category,round(sum(orders_details.quantity * pizzas.price) /
(select round(sum(orders_details.quantity * pizzas.price),2)
 FROM orders_details
	JOIN pizzas
    ON pizzas.pizza_id = orders_details.pizza_id) * 100 ,2) as percentage
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category;

-- analyze the cumulative revenue generation over time.
select order_date, round(sum(revenue) over(order by order_date),2) as cum_revenue
from
(select orders.order_date, sum(orders_details.quantity * pizzas.price) as revenue
from orders_details
join pizzas
on orders_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = orders_details.order_id
group by orders.order_date) as sales;