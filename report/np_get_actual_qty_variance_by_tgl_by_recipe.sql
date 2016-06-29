/* Formatted on 2016/02/03 21:44 (Formatter Plus v4.8.8) */
SELECT   hou.NAME,
         h.batch_no, 
         im.concatenated_segments item_no,
         DECODE(d.LINE_TYPE,'1','product','2','by_product','-1','ingredient') as material,
         im.description item_desc1, d.revision, h.batch_id, h.wip_whse_code,
         h.formula_id, h.actual_cmplt_date, h.recipe_validity_rule_id,
         rcp.recipe_no, rcp.recipe_description, rcp.recipe_version,
         im.primary_uom_code item_um, d.plan_qty pqty, d.actual_qty aqty,
         NVL ((d.actual_qty - d.plan_qty), 0) AS selisih,
         d.dtl_um batchum, 
         CASE WHEN d.actual_qty <> 0 and d.plan_qty <> 0 THEN
         ROUND (NVL ((((d.actual_qty - d.plan_qty) / d.plan_qty) * 100), 0),
                5
               )
         ELSE
           -100
         end AS selisihptc,
         '%' persen,
         d.inventory_item_id ditemid,
         d.material_detail_id line_id, fd.formulaline_id,
         --fd.LINE_TYPE,
         fd.detail_uom formum
    FROM gme_batch_header h,
         gme_material_details d,
         fm_form_mst f,
         fm_matl_dtl fd,
         gmd_recipe_validity_rules val,
         gmd_recipes rcp,
         mtl_system_items_kfv im,
         hr_all_organization_units hou
   WHERE (h.batch_status = 3 OR h.batch_status = 4)
     AND hou.ORGANIZATION_ID = h.ORGANIZATION_ID
     AND h.batch_type = 0
     AND d.batch_id = h.batch_id
     AND h.recipe_validity_rule_id = val.recipe_validity_rule_id
     AND val.recipe_id = rcp.recipe_id
--and     ( d.line_type = -1   )
     AND f.formula_id = h.formula_id
     AND f.formula_id = fd.formula_id
     AND im.organization_id = d.organization_id
     AND im.inventory_item_id = d.inventory_item_id
--and     fd.line_type=-1
     AND d.formulaline_id = fd.formulaline_id
--and h.BATCH_NO = :CP_BatchRange
     AND substr(rcp.recipe_no,1,7) = :recipe
     AND h.ORGANIZATION_ID = :orgid
     AND h.plan_start_date BETWEEN TRUNC (TO_DATE (:tgl1,
                                                   'RRRR/MM/DD HH24:MI:SS'
                                                  )
                                         )
                               AND TRUNC (TO_DATE (:tgl2,
                                                   'RRRR/MM/DD HH24:MI:SS'
                                                  )
                                         )
ORDER BY h.batch_no ASC, d.LINE_TYPE asc, fd.LINE_TYPE asc
