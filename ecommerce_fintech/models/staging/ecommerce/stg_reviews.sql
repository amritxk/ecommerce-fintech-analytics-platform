with stg_reviews as (
    select * from {{ source('raw_ecommerce', 'REVIEWS') }}
),

cleaned as (
    select
        review_id,
        product_id,
        customer_id,
        order_item_id,
        rating_stars,
        review_title,
        review_text,
        sentiment_score,
        helpful_count,
        unhelpful_count,
        verified_purchase,
        moderated_by,
        created_at,
        case
            when sentiment_score >= 0.3 then 'positive'
            when sentiment_score <= -0.3 then 'negative'
            else 'neutral'
        end as sentiment_category,
        helpful_count
        / nullif(helpful_count + unhelpful_count, 0) as helpfulness_ratio,
        review_status = 'approved' as is_approved
    from stg_reviews
)

select * from cleaned
