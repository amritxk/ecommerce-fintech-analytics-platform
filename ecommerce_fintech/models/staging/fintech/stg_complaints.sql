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
        case
            when severity = 'low'      then 1
            when severity = 'medium'   then 2
            when severity = 'high'     then 3
            when severity = 'critical' then 4
        end                                                          as severity_rank,
        description,
        status,
        status in ('resolved', 'closed')                             as is_resolved,
        resolution,
        response_time_hours,
        datediff(hour, created_at, resolved_at)                      as computed_response_time_hours,
        response_time_hours != datediff(hour, created_at, resolved_at) as response_time_mismatch,
        satisfaction_rating,
        assigned_to,
        created_at,
        resolved_at

    from stg_complaints
)

select * from cleaned 
