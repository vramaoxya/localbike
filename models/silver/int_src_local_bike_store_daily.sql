------------------------------------------
{{ 
    config
    (
        partition_by={"field":"order_date","data_type":"date"},
        cluster_by=["store_id"]
    )
}}
------------------------------------------
WITH orders_date AS (

  SELECT 
        order_id, 
        order_date, 
        store_id,
        EXTRACT(YEAR  FROM order_date) as yeardate,
        EXTRACT(YEAR  FROM order_date) || '-' || LPAD(CAST( EXTRACT(MONTH FROM order_date) AS STRING), 2, '0') AS yearmonth,
        LPAD(CAST( EXTRACT(MONTH FROM order_date) AS STRING), 2, '0') || '-' || LPAD(CAST( EXTRACT(DAY FROM order_date) AS STRING), 2, '0') AS monthday,
        LPAD(CAST( EXTRACT(MONTH FROM order_date) AS STRING), 2, '0') as month_2digits,
        FORMAT_DATE('%B', DATE(CONCAT(EXTRACT(YEAR  FROM order_date), '-', EXTRACT(MONTH FROM order_date), '-01'))) AS month_name,
        FORMAT_DATE('%b', DATE(CONCAT(EXTRACT(YEAR  FROM order_date), '-', EXTRACT(MONTH FROM order_date), '-01'))) AS month_abbrev,
        LPAD(CAST(EXTRACT(ISOWEEK FROM order_date) AS STRING), 2, '0') AS week_number
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
         store_name,
         store_city, 
         store_state
  FROM  {{ ref('stg_src_local_bike_stores') }}

),
------------------------------------------
map AS (

  SELECT  
         store_id,
         city, 
         state,
         latitude as store_latitude,
         longitude as store_longitude
  FROM  {{ ref('map') }}

),
------------------------------------------
seasons AS (

  SELECT  
         season_name,
         start_month_day,
         EXTRACT(YEAR  FROM start_month_day) || '-' || LPAD(CAST( EXTRACT(MONTH FROM start_month_day) AS STRING), 2, '0')  AS season_yearmonth,
         end_month_day
  FROM  {{ ref('seasons') }}

),
------------------------------------------
line_sales AS (

  SELECT
    o.order_date,
    o.yeardate,
    o.monthday,
    CASE 
        WHEN o.order_date between se.start_month_day and se.end_month_day THEN se.season_name
        --WHEN order_date between o.yeardate ||'-'||se.start_month_day and o.yeardate ||'-'||se.end_month_day THEN se.season_name
    END as season_name,
    o.yearmonth,
    o.month_2digits,
    o.month_name,
    o.month_abbrev,
    o.week_number,
    o.store_id,
    m.store_latitude,
    m.store_longitude,
    i.total_item_discount_sold AS net_amount
  FROM orders_date o
  LEFT JOIN items_sold as i on o.order_id = i.order_id
  LEFT JOIN map as m on o.store_id = m.store_id
  LEFT JOIN seasons se on se.season_yearmonth = o.yearmonth

)
------------------------------------------ 
SELECT
    ls.order_date,
    ls.yeardate,
    ls.monthday,
    ls.season_name,
    ls.yearmonth,
    ls.month_2digits,
    ls.month_name,
    ls.month_abbrev,
    ls.week_number,
    ls.store_id,
    s.store_name,
    ls.store_latitude,
    ls.store_longitude,    
    s.store_city,
    s.store_state,
    COUNT(DISTINCT ls.store_id || '_' || ls.order_date) AS nb_order_day,
    ROUND( SUM(ls.net_amount), 2) AS total_sales_amount,
    COUNT(*) AS total_items
FROM line_sales ls
LEFT JOIN stores as s on s.store_id = ls.store_id
GROUP BY ls.order_date, ls.yeardate, ls.yearmonth, ls.week_number, ls.month_2digits, ls.month_name, ls.monthday, 
         ls.season_name,ls.month_abbrev,ls.store_id, s.store_name, s.store_city, s.store_state, ls.store_latitude, ls.store_longitude
ORDER BY ls.yeardate, ls.week_number, ls.store_id