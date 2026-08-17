{% set field =['city','country','state','street','zip'] %}

with stg_order as (
    select * from {{ source('raw_ecommerce', 'ORDERS') }}
),

cleaned as (
    select
        order_id,
        customer_id,
        order_timestamp,
        order_status,
        subtotal_amount,
        discount_amount,
        discount_code,
        tax_amount,
        total_amount,
        shipping_address,
        {% for col in field %}
            shipping_address:{{ col }}::string as {{ col }},
        {% endfor %}
{# SHIPPING_ADDRESS:city::string as CITY,
SHIPPING_ADDRESS:country::string as COUNTRY,

SHIPPING_ADDRESS:state::string as STATE,
SHIPPING_ADDRESS:street::string as STREET,
SHIPPING_ADDRESS:zip::string as ZIP, #}
        payment_method,
        fulfillment_warehouse,
        created_at,
        updated_at,
        _snapshot_date
    from stg_order
)

select * from cleaned
