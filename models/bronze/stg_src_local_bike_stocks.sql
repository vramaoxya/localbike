select
    store_id || '_' || product_id as store_product_id,
    quantity as stock_quantity
from {{ source('src_local_bike', 'stocks') }}
