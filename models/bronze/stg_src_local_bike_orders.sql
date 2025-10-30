select
    order_id as order_id,
    customer_id as customer_id,
    order_status as order_status,
    DATETIME(order_date, "Europe/Paris") as order_date,
    DATETIME(required_date, "Europe/Paris") as required_date,
    DATETIME(shipped_date, "Europe/Paris") as shipped_date,
    store_id as store_id,
    staff_id as staff_id
from {{ source("src_local_bike", "orders") }}