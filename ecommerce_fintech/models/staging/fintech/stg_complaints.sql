with stg_complaints as (
    select * from {{ source('raw_fintech', 'COMPLAINTS') }}
),

cleaned as (
    select
        complaint_id,
        customer_id,
        order_id,
        complaint_type,
        severity,
        description,
        status,
        resolution,
        response_time_hours,
        satisfaction_rating,
        assigned_to,
        created_at,
        resolved_at,
        case
            when severity = 'low' then 1
            when severity = 'medium' then 2
            when severity = 'high' then 3
            when severity = 'critical' then 4
        end as severity_rank,
        status in ('resolved', 'closed') as is_resolved,
        datediff(hour, created_at, resolved_at) as computed_response_time_hours,
        response_time_hours
        != datediff(hour, created_at, resolved_at) as response_time_mismatch

    from stg_complaints
)

select * from cleaned
