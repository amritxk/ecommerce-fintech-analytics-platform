{% snapshot snp_products %}

{{
    config(
      target_database='MARTS_DB',
      target_schema='SCHEMA_DIMENSIONS',
      unique_key='product_id',
      strategy='check',
      check_cols=['current_price', 'category'],
    )
}}

select * from {{ source('raw_ecommerce', 'PRODUCTS') }}

{% endsnapshot %}