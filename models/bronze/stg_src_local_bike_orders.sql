select
    order_id as order_id,
    customer_id as customer_id,
    order_status as order_status,
    order_date as order_date,
    required_date as required_date,
    shipped_date as shipped_date,
    store_id as store_id,
    staff_id as staff_id
from {{ source("src_local_bike", "orders") }}