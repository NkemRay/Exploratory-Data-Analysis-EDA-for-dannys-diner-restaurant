/*
A.PIZZA METRICS
1. How many pizzas were ordered?
2. How many unique customer orders were made?
3. How many successful orders were delivered by each customer?
4. How many of each type of pizza was delivered?
5. How many vegetarian and meatlovers were ordered by each customer?
6. What was the maximum number of pizzas delivered in a single order?
7. For each customer, how many delivered pizzas had at least 1 chang and how many had no changes?
8. How many pizzas were delivered that had both exclusions and extras?
9. What was the total volume of pizzas ordered for each hour of the day?
10. What was the volumn of orders for each day of the week?
*/

--A.1   
SELECT COUNT(pizza_id) AS amount_ordered
  FROM pizza_runner.customer_orders

--A.2
SELECT DISTINCT customer_id, COUNT(order_id) AS unique_orders
 FROM pizza_runner.customer_orders
  GROUP BY customer_id
   ORDER BY COUNT(order_id) 

--A.3
WITH cleaned_orders AS(
SELECT order_id, runner_id, pickup_time, distance, duration,
 CASE WHEN cancellation ='null' THEN 0
      WHEN cancellation IS null THEN 0
      WHEN cancellation = '' THEN 0
      ELSE 1 END AS cancellation
FROM pizza_runner.runner_orders
)
 SELECT COUNT(*) AS delivered_orders
 FROM cleaned_orders
 WHERE cancellation = 0

--A.4
WITH cleaned_orders AS(
SELECT order_id, runner_id, pickup_time, distance, duration,
 CASE WHEN cancellation ='null' THEN 0
      WHEN cancellation IS null THEN 0
      WHEN cancellation = '' THEN 0
      ELSE 1 END AS cancellation
FROM pizza_runner.runner_orderS
) 
  SELECT pizza_id, COUNT(*) AS number_of_pizzas
FROM(
    SELECT p.*, r.cancellation
    FROM pizza_runner.customer_orders AS p
      JOIN cleaned_orders AS r 
      ON p.order_id = r.order_id) AS temp_table
    WHERE cancellation = 0
    GROUP BY pizza_id
    
--A.5
SELECT  customer_id, 
  COALESCE (SUM(CASE WHEN pizza_id = 1 THEN 1 END),0) AS meatlovers,
  COALESCE (SUM(CASE WHEN pizza_id = 2 THEN 1 END), 0) AS vegetarians
FROM pizza_runner.customer_orders
GROUP BY customer_id

--A.6
SELECT DISTINCT v.order_id, COUNT(*) AS pizzas_delivered
FROM pizza_runner.customer_orders v
WHERE order_id IN (
             SELECT DISTINCT order_id
            FROM (
                SELECT order_id, runner_id, pickup_time, distance, duration,
                 CASE WHEN cancellation IN ('null', '') OR cancellation IS null THEN 0
                 ELSE 1 END AS cancellation
                FROM pizza_runner.runner_orders) AS runners_orders
WHERE cancellation = 0
)
GROUP BY order_id
ORDER BY pizzas_delivered DESC;

--A.7
WITH cleaned_orders AS (
SELECT order_id, customer_id, pizza_id,
  CASE WHEN exclusions IN ('null', '') THEN null ELSE exclusions END AS exclusions,
  CASE WHEN extras IN ('null', '') THEN null ELSE extras END AS extras,
   order_time
FROM pizza_runner.customer_orders
),
 runner_orders AS (
   SELECT order_id, runner_id, pickup_time, distance, duration,
    CASE WHEN cancellation IN ('null', '') OR cancellation IS null THEN 0 
    ELSE 1 END AS cancellation 
    FROM pizza_runner.runner_orders
 )
 SELECT customer_id,
      COUNT(CASE WHEN change = 0 THEN 0 END) AS pizza_no_change,
      COUNT(CASE WHEN change = 1 THEN 1 END) AS pizza_with_change
 FROM (
    SELECT r.*,
       CASE WHEN exclusions IS null AND extras IS null THEN 0 ELSE 1 END AS change
    FROM cleaned_orders AS r
        WHERE order_id IN (SELECT order_id 
                           FROM runner_orders
                            WHERE cancellation = 0)
 ) AS pizza_changes
 GROUP BY customer_id;
 
--A.8
WITH cleaned_orders AS (
 SELECT order_id, customer_id, pizza_id,
    CASE WHEN exclusions IN ('null', '') THEN null ELSE exclusions END AS exclusions,
    CASE WHEN extras IN ('null', '') THEN null ELSE extras END AS extras,
order_time
 FROM pizza_runner.customer_orders
),
 runner_orders AS(
   SELECT order_id, runner_id, pickup_time, distance, duration,
    CASE WHEN cancellation IN ('null', '') OR cancellation IS null THEN 0 
    ELSE  1 END AS  cancellation 
    FROM pizza_runner.runner_orders
 )
 SELECT COUNT(*) AS pizz_delivered
 FROM(
       SELECT u.*,
        CASE WHEN exclusions IS NOT null AND extras IS NOT null
       THEN 1 ELSE 0 END AS both_ex
 FROM cleaned_orders AS u
 WHERE order_id IN (SELECT order_id
                   FROM runner_orders
                   WHERE cancellation = 0)
 ) AS included_both_ex
 WHERE both_ex = 1;
 
 --A.9
 SELECT EXTRACT(HOUR FROM order_time) AS hour_of_day,
        COUNT(*) AS pizza_ordered
  FROM pizza_runner.customer_orders
  GROUP BY hour_of_day
  ORDER BY pizza_ordered DESC;
 
 --A.10
 SELECT TO_CHAR(order_time, 'Day') AS dow,
        EXTRACT(dow from order_time) AS dow2,
        COUNT(*)AS pizza_ordered
  FROM pizza_runner.customer_orders
  GROUP BY 1, 2
  ORDER BY pizza_ordered DESC;
  
  
 