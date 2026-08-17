with stg_reviews as (
select * from {{ source('raw_ecommerce', 'REVIEWS') }}
),

cleaned as (
select
REVIEW_ID,
PRODUCT_ID,
CUSTOMER_ID,
ORDER_ITEM_ID,
RATING_STARS,
REVIEW_TITLE,
REVIEW_TEXT,
SENTIMENT_SCORE,
case
when sentiment_score >= 0.3  then 'positive'
when sentiment_score <= -0.3 then 'negative'
else 'neutral'end as SENTIMENT_CATEGORY,
HELPFUL_COUNT,
UNHELPFUL_COUNT,
helpful_count / nullif(helpful_count + unhelpful_count, 0)  as HELPFULNESS_RATIO,
VERIFIED_PURCHASE,
REVIEW_STATUS ='approved' as IS_APPROVED,
MODERATED_BY,
CREATED_AT
from stg_reviews
)

select * from cleaned 