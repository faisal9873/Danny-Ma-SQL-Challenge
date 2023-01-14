
/* Case Study Questions */

--1. What is the total amount each customer spent at the restaurant?
--2. How many days has each customer visited the restaurant?
--3. What was the first item from the menu purchased by each customer?
--4. What is the most purchased item on the menu and how many times was it purchased by all customers?
--5. Which item was the most popular for each customer?
--6. Which item was purchased first by the customer after they became a member?
--7. Which item was purchased just before the customer became a member?
--8. What is the total items and amount spent for each member before they became a member?
--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

/*Tables*/
--sales
--menu
--members

/*Question 1*/

SELECT
	sales.customer_id,
    SUM(menu.price)
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu ON menu.product_id=sales.product_id
GROUP BY customer_id;

/*Question 2*/
SELECT
	customer_id,
    COUNT (DISTINCT order_date)
FROM dannys_diner.sales
GROUP BY customer_id;

/*Question 3*/
SELECT sales.customer_id,
	   MIN(sales.order_date)
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu ON menu.product_id = sales.product_id
GROUP BY sales.customer_id

/*Question 4*/
SELECT menu.product_name,
	COUNT(menu.product_name)
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu ON menu.product_id = sales.product_id
GROUP BY menu.product_name;

/*Question 5*/
SELECT DISTINCT ON (Ab.customer_id)
			Ab.customer_id, Ab.product_name, max(Ab.mycount)
FROM (SELECT sales.customer_id, menu.product_name,
	COUNT(menu.product_name) as mycount
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu ON menu.product_id = sales.product_id
GROUP BY menu.product_name, sales.customer_id
ORDER BY sales.customer_id DESC ) as Ab
GROUP BY Ab.customer_id, Ab.product_name

/*Question 6*/
SELECT Ab.customer_id, Ab.order_date, Ab.product_id, menu.product_name
FROM(
SELECT DISTINCT ON (Tb.customer_id) Tb.customer_id, Tb.order_date, Tb.product_id
FROM (SELECT sales.customer_id, sales.order_date, sales.product_id
FROM dannys_diner.sales
INNER JOIN dannys_diner.members ON members.join_date <= sales.order_date AND members.customer_id = sales.customer_id 
ORDER BY sales.order_date ASC) as Tb) as Ab
INNER JOIN dannys_diner.menu ON menu.product_id = Ab.product_id

/*Question 7*/
SELECT Ab.customer_id, Ab.order_date, Ab.product_id, menu.product_name
FROM(
SELECT DISTINCT ON (Tb.customer_id) Tb.customer_id, Tb.order_date, Tb.product_id
FROM (SELECT sales.customer_id, sales.order_date, sales.product_id
FROM dannys_diner.sales
INNER JOIN dannys_diner.members ON members.join_date > sales.order_date AND members.customer_id = sales.customer_id 
ORDER BY sales.order_date DESC) as Tb) as Ab
INNER JOIN dannys_diner.menu ON menu.product_id = Ab.product_id

/*Question 8*/
SELECT At.customer_id, SUM(At.price)
FROM (SELECT Ab.customer_id, Ab.order_date, Ab.product_id, Ab.product_name, Ab.price
FROM (SELECT sales.customer_id, sales.order_date, sales.product_id, menu.product_name, menu.price
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu ON menu.product_id = sales.product_id) as Ab
INNER JOIN dannys_diner.members ON members.join_date > Ab.order_date AND members.customer_id = Ab.customer_id) as At
GROUP BY customer_id

/*Question 9*/
ALTER Table dannys_diner.sales
ADD points INT;
UPDATE dannys_diner.sales
SET points = (SELECT menu.price
FROM dannys_diner.menu
WHERE menu.product_id =sales.product_id);
SELECT sales.customer_id, sales.order_date, sales.product_id, menu.product_name, sales.points, case menu.product_name
WHEN 'sushi' THEN sales.points*20
ELSE sales.points*10 
END
AS result
FROM dannys_diner.sales

/*Question 10*/
ALTER Table dannys_diner.sales
ADD points INT;
UPDATE dannys_diner.sales
SET points = (SELECT menu.price
FROM dannys_diner.menu
WHERE menu.product_id =sales.product_id);
SELECT Tb.customer_id, Tb.order_date, Tb.join_date, Tb.product_id, Tb.product_name, Tb.points, Tb.result,
case 
WHEN Tb.order_date >= Tb.join_date AND Tb.order_date < Tb.join_date + 7 AND Tb.product_name != 'sushi' THEN Tb.result*2 
ELSE Tb.result*1 
END
AS resulta
FROM (SELECT sales.customer_id, sales.order_date, members.join_date, sales.product_id, menu.product_name, sales.points, case menu.product_name
WHEN 'sushi' THEN sales.points*20
ELSE sales.points*10 
END
AS result
FROM dannys_diner.sales
LEFT JOIN dannys_diner.members ON members.customer_id = sales.customer_id
INNER JOIN dannys_diner.menu ON menu.product_id = sales.product_id) as Tb

