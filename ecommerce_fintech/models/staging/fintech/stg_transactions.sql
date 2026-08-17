with stg_transactions as (
    select * from {{ source('raw_fintech', 'TRANSACTIONS') }}
),

cleaned as (
    select
        transaction_id,
        order_id,
        customer_id,
        transaction_type,
        amount,
        currency,
        status,
        payment_method,
        card_last_4,
        gateway_response,
        authorization_code,
        merchant_fee,
        created_at,
        updated_at,
        _loaded_at
    from stg_transactions
    qualify
        (
            ROW_NUMBER()
                over (partition by transaction_id order by _loaded_at desc)
        )
        = 1
)

select * from cleaned
