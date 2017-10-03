select * from (
select * from gme_batch_header vv
where TRUNC(VV.CREATION_DATE)BETWEEN TO_DATE(:TGL1, 'RRRR/MM/DD HH24:MI:SS') AND TO_DATE(:TGL2,'RRRR/MM/DD HH24:MI:SS')
and vv.ORGANIZATION_ID = :org_id
and batch_id in (
    select batch_id from gme_material_details b
where b.INVENTORY_ITEM_ID = 2098
AND b.BATCH_ID IN (
    select BATCH_ID from gme_batch_header vv
where TRUNC(VV.CREATION_DATE)BETWEEN TO_DATE(:TGL1, 'RRRR/MM/DD HH24:MI:SS') AND TO_DATE(:TGL2,'RRRR/MM/DD HH24:MI:SS')
and vv.ORGANIZATION_ID = :org_id
)
and b.ORGANIZATION_ID = :org_id 
)
)pp