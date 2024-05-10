select * from order_details;
select * from orders;

CREATE TABLE pizza_types (
    pizza_type_id VARCHAR(20) PRIMARY KEY,
    name CHARACTER VARYING(100),
    category CHARACTER VARYING(50),
    ingredients CHARACTER VARYING(255)
);

SELECT * FROM pizza_types;
select * from orders;

CREATE TABLE pizza_prices (
    pizza_id CHARACTER VARYING(20),
    pizza_type_id CHARACTER VARYING(20),
    size CHARACTER VARYING(20),
    price NUMERIC(8,2)
);

SELECT * FROM pizza_prices;

-- -------------------------------Basics------------------------------- --

-- Retrive the total number of orders placed.
select count(order_id) as total_orders from orders;

-- calculate the total revenue generated from pizza sales.
select * from order_details;
select * from pizza_prices;
select
round(sum (order_details.quantity * pizza_prices.price),2) as total_sales
from order_details join pizza_prices
on pizza_prices.pizza_id = order_details.pizza_id

-- Identify the highest-priced pizza.
select pizza_types.name, pizza_prices.price
from pizza_types join pizza_prices
on pizza_types.pizza_type_id = pizza_prices.pizza_type_id
order by pizza_prices.price desc limit 1;

-- Identify the most common pizza size ordered.
select * from order_details;
select quantity, count(order_id)
from order_details group by quantity;

-- Identify the most common pizza size ordered.
select pizza_prices.size, count(order_details.order_id) as order_count
from pizza_prices join order_details
on pizza_prices.pizza_id = order_details.pizza_id
group by pizza_prices.size order by order_count desc;

-- List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name,
sum(order_details.quantity) as quantity
from pizza_types join pizza_prices
on pizza_types.pizza_type_id = pizza_prices.pizza_type_id
join order_details
on order_details.pizza_id = pizza_prices.pizza_id
group by pizza_types.name order by quantity desc limit 5;


-- -------------------------------Intermediate------------------------------- --

-- Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_types.category,
sum(order_details.quantity) as quantity
from pizza_types join pizza_prices
on pizza_types.pizza_type_id = pizza_prices.pizza_type_id
join order_details
on order_details.pizza_id = pizza_prices.pizza_id
group by pizza_types.category order by quantity desc;

-- Determine the distribution of orders by hour of the day.

SELECT EXTRACT(HOUR FROM time) AS hour, COUNT(order_id) 
FROM orders 
GROUP BY EXTRACT(HOUR FROM time) order by count desc;

-- Join relevant tables to find the category-wise distribution of pizzas.

select category, count(name) from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(quantity),0) as avg_pizza_ordered_per_day
from (select orders.date, sum(order_details.quantity) as quantity
from orders join order_details
on orders.order_id = order_details.order_id
group by orders.date) as order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name,
sum(order_details.quantity * pizza_prices.price) as revenue
from pizza_types join pizza_prices
on pizza_prices.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id = pizza_prices.pizza_id
group by pizza_types.name order by revenue desc limit 3;


-- -------------------------------Advanced------------------------------- --

-- Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category,
sum(order_details.quantity * pizza_prices.price) as revenue
from pizza_types join pizza_prices
on pizza_types.pizza_type_id = pizza_prices.pizza_type_id
join order_details
on order_details.pizza_id = pizza_prices.pizza_id
group by pizza_types.category order by revenue desc;

select pizza_types.category,
round(sum(order_details.quantity*pizza_prices.price) / (select
	round (sum (order_details.quantity * pizza_prices.price),
			2) as total_sales
from
	order_details
		join
	pizza_prices on pizza_prices.pizza_id = order_details.pizza_id)*100,2) as revenue
from pizza_types join pizza_prices
on pizza_types.pizza_type_id = pizza_prices.pizza_type_id
join order_details
on order_details.pizza_id = pizza_prices.pizza_id
group by pizza_types.category order by revenue desc;

-- Analyze the cumulative revenue generated over time.

select date, sum (revenue) over (order by date) as cum_revenue
from
(select orders.date,
sum(order_details.quantity * pizza_prices.price) as revenue
from order_details join pizza_prices
on order_details.pizza_id = pizza_prices.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name, revenue from
(select category, name, revenue,
 rank() over(partition by category order by revenue desc) as rn
 from
 (select pizza_types.category, pizza_types.name,
  sum((order_details.quantity) * pizza_prices.price) as revenue
  from pizza_types join pizza_prices
  on pizza_types.pizza_type_id = pizza_prices.pizza_type_id
  join order_details
  on order_details.pizza_id = pizza_prices.pizza_id
  group by pizza_types.category, pizza_types.name) as a) as b
  where rn <= 3;
