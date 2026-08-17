with stg_promotions as 
(
    select * from {{source('raw_ecommerce','PROMOTIONS')}}
),

cleaned as (
select 
PROMOTION_ID,
PROMO_CODE,
PROMO_TYPE,
DISCOUNT_VALUE,
DISCOUNT_CAP,
ELIGIBLE_PRODUCT_IDS,
ELIGIBLE_CUSTOMER_SEGMENT,
MIN_PURCHASE_AMOUNT,
USAGE_LIMIT,
CURRENT_USAGE,
(CURRENT_USAGE / nullif(USAGE_LIMIT,0) )*100
 as USAGE_RATE,
START_DATE,
END_DATE,
CASE WHEN CURRENT_DATE() Between START_DATE and END_DATE then 'active' else 'inactive' end as ACTUALL_VALID_STATUS,
STATUS,
CREATED_AT
    from stg_promotions

)
select * from cleaned