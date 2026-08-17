with stg_chargebacks as (
    select * from {{ source('raw_fintech', 'CHARGEBACKS') }}
),

cleaned as (
    select
        chargeback_id,
        transaction_id,
        order_id,
        customer_id,
        dispute_reason,
        amount,
        chargeback_status,
        filed_date,
        resolution_date,
        evidence_provided,
        created_at,
        chargeback_status in ('new', 'investigation') as is_open,
        (DATEDIFF('day', filed_date, resolution_date), 0) as days_to_resolve
    from stg_chargebacks

)

select * from cleaned
