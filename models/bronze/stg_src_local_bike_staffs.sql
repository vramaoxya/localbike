select
    staff_id as staff_id,
    INITCAP(first_name) as staff_first_name,
    INITCAP(last_name) as staff_last_name,
    phone as staff_phone,
    email as staff_email,
    active as staff_active,
    store_id as store_id,
    manager_id as manager_id
from {{ source("src_local_bike", "staffs") }}        