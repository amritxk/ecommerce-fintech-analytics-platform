with customers as (

    select * from {{ ref('stg_customers') }}

)

select
    customer_id,
    email,
    first_name,
    last_name,
    kyc_status,
    account_status,
    customer_segment
from customers
