create database pizza_house;

use pizza_house;

create table orders(
order_id int not null primary key,
order_date date not null,
order_time time not null);

create table order_details(
order_details_id int not null primary key,
order_id int not null,
pizza_id text not null,
quantity int not null);

-- QUESTIONS

-- Retrieve the total number of orders placed.
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM orders;

-- Calculate the total revenue generated from pizza sales.
SELECT round(sum(od.quantity * p.price),2) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id;

-- Identify the highest-priced pizza.
SELECT pt.name AS pizza_name
FROM pizzas p
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT p.size, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY total_quantity DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name AS pizza_name,
    SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pt.category, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category;

-- Determine the distribution of orders by hour of the day.
SELECT hour(order_time) as hour , count(order_id) as order_count
from orders
group by hour(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT pt.category, COUNT(DISTINCT p.pizza_id) AS pizza_count
FROM pizzas p
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(quantity), 0)
FROM (
    SELECT o.order_date, SUM(od.quantity) AS quantity
    FROM orders o 
    JOIN order_details od
    ON o.order_id = od.order_id
    GROUP BY o.order_date
) AS order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT pt.name AS pizza_name,
       SUM(od.quantity * p.price) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.category AS pizza_category,
    ROUND(SUM(od.quantity * p.price) * 100.0 / 
         (SELECT SUM(od2.quantity * p2.price)
          FROM order_details od2
          JOIN pizzas p2 ON od2.pizza_id = p2.pizza_id), 2) AS percentage_contribution
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY percentage_contribution DESC;

-- Analyze the cumulative revenue generated over time.
SELECT 
    o.order_date,
    ROUND(SUM(od.quantity * p.price), 2) AS daily_revenue,
    ROUND(SUM(SUM(od.quantity * p.price)) OVER (ORDER BY o.order_date), 2) AS cumulative_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN orders o ON od.order_id = o.order_id
GROUP BY o.order_date
ORDER BY o.order_date;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT 
    category, 
    name, 
    revenue
FROM (
    SELECT 
        category, 
        name, 
        revenue,
        RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
    FROM (
        SELECT 
            pt.category, 
            pt.name, 
            SUM(od.quantity * p.price) AS revenue
        FROM pizza_types pt
        JOIN pizzas p 
            ON pt.pizza_type_id = p.pizza_type_id
        JOIN order_details od 
            ON p.pizza_id = od.pizza_id
        GROUP BY pt.category, pt.name
    ) AS a
) AS b
WHERE rn <= 3;













