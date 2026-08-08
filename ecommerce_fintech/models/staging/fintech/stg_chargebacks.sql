with stg_chargebacks as (
    select * from {{ source('raw_fintech', 'CHARGEBACKS') }}
),

cleaned as (
select 
CHARGEBACK_ID,
TRANSACTION_ID,
ORDER_ID,
CUSTOMER_ID,
DISPUTE_REASON,
AMOUNT,
CHARGEBACK_STATUS,
chargeback_status in ('new', 'investigation')  as IS_OPEN,
FILED_DATE,
RESOLUTION_DATE,
(DATEDIFF ('day',FILED_DATE,RESOLUTION_DATE),0) as DAYS_to_RESOLVE,
EVIDENCE_PROVIDED,
CREATED_AT
from stg_chargebacks

)

select * from cleaned