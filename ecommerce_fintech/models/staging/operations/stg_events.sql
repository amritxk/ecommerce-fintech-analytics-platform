with stg_events as (
    select * from {{ source('raw_operations', 'EVENTS') }}
),

cleaned as (
    select
        event_id,
        event_timestamp,
        user_id,
        session_id,
        event_type,
        product_id,
        event_value,
        event_metadata,
        event_metadata:device::STRING as device,
        event_metadata:browser::STRING as browser,
        event_metadata:location:country::STRING as country,
        event_metadata:location:region::STRING as region,
        event_metadata:utm_params:source::STRING as utm_source,
        event_metadata:utm_params:medium::STRING as utm_medium,
        event_metadata:utm_params:campaign::STRING as utm_campaign,
        _loaded_at
    from stg_events
    qualify
        ROW_NUMBER() over (partition by event_id order by _loaded_at desc) = 1
)

select * from cleaned
