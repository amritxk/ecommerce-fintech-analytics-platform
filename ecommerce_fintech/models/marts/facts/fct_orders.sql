{{
  config(
    materialized = 'incremental',
    incremental_strategy = 'merge',
    unique_key='order_id'

    )
}}


{% if is_incremental() %}
    {% set max_updated_query %}
        select max(updated_at) from {{ this }}
    {% endset %}
    {% set max_updated_at = run_query(max_updated_query).columns[0].values()[0] %}
{% endif %}

with orders as (

    select * from {{ ref('stg_orders') }}

    {% if is_incremental() %}
        where updated_at > '{{ max_updated_at }}'
    {% endif %}

),

order_items_agg as (

    select
        order_id,
        count(order_item_id) as total_items,
        sum(quantity) as total_quantity

    from {{ ref('stg_order_items') }}
    group by order_id

),

final as (

    select
        orders.order_id,
        orders.customer_id,
        orders.order_timestamp,
        orders.order_status,
        orders.subtotal_amount,
        orders.discount_amount,
        orders.tax_amount,
        orders.total_amount,
        orders.payment_method,
        orders.fulfillment_warehouse,
        order_items_agg.total_items,
        order_items_agg.total_quantity,
        orders.created_at,
        orders.updated_at

    from orders
    left join order_items_agg
        on orders.order_id = order_items_agg.order_id

)

select * from final
