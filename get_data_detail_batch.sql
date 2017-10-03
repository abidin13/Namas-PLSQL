/*get data batch */
select batch_id from gme_batch_header bh, mtl_parameters mp
where batch_no = 'YYYYYY'
and organization_code = 'ZZZ'
and bh.organization_id = mp.organization_id;




/*Query 1 - Header*/

select batch_id, batch_no, bh.organization_id, organization_code, batch_type, batch_status, recipe_validity_rule_id, formula_id, routing_id, to_char (plan_start_date, 'DD-MON-YYYY HH24:MI:SS') as plan_start_date, to_char(actual_start_date, 'DD-MON-YYYY HH24:MI:SS') as actual_start_date, to_char (plan_cmplt_date, 'DD-MON-YYYY HH24:MI:SS') as plan_cmplt_date, to_char (actual_cmplt_date, 'DD-MON-YYYY HH24:MI:SS') as actual_cmplt_date, to_char (due_date, 'DD-MON-YYYY HH24:MI:SS') as due_date, to_char (batch_close_date, 'DD-MON-YYYY HH24:MI:SS') as batch_close_date, actual_cost_ind, update_inventory_ind, to_char (bh.last_update_date, 'DD-MON-YYYY HH24:MI:SS') as last_update_date, bh.last_updated_by, to_char (bh.creation_date, 'DD-MON-YYYY HH24:MI:SS') as creation_date, bh.created_by, bh.last_update_login, bh.delete_mark, text_code, parentline_id, fpo_id, automatic_step_calculation, gl_posted_ind, firmed_ind, finite_scheduled_ind, order_priority, migrated_batch_ind, enforce_step_dependency, terminated_ind, enhanced_pi_ind, laboratory_ind, move_order_header_id, terminate_reason_id
FROM gme_batch_header bh, mtl_parameters p
WHERE batch_id in (:batch_id)
AND bh.organization_id = p.organization_id;

/*Query 2 - Material Details*/

select md.batch_id, batch_no, line_type, line_no, material_detail_id, md.inventory_item_id, segment1 as item_number, plan_qty, actual_qty, wip_plan_qty, dtl_um, release_type, md.phantom_id, md.subinventory, md.locator_id, material_requirement_date, md.move_order_line_id, original_qty, original_primary_qty, cost_alloc, scrap_factor, scale_type, contribute_yield_ind, contribute_step_qty_ind, to_char (md.creation_date, 'DD-MON-YYYY HH24:MI:SS') as creation_date, to_char (md.last_update_date, 'DD-MON-YYYY HH24:MI:SS') as last_update_date, formulaline_id
FROM gme_material_details md, mtl_system_items_b i, gme_batch_header bh
WHERE md.batch_id IN (:batch_id)
AND md.batch_id = bh.batch_id
AND md.inventory_item_id = i.inventory_item_id
AND bh.organization_id = i.organization_id
ORDER BY batch_id, line_type, material_detail_id;

/*Query 3 - Transactions, Reservations, Pending Product Lots*/

