with stg_returns as (
select * from {{ source('raw_fintech', 'RETURNS') }}
),

cleaned as (
select 
RETURN_ID,
ORDER_ID,
ORDER_ITEM_ID,
CUSTOMER_ID,
PRODUCT_ID,
RETURN_REASON,
RETURN_STATUS,
return_status = 'refunded'  as IS_COMPLETED,
REFUND_AMOUNT,
RESTOCKING_FEE,
refund_amount - restocking_fee   as net_refund_amount,
INITIATED_DATE,
RECEIVED_DATE,
REFUND_DATE,
datediff(day, initiated_date, refund_date)         as turnaround_days,
TRACKING_NUMBER,
CREATED_AT
from stg_returns
)

select * from cleaned 