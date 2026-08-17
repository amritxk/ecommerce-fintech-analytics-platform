with stg_order_items as (
    select * from {{ source('raw_ecommerce', 'ORDER_ITEMS') }}
),

cleaned as (
select 
ORDER_ITEM_ID,
ORDER_ID,
PRODUCT_ID,
QUANTITY,
UNIT_PRICE,
LINE_TOTAL,
Round(LINE_TOTAL,2) = ROUND((QUANTITY*UNIT_PRICE),2)
as DATA_VALIDATION_FLAG,
APPLIED_PROMOTIONS,
RESTOCKING_FEE,
CREATED_AT
    from stg_order_items

)
select * from cleaned 