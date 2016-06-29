SELECT
    h.batch_no, 
    im.concatenated_segments item_no,
    im.description item_desc1,
   d.revision,
    h.batch_id,
    h.wip_whse_code,
    h.formula_id ,
    h.actual_cmplt_date,
    h.recipe_validity_rule_id,
    rcp.recipe_no,
    rcp.RECIPE_DESCRIPTION,
    rcp.recipe_version,
    im.primary_uom_code item_um ,
    d.plan_qty pqty,
    d.actual_qty aqty,
    nvl((d.actual_qty - d.plan_qty),0)   as selisih,
    round(nvl((((d.actual_qty - d.plan_qty) / d.PLAN_QTY) * 100),0),5)   as selisihpct,
    d.dtl_um batchum,
    d.inventory_item_id ditemid,
    d.material_detail_id line_id,
                'U' var_type,
    fd.formulaline_id,
                fd.detail_uom formum
FROM
    gme_batch_header h,
    gme_material_details d,
    fm_form_mst f,
    fm_matl_dtl  fd,
    gmd_recipe_validity_rules val,
    gmd_recipes rcp,
    mtl_system_items_kfv im
WHERE
    (h.batch_status =  3  or h.batch_status =  4)
and     h.batch_type = 0    
and     d.batch_id= h.batch_id
and    h.recipe_validity_rule_id = val.recipe_validity_rule_id
and    val.recipe_id = rcp.recipe_id
--and     ( d.line_type = -1   )
and     f.formula_id= h.formula_id
and     f.formula_id= fd.formula_id    
and     im.organization_id = d.organization_id   
and     im.inventory_item_id = d.inventory_item_id
--and     fd.line_type=-1
and     d.formulaline_id = fd.formulaline_id
--and h.BATCH_NO = :CP_BatchRange
and rcp.RECIPE_NO = :recipe 
order by h.BATCH_NO asc
