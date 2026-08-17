with stg_products as (
select * from {{ source('raw_ecommerce', 'PRODUCTS') }}
),

cleaned as (
    select 
    PRODUCT_ID,
PRODUCT_NAME,
lower(trim(CATEGORY)) as CATEGORY ,
lower(trim(SUBCATEGORY)) as SUBCATEGORY,
DESCRIPTION,
LIST_PRICE,
COST,
CURRENT_PRICE,
(CURRENT_PRICE-COST) as MARGIN,
INVENTORY_COUNT,
SUPPLIER_ID,
WEIGHT,
IS_ACTIVE,
CREATED_AT,
UPDATED_AT,
_SNAPSHOT_DATE
from stg_products
)

select * from cleaned