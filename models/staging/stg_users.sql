with source as (
    select * from {{ ref('raw_users') }}
),

renamed as (
    select
        cast(user_id as varchar) as user_id,
        cast(created_at as timestamp) as user_created_at,
        upper(cast(country as varchar)) as country,
        lower(cast(acquisition_channel as varchar)) as acquisition_channel,
        lower(cast(lifecycle_stage as varchar)) as lifecycle_stage,
        cast(is_marketing_opted_in as boolean) as is_marketing_opted_in
    from source
)

select * from renamed
