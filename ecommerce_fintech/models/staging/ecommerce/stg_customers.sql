with stg_customers as (
    select * from {{ source('raw_ecommerce', 'CUSTOMERS') }}
),

cleaned as (
    select
        customer_id,
        phone,
        first_name,
        last_name,
        date_of_birth,
        country,
        kyc_status,
        kyc_verified_date,
        customer_segment,
        lifetime_purchases,
        account_status,
        last_purchase_date,
        preferred_currency,
        created_at,
        _snapshot_date,
        LOWER(TRIM(email)) as email,
        case
            when kyc_status = 'approved' then 'Yes'
            else 'No'
        end as kyc_status_yesno,
        case
            when account_status = 'active' then 'Yes'
            else 'No'
        end as account_status_yesno

    from stg_customers
)

select * from cleaned
