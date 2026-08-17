with stg_order_items as (
    select * from {{ source('raw_ecommerce', 'ORDER_ITEMS') }}
),

cleaned as (
    select
        order_item_id,
        order_id,
        product_id,
        quantity,
        unit_price,
        line_total,
        applied_promotions,
        restocking_fee,
        created_at,
        Round(line_total, 2) = Round((quantity * unit_price), 2)
            as data_validation_flag
    from stg_order_items

)

select * from cleaned
