select *
from {{ ref('int_order_session_attribution') }}
where (
        attribution_status = 'attributed'
        and converting_session_id is null
    )
    or (
        attribution_status = 'fallback'
        and converting_session_id is not null
    )
