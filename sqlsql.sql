What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers?


--All sellers amount
SELECT SUM(oi.price) AS total_earned_by_all_sellers FROM order_items oi;

--groupby
SELECT oi.seller_id, SUM(oi.price) AS earned_by_seller FROM order_items oi
GROUP BY oi.seller_id
ORDER BY earned_by_seller DESC;


--Tech amount
SELECT SUM(oi.price) AS total_earned_by_tech_sellers
FROM order_items oi
JOIN products p
  ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t
  ON p.product_category_name = t.product_category_name
WHERE t.product_category_name_english IN (
  'computers','computers_accessories','electronics',
  'telephony','fixed_telephony','consoles_games','pc_gamer',
  'tablets_printing_image','security_and_services',
  'signaling_and_security','stationery'
);


Can you work out the average monthly income of all sellers? Can you work out the average monthly income of Tech sellers?

--seller   566318.4875716815 ??? delivered 574847.7440024718
SELECT 
  DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
  SUM(oi.price) AS monthly_income
FROM order_items oi
JOIN orders o  ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY month;



--tech
SELECT 
  DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
  SUM(oi.price) AS monthly_income_tech
FROM order_items oi
JOIN orders o   ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t
       ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
  AND t.product_category_name_english IN (
    'computers','computers_accessories','electronics','audio',
    'telephony','fixed_telephony','consoles_games','pc_gamer',
    'tablets_printing_image','security_and_services',
    'signaling_and_security','stationery'
  )
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY month;


How many orders are delivered on time vs orders delivered with a delay?

SELECT 
  CASE 
    WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date 
         THEN 'on_time'
    ELSE 'delayed'
  END AS delivery_status,
  COUNT(*) AS orders_count
FROM orders o
WHERE o.order_status = 'delivered'
GROUP BY delivery_status;


product size

SELECT 
  t.product_category_name_english,
  d.delivery_status,
  COUNT(*) AS orders_count
FROM orders o
JOIN order_items oi  ON o.order_id = oi.order_id
JOIN products p      ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t 
       ON p.product_category_name = t.product_category_name
JOIN (
  SELECT 
    order_id,
    CASE 
      WHEN order_delivered_customer_date <= order_estimated_delivery_date 
           THEN 'on_time'
      ELSE 'delayed'
    END AS delivery_status
  FROM orders
  WHERE order_status = 'delivered'
) d ON o.order_id = d.order_id
GROUP BY t.product_category_name_english, d.delivery_status
ORDER BY orders_count DESC;


-Delays
- tech sellers concentration are less
Spendings

******************************* 20.09.2025

What categories of tech products does Magist have?

SELECT 
    tr.product_category_name_english AS tech_category,
    COUNT(*) AS product_count
FROM products p
LEFT JOIN product_category_name_translation tr
       ON p.product_category_name = tr.product_category_name
GROUP BY tr.product_category_name_english
ORDER BY product_count DESC;


How many products of these tech categories have been sold (within the time window of the database snapshot)? What percentage does that represent from the overall number of products sold?


SELECT 
  t.total_products_sold,
  s.tech_products_sold,
  ROUND( (s.tech_products_sold / t.total_products_sold) * 100 , 2) AS tech_products_percentage
FROM
  (SELECT COUNT(*) AS total_products_sold
   FROM order_items) t
CROSS JOIN
  (SELECT COUNT(*) AS tech_products_sold
   FROM order_items oi
   JOIN products p 
     ON oi.product_id = p.product_id
   LEFT JOIN product_category_name_translation tr
     ON p.product_category_name = tr.product_category_name
   WHERE tr.product_category_name_english IN (
     'computers','computers_accessories','electronics','audio',
     'telephony','fixed_telephony','consoles_games','pc_gamer',
     'tablets_printing_image','security_and_services',
     'signaling_and_security','stationery'
   )) s;


'112650','19917','17.68'


What’s the average price of the products being sold?

120.65