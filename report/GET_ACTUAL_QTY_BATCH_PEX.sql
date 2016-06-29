/* Formatted on 2015/12/05 19:40 (Formatter Plus v4.8.8) */
SELECT   a.batch_no, a.recipe_validity_rule_id, a.formula_id, a.routing_id,
         (SELECT b.recipe_description
            FROM apps.gme_batch_header aa,
                 apps.gmd_recipes b,
                 gmd_recipe_validity_rules grr
           WHERE aa.formula_id = b.formula_id
             AND aa.recipe_validity_rule_id = grr.recipe_validity_rule_id
             AND grr.recipe_id = b.recipe_id
             AND aa.batch_id = a.batch_id) AS recipe_desc,
         (SELECT b.recipe_no
            FROM apps.gme_batch_header aa,
                 apps.gmd_recipes b,
                 gmd_recipe_validity_rules grr
           WHERE aa.formula_id = b.formula_id
             AND aa.recipe_validity_rule_id = grr.recipe_validity_rule_id
             AND grr.recipe_id = b.recipe_id
             AND aa.batch_id = a.batch_id) AS recipe,
         (SELECT b.recipe_version
            FROM apps.gme_batch_header aa,
                 apps.gmd_recipes b,
                 gmd_recipe_validity_rules grr
           WHERE aa.formula_id = b.formula_id
             AND aa.recipe_validity_rule_id = grr.recipe_validity_rule_id
             AND grr.recipe_id = b.recipe_id
             AND aa.batch_id = a.batch_id) AS recipe_ver,
         
         DECODE (a.batch_status,
                 -1, 'Cancelled',
                 1, 'Pending',
                 2, 'WIP',
                 3, 'Completed',
                 4, 'Closed'
                ) AS batch_status1,
         (SELECT    f.segment1
                 || '-'
                 || f.segment2
                 || '-'
                 || f.segment3
                 || '-'
                 || f.segment4
                 || '-'
                 || f.segment5
            FROM mtl_system_items f
           WHERE f.inventory_item_id = b.inventory_item_id
             AND f.organization_id = b.organization_id) AS item,
         (SELECT a.description
            FROM mtl_system_items a
           WHERE a.inventory_item_id = b.inventory_item_id
             AND a.organization_id = b.organization_id) AS itemdescription,
         c.routing_no, c.routing_desc, c.routing_vers, d.formula_desc1,
         d.formula_vers, b.line_type,
         DECODE (b.line_type,
                 -1, 'Ingredients',
                 1, 'Product',
                 2, 'By-Product'
                ) AS TYPE,
         f.SUBINVENTORY_CODE,
         b.line_no AS NO, b.plan_qty AS planned_qty,
         b.wip_plan_qty AS wip_plan_qty, b.actual_qty AS actual_qty,
         g.lot_number,
                      CASE 
                        WHEN b.line_type = 2 THEN
                            b.actual_qty
                        else
                            g.transaction_quantity
                        end as transaction_quantity ,
                      --g.primary_quantity as pq,
                      b.dtl_um AS uom,
         DECODE (a.organization_id,
                 91, 'Bandung',
                 98, 'Bandung',
                 105, 'Bandung',
                 112, 'Bandung',
                 119, 'Lampung',
                 153, 'Medan',
                 162, 'Solo',
                 171, 'Sentul',
                 194, 'Surabaya',
                 213, 'Bali',
                 231, 'Manado'
                ) AS plant
    FROM gme_batch_header a,
         gme_material_details b,
         gmd_routings_vl c,
         fm_form_mst_vl d,
         mtl_material_transactions f,
         mtl_transaction_lot_numbers g
   WHERE a.batch_id = b.batch_id
     AND a.routing_id = c.routing_id(+)
     AND a.formula_id = d.formula_id
     AND b.inventory_item_id = f.inventory_item_id(+)
     AND b.material_detail_id = f.trx_source_line_id(+)
     AND f.transaction_id = g.transaction_id(+)
     AND f.organization_id = g.organization_id(+)
     AND f.inventory_item_id = g.inventory_item_id(+)
     AND (   g.transaction_source_type_id = 5
          OR g.transaction_source_type_id IS NULL
         )
     AND a.organization_id = :io
     AND a.batch_status = 4
     AND (   TRUNC (plan_start_date) BETWEEN TO_DATE (:from_date,
                                                      'RRRR/MM/DD HH24:MI:SS'
                                                     )
                                         AND TO_DATE (:TO_DATE,
                                                      'RRRR/MM/DD HH24:MI:SS'
                                                     )
          --OR a.batch_no BETWEEN :from_batch_no AND :to_batch_no
         )
     AND substr(d.FORMULA_NO, 5,3)=:ITEM
--     and b.line_type = 2
ORDER BY a.batch_no, b.line_type, b.line_no