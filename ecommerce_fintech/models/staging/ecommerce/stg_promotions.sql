with stg_promotions as (
    select * from {{ source('raw_ecommerce','PROMOTIONS') }}
),

cleaned as (
    select
        promotion_id,
        promo_code,
        promo_type,
        discount_value,
        discount_cap,
        eligible_product_ids,
        eligible_customer_segment,
        min_purchase_amount,
        usage_limit,
        current_usage,
        start_date,
        end_date,
        status,
        created_at,
        (current_usage / nullif(usage_limit, 0)) * 100
            as usage_rate,
        case
            when
                current_date() between start_date and end_date
                then 'active'
            else 'inactive'
        end as actuall_valid_status
    from stg_promotions

)

select * from cleaned
