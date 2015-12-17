select aa. *,
(
    select user_name, 
    case
        when user_name like '%BTJ%' then 'BATUJAJAR'
        when user_name like '%LPG%' then 'LAMPUNG'
    end AS plant
    from fnd_user
) as plant
from fnd_user aa
where aa.LAST_LOGON_DATE is null
and aa.USER_NAME 
