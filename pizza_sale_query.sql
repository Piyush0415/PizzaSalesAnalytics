-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;

-- Calculate the total revenue generated from pizza sales
SELECT 
    ROUND(SUM(p.price * od.quantity), 2) AS total_revenue
FROM
    pizzas AS p
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id;

-- Identify the highest priced piza 
SELECT 
    pt.name, p.price
FROM
    pizzas AS p
        JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    p.size AS size, COUNT(size) AS common_size_ordered
FROM
    pizzas AS p
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY common_size_ordered DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities
SELECT 
    pt.name AS pizza_type,
    COUNT(od.order_details_id) AS orders,
    SUM(od.quantity) AS quantity
FROM
    pizzas AS p
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
        JOIN
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY quantity DESC
LIMIT 5;

-- Retrieve the total quantity of each pizza ordered
SELECT 
    pt.category AS pizza_type, SUM(od.quantity) AS quantity
FROM
    pizzas AS p
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
        JOIN
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY quantity DESC;

-- Determine the distribution of orders by hour of the day
SELECT 
    HOUR(order_time) AS hours, COUNT(order_id)
FROM
    orders
GROUP BY HOUR(order_time);

-- bb Category wise pizza distribution 
SELECT
	category, COUNT(name) AS total_pizza
FROM 
	pizza_types
GROUP BY category;

-- Calculate the average number of pizzas ordered per day
WITH total_pizza_cte AS (SELECT 
	o.order_date AS orders_date, SUM(od.quantity) AS total_pizza
FROM 
	order_details AS od
		JOIN 
	orders AS o ON o.order_id = od.order_id
GROUP BY o.order_date )

SELECT 
	ROUND(AVG(total_pizza), 0) AS avg_pizza_order_per_day
FROM total_pizza_cte;

-- Determine the top 3 most ordered pizza typed based on revenue
SELECT 
	pt.name, ROUND(SUM(p.price*od.quantity), 2) AS total_pizza_sales
FROM 
	pizzas AS p
		JOIN 
	order_details AS od ON p.pizza_id = od.pizza_id
		JOIN 
	pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY total_pizza_sales DESC
LIMIT 3;

-- Calculate the percentage contibution of each pizza type to total revenue.
 WITH pizza_sales_cte AS ( SELECT 
	pt.category, ROUND(SUM(p.price*od.quantity), 2) AS total_pizza_sales
FROM 
	pizzas AS p
		JOIN 
	order_details AS od ON p.pizza_id = od.pizza_id
		JOIN 
	pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY total_pizza_sales DESC )

SELECT
	category, ROUND((total_pizza_sales / SUM(total_pizza_sales) OVER()) * 100, 2)  AS contribute_percentage
FROM pizza_sales_cte;

-- Analyze the cumulative revenue generated over time 
SELECT 
	o.order_date, ROUND(SUM(od.quantity * p.price), 2) AS pizza_sales,
    SUM(ROUND(SUM(od.quantity * p.price), 2))  OVER (ORDER BY o.order_date) AS cum_revenue
FROM 
	pizzas AS p
		JOIN 
	order_details AS od ON p.pizza_id = od.pizza_id
		JOIN 
	orders AS o ON o.order_id = od.order_id
GROUP BY o.order_date;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category 
SELECT * 
FROM ( 
	SELECT 
	pt.category,pt.name, p.pizza_type_id,
    SUM(p.price * od.quantity) AS sales,
    DENSE_RANK() OVER(PARTITION BY category ORDER BY SUM(p.price * od.quantity) DESC) AS rnk
FROM 
	pizzas AS p
		JOIN 
	order_details AS od ON p.pizza_id=od.pizza_id
		JOIN 
	pizza_types AS pt ON p.pizza_type_id=pt.pizza_type_id
GROUP BY pt.category,pt.name, p.pizza_type_id
ORDER BY category
) AS T
WHERE rnk IN (1, 2, 3);
    
