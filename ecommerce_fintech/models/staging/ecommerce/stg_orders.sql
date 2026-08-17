{% set field =['city','country','state','street','zip'] %}

with stg_order as (
    select * from {{ source('raw_ecommerce', 'ORDERS') }}
),

cleaned as 
( select 
ORDER_ID,
CUSTOMER_ID,
ORDER_TIMESTAMP,
ORDER_STATUS,
SUBTOTAL_AMOUNT,
DISCOUNT_AMOUNT,
DISCOUNT_CODE,
TAX_AMOUNT,
TOTAL_AMOUNT,
SHIPPING_ADDRESS,
{% for col in field %}
SHIPPING_ADDRESS:{{col}}::string as {{col}},
{% endfor %}
{# SHIPPING_ADDRESS:city::string as CITY,
SHIPPING_ADDRESS:country::string as COUNTRY,

SHIPPING_ADDRESS:state::string as STATE,
SHIPPING_ADDRESS:street::string as STREET,
SHIPPING_ADDRESS:zip::string as ZIP, #}
PAYMENT_METHOD,
FULFILLMENT_WAREHOUSE,
CREATED_AT,
UPDATED_AT,
_SNAPSHOT_DATE
from stg_order
)

select * from cleaned