SELECT 'MMT' as table_name, t.transaction_id as trans_or_rsrv_id, ty.transaction_type_name,
h.batch_status, d.batch_id as batch_id, t.transaction_source_id as trans_or_rsrv_source_id,
d.line_type, t.trx_source_line_id as material_detail_id, t.organization_id,
pa.organization_code, t.inventory_item_id, i.segment1 as item_number,
t.subinventory_code, t.locator_id, lt.lot_number as lot_number, t.primary_quantity, i.primary_uom_code,
t.transaction_quantity as trans_or_rsrv_qty, lt.transaction_quantity as lot_trans_qty,
t.transaction_uom as trans_or_rsrv_uom, t.secondary_transaction_quantity as sec_qty,
t.secondary_uom_code, lt.primary_quantity as lot_primary_qty, to_char(t.transaction_date, 'DD-MON-YYYY HH24:MI:SS') as trans_or_rsrv_date,
t.LPN_ID,
t.TRANSFER_LPN_ID, t.transaction_mode, NULL as lock_flag, NULL as process_flag,
to_char(t.creation_date, 'DD-MON-YYYY HH24:MI:SS') as creation_date,
to_char(t.last_update_date, 'DD-MON-YYYY HH24:MI:SS') as last_update_date, opm_costed_flag
FROM mtl_material_transactions t, gme_material_details d, gme_batch_header h,
mtl_transaction_lot_numbers lt, mtl_lot_numbers lot, mtl_system_items_b i,
mtl_transaction_types ty, mtl_parameters pa
WHERE t.transaction_source_type_id = 5
AND h.batch_id in (:batch_id)
AND t.transaction_source_id = h.batch_id
AND t.organization_id = h.organization_id
AND d.batch_id = h.batch_id
AND d.material_detail_id = t.trx_source_line_id
AND lt.transaction_id(+) = t.transaction_id -- This join allows us to get the lot number
AND lot.lot_number(+) = lt.lot_number -- This join allows us to get lot specific info if needed.
AND lot.organization_id(+) = lt.organization_id
AND lot.inventory_item_id(+) = lt.inventory_item_id
AND t.organization_id = i.organization_id
AND t.inventory_item_id = i.inventory_item_id
AND t.transaction_type_id = ty.transaction_type_id
And t.organization_id = pa.organization_id
UNION ALL
SELECT 'RSRV' as table_name, reservation_id as trans_or_rsrv_id , NULL, h.batch_status,
d.batch_id as batch_id,
demand_source_header_id as trans_or_rsrv_source_id, d.line_type,
demand_source_line_id as material_detail_id,
r.organization_id, pa.organization_code, r.inventory_item_id, i.segment1 as item_number,
r.subinventory_code, r.locator_id, r.lot_number,
primary_reservation_quantity, i.primary_uom_code, reservation_quantity as trans_or_rsrv_qty, NULL,
reservation_uom_code as trans_or_rsrv_uom, secondary_reservation_quantity as sec_qty,
r.secondary_uom_code, NULL, to_char(requirement_date, 'DD-MON-YYYY HH24:MI:SS') as trans_or_rsrv_date,
LPN_ID, NULL, NULL, NULL, NULL, to_char(r.creation_date, 'DD-MON-YYYY HH24:MI:SS') as creation_date,
to_char(r.last_update_date, 'DD-MON-YYYY HH24:MI:SS') as last_update_date, NULL
FROM mtl_reservations r, gme_material_details d, gme_batch_header h, mtl_system_items_b i,
mtl_parameters pa
WHERE demand_source_type_id = 5
AND h.batch_id in (:batch_id)
AND demand_source_header_id = h.batch_id
AND r.organization_id = h.organization_id
AND d.batch_id = h.batch_id
AND d.material_detail_id = demand_source_line_id
AND r.organization_id = i.organization_id
AND r.inventory_item_id = i.inventory_item_id
And r.organization_id = pa.organization_id
UNION ALL
SELECT 'PPL' as table_name, pending_product_lot_id as trans_or_rsrv_id, NULL, h.batch_status,
d.batch_id as batch_id, NULL, d.line_type, d.material_detail_id, h.organization_id,
pa.organization_code, d.inventory_item_id, i.segment1 as item_number,
NULL, NULL, lot_number, NULL, NULL, quantity as trans_or_rsrv_qty, NULL, NULL,
secondary_quantity as sec_qty, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
to_char(p.creation_date, 'DD-MON-YYYY HH24:MI:SS') as creation_date,
to_char(p.last_update_date, 'DD-MON-YYYY HH24:MI:SS') as last_update_date, NULL
FROM gme_pending_product_lots p, gme_material_details d, gme_batch_header h,
mtl_system_items_b i, mtl_parameters pa
WHERE h.batch_id in (:batch_id)
AND p.batch_id = h.batch_id
AND d.batch_id = h.batch_id
AND d.material_detail_id = p.material_detail_id
AND h.organization_id = i.organization_id
AND d.inventory_item_id = i.inventory_item_id
And h.organization_id = pa.organization_id
UNION ALL
-- Note that there should not be any transactions in MMTT. If there are, they are usually "stuck" there and
-- need to be processed or deleted
SELECT 'MMTT' as table_name, t.TRANSACTION_TEMP_ID as trans_or_rsrv_id,
ty.transaction_type_name, h.batch_status, d.batch_id as batch_id,
t.transaction_source_id as trans_or_rsrv_source_id, d.line_type,
t.trx_source_line_id as material_detail_id, t.organization_id,
pa.organization_code, t.inventory_item_id, i.segment1 as item_number,
t.subinventory_code, t.locator_id, lt.lot_number as lot_number, t.primary_quantity, i.primary_uom_code,
t.transaction_quantity as trans_or_rsrv_qty, lt.transaction_quantity as lot_trans_qty,
t.transaction_uom as trans_or_rsrv_uom, t.secondary_transaction_quantity as sec_qty,
t.secondary_uom_code, lt.primary_quantity as lot_primary_qty, to_char(t.transaction_date, 'DD-MON-YYYY HH24:MI:SS') as trans_or_rsrv_date,
t.LPN_ID, t.TRANSFER_LPN_ID, t.transaction_mode, t.lock_flag, t.process_flag,
to_char(t.creation_date, 'DD-MON-YYYY HH24:MI:SS') as creation_date,
to_char(t.last_update_date, 'DD-MON-YYYY HH24:MI:SS') as last_update_date, NULL
FROM mtl_material_transactions_temp t, gme_material_details d, gme_batch_header h,
mtl_transaction_lots_temp lt, mtl_system_items_b i, mtl_transaction_types ty,
mtl_parameters pa --mtl_lot_numbers lot
WHERE t.transaction_source_type_id = 5
AND h.batch_id in (:batch_id)
AND transaction_source_id = h.batch_id
AND t.organization_id = h.organization_id
AND d.batch_id = h.batch_id
AND d.material_detail_id = trx_source_line_id
AND lt.TRANSACTION_TEMP_ID (+) = t.TRANSACTION_TEMP_ID -- This join allows us to get the lot number
--AND lot.lot_number(+) = lt.lot_number
--AND t.organization_id = lot.organization_id
AND t.organization_id = i.organization_id
AND t.inventory_item_id = i.inventory_item_id
AND t.transaction_type_id = ty.transaction_type_id
And t.organization_id = pa.organization_id
UNION ALL
SELECT 'MTI' as table_name, t.TRANSACTION_INTERFACE_ID as trans_or_rsrv_id,
ty.transaction_type_name, h.batch_status, d.batch_id as batch_id,
t.transaction_source_id as trans_or_rsrv_source_id, d.line_type,
t.trx_source_line_id as material_detail_id, t.organization_id, pa.organization_code,
t.inventory_item_id, i.segment1 as item_number,
t.subinventory_code, t.locator_id, lt.lot_number as lot_number, t.primary_quantity, i.primary_uom_code,
t.transaction_quantity as trans_or_rsrv_qty, lt.transaction_quantity as lot_trans_qty,
t.transaction_uom as trans_or_rsrv_uom, t.secondary_transaction_quantity as sec_qty,
t.secondary_uom_code, lt.primary_quantity as lot_primary_qty, to_char(t.transaction_date, 'DD-MON-YYYY HH24:MI:SS') as trans_or_rsrv_date,
t.LPN_ID, t.TRANSFER_LPN_ID, t.transaction_mode, to_char(t.lock_flag), to_char(t.process_flag) ,
to_char(t.creation_date, 'DD-MON-YYYY HH24:MI:SS') as creation_date,
to_char(t.last_update_date, 'DD-MON-YYYY HH24:MI:SS') as last_update_date, NULL
FROM mtl_transactions_interface t, gme_material_details d, gme_batch_header h,
mtl_transaction_lots_interface lt, mtl_system_items_b i, mtl_transaction_types ty,
mtl_parameters pa --mtl_lot_numbers lot
WHERE t.transaction_source_type_id = 5
AND h.batch_id in (:batch_id)
AND transaction_source_id = h.batch_id
AND t.organization_id = h.organization_id
AND d.batch_id = h.batch_id
AND d.material_detail_id = trx_source_line_id
AND lt.TRANSACTION_INTERFACE_ID (+) = t.TRANSACTION_INTERFACE_ID -- This join allows us to get the lot number
--AND lot.lot_number(+) = lt.lot_number
--AND t.organization_id = lot.organization_id
AND t.organization_id = i.organization_id
AND t.inventory_item_id = i.inventory_item_id
AND t.transaction_type_id = ty.transaction_type_id
And t.organization_id = pa.organization_id
ORDER BY batch_id, table_name, line_type, material_detail_id, trans_or_rsrv_id;


