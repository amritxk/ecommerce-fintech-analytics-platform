with stg_products as (
    select * from {{ source('raw_ecommerce', 'PRODUCTS') }}
),

cleaned as (
    select
        product_id,
        product_name,
        description,
        list_price,
        cost,
        current_price,
        inventory_count,
        supplier_id,
        weight,
        is_active,
        created_at,
        updated_at,
        _snapshot_date,
        lower(trim(category)) as category,
        lower(trim(subcategory)) as subcategory,
        (current_price - cost) as margin
    from stg_products
)

select * from cleaned
