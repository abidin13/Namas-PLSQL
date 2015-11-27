/* Formatted on 2015/10/02 15:57 (Formatter Plus v4.8.8) */
SELECT t.recipe_description, b.recipe_no,
       b.recipe_version, b.creation_organization_id, hou.name,
       fbb.formula_no, ftt.formula_desc1, 
       rbb.routing_no, rtt.routing_desc,
       b.project_id, b.recipe_status,
       b.planned_process_loss, b.contiguous_ind, b.text_code, b.delete_mark,
       b.attribute_category, b.attribute1, b.creation_date, b.created_by,
       b.last_updated_by, b.last_update_date, b.last_update_login,
       b.owner_id,
       b.owner_lab_type, b.calculate_step_quantity, b.recipe_type,
       b.enhanced_pi_ind, b.master_recipe_id, b.fixed_process_loss,
       b.fixed_process_loss_uom
       
       
    FROM gmd_recipes_b b, 
       gmd_recipes_tl t,
       fm_form_mst_b fbb,
       fm_form_mst_tl ftt,
       gmd_routings_b rbb,
       gmd_routings_tl rtt,
       hr_all_organization_units hou
            
 
 WHERE b.recipe_id = t.recipe_id
 and b.FORMULA_ID = ftt.formula_id
 and b.FORMULA_ID = fbb.formula_id
 and rbb.routing_id = b.routing_id
 and rtt.routing_id = rbb.routing_id
 and b.creation_organization_id = hou.ORGANIZATION_ID        
 