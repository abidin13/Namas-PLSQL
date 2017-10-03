select * from
(
SELECT a.wip_entity_name, a.creation_date,
       (select transaction_id from WIP_TRANSACTION_ACCOUNTS where wip_entity_id = a.wip_entity_id and organization_id = a.organization_id and rownum = 1) as  transaction_number,
       (select transaction_date from WIP_TRANSACTION_ACCOUNTS where wip_entity_id = a.wip_entity_id and organization_id = a.organization_id and rownum = 1) as  transaction_date,
       wo_status.meaning status
FROM wip_entities a, wip_discrete_jobs b,
     (SELECT lookup_code
               , meaning
            FROM apps.fnd_lookup_values_vl
           WHERE lookup_type = 'WIP_JOB_STATUS') wo_status
where a.organization_id = 103
and   a.wip_entity_id in (select wip_entity_id from WIP_REQUIREMENT_OPERATIONS where organization_id = a.organization_id)
and   a.wip_entity_id = b.wip_entity_id
and   a.organization_id = b.organization_id
AND   b.status_type = wo_status.lookup_code(+)
)pp
where TRUNC(pp.transaction_date) BETWEEN TO_DATE(:p_from_date,'RRRR/MM/DD HH24:MI:SS') AND TO_DATE(:p_to_date,'RRRR/MM/DD HH24:MI:SS')