/* Q1; what is the total amount each customer spent at the restaurant?*/

 SELECT customer_id, CONCAT( '$',  SUM(price))AS Total_amount
  FROM dannys_diner.menu AS menu
   JOIN dannys_diner.sales AS sales
    ON menu.product_id = sales.product_id
   GROUP BY customer_id
     ORDER BY Total_amount DESC --- customer_id A spent $76
                                ---customer_id B spent $74 
                                ---customer_id C spent $36
     
/*Q2; How many days has each customer visited the retaurant */ 

SELECT customer_id, COUNT(order_date) 
 FROM  dannys_diner.sales
  GROUP BY customer_id --- Customer_id A and B visited 6 times 
                       ---  customer_id C visited 3 times 

/* Q3; what was the first item from the menu purchased by each customer*/
---using CTE
WITH first_purchase AS
    (SELECT customer_id, MIN (order_date) AS first_item
    FROM dannys_diner.sales AS sales
    GROUP BY customer_id)
SELECT s.customer_id, menu.product_name, order_date
 FROM dannys_diner.sales AS s
  JOIN first_purchase AS f
   ON f.customer_id= s.customer_id AND s.order_date= f.first_item
    JOIN dannys_diner.menu 
     ON s.product_id=menu.product_id --- sushi and curry were the first item purchase by customer_id A
                                     --- curry was the first item purchased by customer_id B/*
                                     ---ramen was the first item purchased by customer_id C/*


/* Q4; what is the most purchased item on the menu and how many times was it purchase by all customer*/
SELECT DISTINCT menu.product_name, COUNT(sales.product_id) AS most_ordered 
 FROM dannys_diner.sales AS sales
  JOIN dannys_diner.menu AS menu
   ON sales.product_id=menu.product_id
     GROUP BY menu.product_name 
    ORDER BY  COUNT(sales.product_id) DESC LIMIT 1 ---ramen was the most purchased by all the customer with the total of 8 */   
    
/*Q5; which item was the most popular for each customer*/
SELECT product_name, customer_id, COUNT(sales.product_id) AS most_popular
 FROM dannys_diner.sales AS sales
  JOIN dannys_diner.menu AS menu
   ON sales.product_id=menu.product_id
    GROUP BY product_name,customer_id
     ORDER BY most_popular DESC LIMIT 1 ---ramen was the most popular for customer_id C and customer_id A 
                                        ---sushi was the most popular for customer_id B


/*Q6; which items was purchased first by the customer after they became a member*/

SELECT me.product_name, me2.customer_id, sa.order_date
   FROM dannys_diner.menu AS me
    JOIN dannys_diner.sales AS sa
     ON me.product_id=sa.product_id
    JOIN dannys_diner.members AS me2
     ON sa.customer_id =me2.customer_id
WHERE sa.order_date > me2.join_date
 GROUP BY me.product_name, me2.customer_id, sa.order_date
   ORDER BY order_date -- ramen was the first item purchased by customer_id A and sushi was the first item purchased by customer_id B 

/*Q7; which items was purchased just before the customer bacame a member*/

SELECT me.product_name, me2.customer_id, sa.order_date
   FROM dannys_diner.menu AS me
    JOIN dannys_diner.sales AS sa
     ON me.product_id=sa.product_id
    JOIN dannys_diner.members AS me2
     ON sa.customer_id =me2.customer_id
WHERE sa.order_date < me2.join_date
 GROUP BY me.product_name, me2.customer_id, sa.order_date
   ORDER BY order_date  ----  sushi and curry where the items purchased before the customer became members/*
 
 ---/*Q8; what is the total items and amount spent by each member before they became a member*/
 
 SELECT sa.customer_id ,
        COUNT(sa.product_id) AS total_items,
         CONCAT('$', SUM(m2.price)) AS total_amount
  FROM dannys_diner.members AS m1
  JOIN dannys_diner.sales AS sa
   ON m1.customer_id=sa.customer_id
  JOIN dannys_diner.menu AS m2
   ON sa.product_id = m2.product_id
    WHERE sa.order_date < m1.join_date
      GROUP BY sa.customer_id
       ORDER BY sa.customer_id --customer_id A bought total of 2 items and total amount of $25
                               --- customer_id B bought total of 3 items and total amount of $40
                               
/*Q9; if each $1 spent equates to 10 points and sushi has a 2* points multiplier, how many ponts would each customer have?*/

with selling_points AS
 (SELECT customer_id, CASE WHEN m1.product_id = 1 THEN price * 20
 ELSE price * 10
  END AS  points
   FROM dannys_diner.sales AS sa 
    JOIN dannys_diner.menu AS m1
     ON sa.product_id = m1.product_id)
 
 SELECT customer_id, SUM(points) AS Total_points
  FROM selling_points
   GROUP BY customer_id
    ORDER BY total_points DESC -- customer_id B has the total_points of 940
                              --- customer_id A has the total_points of 860
                              --- customer_id C has the total_points of 360
 
/*Q10; In the first week after the customer joins the program (including their join date)
--they earn 2* ponits on all items, not just sushi. How many points do customer A and B have at the end of january?*/

SELECT s.customer_id,
 SUM
 (CASE 
  WHEN s.order_date BETWEEN m1.join_date AND (m1.join_date + 6)
   THEN (m2.price * 20)
  WHEN product_name = 'sushi' THEN price * 20
   ELSE m2.price * 10
   END ) AS points
   
   FROM dannys_diner.sales AS s
    JOIN dannys_diner.members AS m1
     ON s.customer_id = m1.customer_id
    JOIN dannys_diner.menu AS m2
     ON m2.product_id = s.product_id
   WHERE s.order_date >= '2021-01-01' AND s.order_date <'2021-02-01'
    GROUP BY s.customer_id
     ORDER BY s.customer_id -- customer_A has the total of 1370 points in the first week  
                            --customer_B has the total of 820 points in the first week 
