select
    store_id as store_id,
    store_name as store_name,
    phone as phone,
    email as email,
    street as street,
    city as city,
    state as state,
    zip_code as zip_code
from {{ source("src_local_bike", "stores") }}
