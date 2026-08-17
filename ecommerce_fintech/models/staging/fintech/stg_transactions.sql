with stg_transactions as (
    select * from {{ source('raw_fintech', 'TRANSACTIONS') }}
),

cleaned  as (
select 
TRANSACTION_ID,
ORDER_ID,
CUSTOMER_ID,
TRANSACTION_TYPE,
AMOUNT,
CURRENCY,
STATUS,
PAYMENT_METHOD,
CARD_LAST_4,
GATEWAY_RESPONSE,
AUTHORIZATION_CODE,
MERCHANT_FEE,
CREATED_AT,
UPDATED_AT,
_LOADED_AT
from stg_transactions
QUALIFY (ROW_NUMBER() over (PARTITION BY TRANSACTION_ID order by  _LOADED_AT desc))=1
)

select * from cleaned