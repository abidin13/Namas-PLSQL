 SELECT WE.wip_entity_name, WDJ.scheduled_completion_date
  FROM wip_discrete_jobs WDJ, wip_entities WE
  WHERE WDJ.organization_id = &p_org_id
  --AND WDJ.scheduled_completion_date 
  AND WDJ.status_type = 3
  AND WDJ.wip_entity_id = WE.wip_entity_id
  AND WDJ.organization_id = WE.organization_id
  AND WE.entity_type = 6
  
  order by WDJ.scheduled_completion_date asc 


  /* detail */
   SELECT WE.wip_entity_name, WDJ.scheduled_completion_date
  FROM wip_discrete_jobs WDJ, wip_entities WE
  WHERE WDJ.organization_id = &p_org_id
  AND WDJ.scheduled_completion_date  BETWEEN TRUNC(TO_DATE (:BULAN_AWAL||'-01', 'MM/RRRR/DD HH24:MI:SS'))
                        AND  last_day(TRUNC(TO_DATE (:BULAN_AKHIR||'-01', 'MM/RRRR/DD HH24:MI:SS')))
  AND WDJ.status_type = 3
  AND WDJ.wip_entity_id = WE.wip_entity_id
  AND WDJ.organization_id = WE.organization_id
  AND WE.entity_type = 6
  
  order by WDJ.scheduled_completion_date asc 