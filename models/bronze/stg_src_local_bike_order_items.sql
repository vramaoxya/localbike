SELECT
  order_id || '_' || item_id AS order_item_id,
  product_id as product_id,
  quantity as quantity,
  list_price as list_price,
  discount as discount,
  quantity * list_price * (1 - discount) AS total_item_sold
  --{{ calculate_total_order_item_amount('list_price','quantity','discount') }} AS total_item_sold
  --quantity * list_price * (1 - discount)
FROM {{ source("src_local_bike", "order_items") }}