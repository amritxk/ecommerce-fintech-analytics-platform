with stg_returns as (
    select * from {{ source('raw_fintech', 'RETURNS') }}
),

cleaned as (
    select
        return_id,
        order_id,
        order_item_id,
        customer_id,
        product_id,
        return_reason,
        return_status,
        refund_amount,
        restocking_fee,
        initiated_date,
        received_date,
        refund_date,
        tracking_number,
        created_at,
        return_status = 'refunded' as is_completed,
        refund_amount - restocking_fee as net_refund_amount,
        datediff(day, initiated_date, refund_date) as turnaround_days
    from stg_returns
)

select * from cleaned
