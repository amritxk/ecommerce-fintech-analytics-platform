with stg_events as (
select * from {{ source('raw_operations', 'EVENTS') }}
),

cleaned as (
select 
EVENT_ID,
EVENT_TIMESTAMP,
USER_ID,
SESSION_ID,
EVENT_TYPE,
PRODUCT_ID,
EVENT_VALUE,
EVENT_METADATA,
event_metadata:device::STRING AS device,
event_metadata:browser::STRING AS browser,
event_metadata:location:country::STRING AS country,
event_metadata:location:region::STRING AS region,
event_metadata:utm_params:source::STRING AS utm_source,
event_metadata:utm_params:medium::STRING AS utm_medium,
event_metadata:utm_params:campaign::STRING AS utm_campaign,
_LOADED_AT
from stg_events
QUALIFY ROW_NUMBER() OVER(PARTITION by EVENT_ID order by _LOADED_AT desc )=1
)
select * from cleaned
