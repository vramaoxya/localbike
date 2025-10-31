------------------------------------------
WITH staff_list AS (
  SELECT
    s.staff_id,
    s.staff_first_name,
    s.staff_last_name,
    s.manager_id,
    s.path,
    s.level
  FROM {{ ref('int_src_local_bike_staff_hierarchy') }} s
),
------------------------------------------
sales_by_employer AS (
  SELECT
    o.order_date as order_date,
    EXTRACT(YEAR FROM o.order_date) as yeardate,
    EXTRACT(YEAR FROM o.order_date) || '-' || LPAD(CAST( EXTRACT(MONTH FROM o.order_date) AS STRING), 2, '0') AS yearmonth,
    LPAD(CAST( EXTRACT(MONTH FROM o.order_date) AS STRING), 2, '0') || '-' || LPAD(CAST( EXTRACT(DAY FROM o.order_date) AS STRING), 2, '0') AS monthday,
    LPAD(CAST( EXTRACT(MONTH FROM o.order_date) AS STRING), 2, '0') as month_2digits,
    FORMAT_DATE('%B', DATE(CONCAT(EXTRACT(YEAR FROM o.order_date), '-', EXTRACT(MONTH FROM o.order_date), '-01'))) AS month_name,
    FORMAT_DATE('%b', DATE(CONCAT(EXTRACT(YEAR FROM o.order_date), '-', EXTRACT(MONTH FROM o.order_date), '-01'))) AS month_abbrev,
    LPAD(CAST(EXTRACT(ISOWEEK FROM o.order_date) AS STRING), 2, '0') AS week_number,
    o.staff_id,
    oi.total_item_discount_sold as total_item_discount_sold
  FROM {{ ref('stg_src_local_bike_orders') }} as o
  LEFT JOIN {{ ref('stg_src_local_bike_order_items') }} as oi ON o.order_id = oi.order_id
)
------------------------------------------
SELECT 
    em.order_date,
    em.yeardate,
    em.monthday,
    em.yearmonth,
    em.month_2digits,
    em.month_name,
    em.month_abbrev,
    em.week_number,
    ROUND(em.total_item_discount_sold, 2) as total_item_sold_staff,
    s.*
FROM sales_by_employer as em 
JOIN staff_list as s ON em.staff_id = s.staff_id
ORDER BY em.order_date