/*Query 4 - Transaction Pairs*/

SELECT *
FROM gme_transaction_pairs
WHERE batch_id in (:batch_id);

 

/*Query 5 - Batch Steps*/

SELECT batch_id, batchstep_no, batchstep_id, step_status, gbt.oprn_id, oprn_no, oprn_vers, plan_step_qty, actual_step_qty, step_qty_um, to_char(plan_start_date, 'DD-MON-YYYY HH24:MI:SS') as plan_start_date, to_char(actual_start_date, 'DD-MON-YYYY HH24:MI:SS') as actual_start_date, to_char(plan_cmplt_date, 'DD-MON-YYYY HH24:MI:SS') as plan_cmplt_date, to_char(actual_cmplt_date, 'DD-MON-YYYY HH24:MI:SS') as actual_cmplt_date, steprelease_type, max_step_capacity, max_step_capacity_um, plan_charges, actual_charges, quality_status, routingstep_id
FROM gme_batch_steps gbt, gmd_operations_b gob
WHERE batch_id in (:batch_id)
And gbt.oprn_id = gob.oprn_id
ORDER BY batch_id, batchstep_no;

 

/*Query 6 - Batch Step Activities*/

SELECT batch_id, batchstep_id, batchstep_activity_id, activity, offset_interval, to_char(plan_start_date, 'DD-MON-YYYY HH24:MI:SS') as plan_start_date, to_char(actual_start_date, 'DD-MON-YYYY HH24:MI:SS') as actual_start_date, to_char(plan_cmplt_date, 'DD-MON-YYYY HH24:MI:SS') as plan_cmplt_date, to_char(actual_cmplt_date, 'DD-MON-YYYY HH24:MI:SS') as actual_cmplt_date, plan_activity_factor, actual_activity_factor, oprn_line_id
FROM gme_batch_step_activities
WHERE batch_id in (:batch_id)
ORDER BY batch_id, batchstep_id, batchstep_activity_id;

 

