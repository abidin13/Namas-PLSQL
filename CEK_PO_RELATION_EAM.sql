Select WE.WIP_ENTITY_ID,WE.WIP_ENTITY_NAME,WE.ENTITY_TYPE, WDJ.STATUS_TYPE
From WIP_ENTITIES WE, WIP_DISCRETE_JOBS WDJ
Where WE.WIP_ENTITY_ID = WDJ.WIP_ENTITY_ID
And WE.WIP_ENTITY_ID in (
select wip_entity_id from po_distributions_all 
where po_header_id in (
    select po_header_id from po_headers_all
    where segment1 = '16101300541'
)
)