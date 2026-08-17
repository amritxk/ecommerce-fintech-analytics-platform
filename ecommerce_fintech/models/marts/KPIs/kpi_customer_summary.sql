with order_summary as (

    select
        customer_id,
        count(order_id)   as total_orders,
        sum(total_amount) as lifetime_spend

    from {{ ref('fct_orders') }}
    group by customer_id

),

customers as (

    select customer_id from {{ ref('dim_customer') }}

),

final as (

    select
        customers.customer_id,
        coalesce(order_summary.total_orders, 0)   as total_orders,
        coalesce(order_summary.lifetime_spend, 0) as lifetime_spend

    from customers
    left join order_summary
        on customers.customer_id = order_summary.customer_id

)

select * from final