/*Query 7 - Batch Step Resources*/

SELECT batch_id, batchstep_id, batchstep_activity_id, batchstep_resource_id, resources, scale_type, plan_rsrc_count, actual_rsrc_count, plan_rsrc_usage, actual_rsrc_usage, usage_um, plan_rsrc_qty, actual_rsrc_qty, resource_qty_um, to_char(plan_start_date, 'DD-MON-YYYY HH24:MI:SS') as plan_start_date, to_char(actual_start_date, 'DD-MON-YYYY HH24:MI:SS') as actual_start_date, to_char(plan_cmplt_date, 'DD-MON-YYYY HH24:MI:SS') as plan_cmplt_date, to_char(actual_cmplt_date, 'DD-MON-YYYY HH24:MI:SS') as actual_cmplt_date, offset_interval, min_capacity, max_capacity, capacity_um, calculate_charges, prim_rsrc_ind
FROM gme_batch_step_resources
WHERE batch_id in (:batch_id)
ORDER BY batch_id, batchstep_id, batchstep_activity_id, batchstep_resource_id;

 

/*Query 8 - Resource Transactions*/

SELECT doc_id as batch_id, line_id as batchstep_resource_id, poc_trans_id, resources, resource_usage, trans_qty_um, to_char(trans_date, 'DD-MON-YYYY HH24:MI:SS') as trans_date, to_char(start_date, 'DD-MON-YYYY HH24:MI:SS') as start_date, to_char(end_date, 'DD-MON-YYYY HH24:MI:SS') as end_date, completed_ind, posted_ind, overrided_protected_ind, reverse_id, delete_mark
FROM gme_resource_txns
WHERE doc_id in (:batch_id)
ORDER BY doc_id, line_id, poc_trans_id;

 

/*Query 9 - Recipe Details*/

	select r.*
	  from gme_batch_header b
	      ,gmd_recipes r
	      ,gmd_recipe_validity_rules vr
	    where b.batch_id= &&batch_id
	      and b.recipe_validity_rule_id=vr.recipe_validity_rule_id
	      and vr.recipe_id=r.recipe_id;

 

/*Query 10 - Recipe Validity Rules*/

select vr.*
  from gme_batch_header b
      ,gmd_recipes r
      ,gmd_recipe_validity_rules vr
    where b.batch_id= &&batch_id
      and b.recipe_validity_rule_id=vr.recipe_validity_rule_id
      and vr.recipe_id=r.recipe_id;

 

/*Query 11 - Yield Layers*/

SELECT *
FROM gmf_incoming_material_layers il
WHERE (il.mmt_organization_id, il.mmt_transaction_id) IN
    (SELECT DISTINCT t.organization_id, t.transaction_id
     FROM mtl_material_transactions t
     WHERE t.transaction_source_id = &&batch_id
     AND   t.transaction_source_type_id = 5);

 

/*Query 12 - Material Consumption Layers*/

