with stg_customers as (
    select * from {{ source('raw_ecommerce', 'CUSTOMERS') }}
),

cleaned as
 (
Select  
CUSTOMER_ID,
LOWER(TRIM(EMAIL)) as EMAIL,
PHONE, 
FIRST_NAME,
LAST_NAME, 
DATE_OF_BIRTH, 
COUNTRY,
case when kyc_status = 'approved' then 'Yes'
             else 'No' end  as KYC_STATUS_YESNO ,
KYC_STATUS,
KYC_VERIFIED_DATE,
CUSTOMER_SEGMENT,
LIFETIME_PURCHASES,
ACCOUNT_STATUS,
case when account_status = 'active' then 'Yes'
             else 'No' end   as ACCOUNT_STATUS_YESNO, 
LAST_PURCHASE_DATE,
PREFERRED_CURRENCY, 
CREATED_AT,
_SNAPSHOT_DATE

from stg_customers
)

select * from cleaned