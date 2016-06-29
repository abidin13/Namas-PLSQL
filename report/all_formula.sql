SELECT b.formula_no,
       t.formula_desc1,
       b.formula_vers, b.formula_type, b.scale_type,
       b.formula_class, b.fmcontrol_class, b.in_use, b.inactive_ind,
       b.attribute_category, b.text_code, b.delete_mark, b.created_by,
       b.creation_date, b.last_update_date, b.last_updated_by,
       b.last_update_login, b.project_id, b.formula_status, b.owner_id,
       b.total_input_qty, b.total_output_qty, b.yield_uom,
       b.owner_organization_id, b.master_formula_id, b.auto_product_calc,
       misk.CONCATENATED_SEGMENTS,
       msb.description,
       DECODE (fmtl.line_type,'1','Product','2','By_product','-1','Ingredients')as line_type,    
       fmtl.COST_ALLOC,
       fmtl.QTY,
       fmtl.DETAIL_UOM,
       mp.ORGANIZATION_CODE,
       hou.NAME
      
         
  FROM fm_form_mst_b b, 
       fm_form_mst_tl t, 
       FM_MATL_DTL fmtl,
       mtl_system_items_b msb,
       mtl_system_items_kfv misk,
       hr_all_organization_units hou,
       mtl_parameters mp
       
  where misk.INVENTORY_ITEM_ID = fmtl.INVENTORY_ITEM_ID
  and b.FORMULA_ID = t.FORMULA_ID
  and msb.inventory_item_id = misk.inventory_item_id
  and msb.organization_id = b.OWNER_ORGANIZATION_ID
  and fmtl.FORMULA_ID = b.FORMULA_ID
  and b.OWNER_ORGANIZATION_ID = misk.ORGANIZATION_ID
  and b.OWNER_ORGANIZATION_ID = hou.ORGANIZATION_ID
  and hou.ORGANIZATION_ID = mp.ORGANIZATION_ID