SELECT *
FROM gmf_outgoing_material_layers ol
WHERE (ol.mmt_organization_id, ol.mmt_transaction_id) IN
    (SELECT DISTINCT t.organization_id, t.transaction_id
     FROM mtl_material_transactions t
     WHERE t.transaction_source_id = &&batch_id
     AND   t.transaction_source_type_id = 5);

 

/*Query 13 - Resource Consumption Layers*/

SELECT *
FROM gmf_resource_layers il
WHERE il.poc_trans_id IN
    (SELECT t.poc_trans_id
    FROM gme_resource_txns t
    WHERE t.doc_id = &&batch_id
    AND   t.doc_type = 'PROD');

 

/*Query 14 - VIB Details*/

SELECT *
FROM gmf_batch_vib_details bvd
WHERE bvd.requirement_id IN
    (SELECT br.requirement_id
    FROM gmf_batch_requirements br
    WHERE br.batch_id = &&batch_id);

 

/*Query 15 - Batch Requirement Details*/

SELECT *
FROM gmf_batch_requirements br
WHERE br.batch_id = &&batch_id;

 

/*Query 16 - Layer Cost Details*/
SELECT *
FROM gmf_layer_cost_details c
WHERE
     c.layer_id IN
    (SELECT il.layer_id
    FROM gme_batch_header h, mtl_material_transactions t, gmf_incoming_material_layers il
    WHERE h.batch_id = &&batch_id
    AND    h.batch_id = t.transaction_source_id
    AND    t.transaction_source_type_id = 5
    AND    il.mmt_transaction_id           = t.transaction_id
        AND    il.mmt_organization_id          = t.organization_id
    );

 

/*Query 17 - Extract Header Details*/

select geh.*
from gmf.gmf_xla_extract_headers geh                
where geh.entity_code = 'PRODUCTION'
and source_document_id = &&batch_id
and txn_source = 'PM';

 

/*Query 18 - Extract Lines Details*/

select gel.*
from gmf.gmf_xla_extract_lines gel                 
where gel.header_id in
    (
    select geh.header_id
    from gmf.gmf_xla_extract_headers geh                
    where geh.entity_code = 'PRODUCTION'
    and source_document_id = &&batch_id
    and txn_source = 'PM');

 

/*Query 19 - SLA Events*/

select xe.*
from xla.xla_events xe            
WHERE XE.EVENT_ID IN
    (Select event_id from gmf_xla_extract_headers where source_document_id = &batch_id
and txn_source = 'PM');

 

/*Query 20 - SLA Distribution Links*/

select xte.*
from xla_transaction_entities_upg xte
where xte.application_id = 555
and xte.entity_id in (select xe.entity_id
               from xla.xla_events xe            
                      WHERE XE.EVENT_ID IN (select EVENT_ID
                                        from GMF_XLA_EXTRACT_HEADERS
                                       where SOURCE_DOCUMENT_ID = &batch_id
                           and txn_source = 'PM'
                        )
             );

 

/*Query 21 - SLA Headers*/

SELECT * FROM XLA_AE_HEADERS
where application_id = 555 and event_id IN ( Select event_id from gmf_xla_extract_headers where source_document_id =&batch_id
and txn_source = 'PM');

 

/*Query 22 - SLA Lines*/

SELECT * FROM xla_ae_lines where ae_header_id IN ( SELECT ae_header_id
FROM xla_ae_headers where application_id = 555 and event_id IN
( Select event_id from gmf_xla_extract_headers where source_document_id =&batch_id
and txn_source = 'PM'));

 

/*Query 23 - Item Component Class Details*/

select a.*
from gl_item_dtl a
where a.itemcost_id
in (select itemcost_id
    from gl_item_cst
    where (inventory_item_id, organization_id,cost_type_id, period_id)
    IN (select distinct mmt.inventory_item_id, mmt.organization_id,gps.cost_type_id,gps.period_id
        from gmf_organization_definitions god,
             gmf_period_statuses gps,
             gmf_fiscal_policies gfp,
             cm_mthd_mst mthd,
             mtl_material_transactions mmt
        WHERE mmt.transaction_source_type_id     = 5
              AND god.organization_id            = mmt.organization_id
              AND mmt.transaction_source_id      = &&batch_id
              AND gfp.legal_entity_id            = god.legal_entity_id
              AND mthd.cost_type_id              = gfp.cost_type_id
              AND gps.legal_entity_id            = gfp.legal_entity_id
              AND gps.cost_type_id               = gfp.cost_type_id
              AND mmt.transaction_date           >= gps.start_date
              AND mmt.transaction_date           <= gps.end_date));