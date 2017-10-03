select distinct inventory_item_id
FROM gme_material_details
WHERE batch_id IN (558332,558333,558362,558364);

select * from MTL_UOM_CLASS_CONVERSIONS
where inventory_item_id in
(select distinct inventory_item_id
FROM gme_material_details
WHERE batch_id IN (558332,558333,558362,558364));
