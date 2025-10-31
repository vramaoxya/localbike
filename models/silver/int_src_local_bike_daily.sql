WITH orders_date AS (
  SELECT 
        order_id, 
        order_date, 
        store_id,
        EXTRACT(YEAR  FROM order_date) as yeardate,
        EXTRACT(YEAR  FROM order_date) || '-' || EXTRACT(MONTH FROM order_date) AS yearmonth,
        LPAD(CAST( EXTRACT(MONTH FROM order_date) AS STRING), 2, '0') month_2digits,
        FORMAT_DATE('%B', DATE(CONCAT(EXTRACT(YEAR  FROM order_date), '-', EXTRACT(MONTH FROM order_date), '-01'))) AS month_name,
        FORMAT_DATE('%b', DATE(CONCAT(EXTRACT(YEAR  FROM order_date), '-', EXTRACT(MONTH FROM order_date), '-01'))) AS month_abbrev,
        EXTRACT(ISOWEEK FROM order_date) AS week_number
  FROM {{ ref('stg_src_local_bike_orders') }}
),
------------------------------------------
items_sold AS (
  SELECT 
        order_id, 
        quantity, 
        total_item_discount_sold
  FROM {{ ref('stg_src_local_bike_order_items') }}
),
------------------------------------------
stores AS (
  SELECT store_id, 
         store_city, 
         store_state
  FROM  {{ ref('stg_src_local_bike_stores') }}
),
------------------------------------------
line_sales AS (
  SELECT
    o.order_date,
    o.yeardate,
    o.yearmonth,
    o.month_2digits,
    o.month_name,
    o.month_abbrev,
    o.week_number,
    o.store_id,
    i.total_item_discount_sold AS net_amount
  FROM orders_date o
  JOIN items_sold  i USING (order_id)
)
------------------------------------------ 
SELECT
    ls.order_date,
    ls.yeardate,
    ls.yearmonth,
    ls.month_2digits,
    ls.month_name,
    ls.month_abbrev,
    ls.week_number,
    ls.store_id,
    s.store_city,
    s.store_state,
    COUNT(DISTINCT CONCAT(CAST(s.store_id AS STRING), '_', CAST(ls.order_date AS STRING))) AS order_day_keys,
    ROUND( SUM(ls.net_amount), 2) AS total_sales_amount,
    COUNT(*) AS total_items
FROM line_sales ls
JOIN stores s USING (store_id)
GROUP BY ls.order_date, ls.yeardate, ls.yearmonth, ls.week_number, ls.month_2digits, ls.month_name, ls.month_abbrev,ls.store_id, s.store_city, s.store_state 