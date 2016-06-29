/* Formatted on 2016/06/10 07:22 (Formatter Plus v4.8.8) */
SELECT   TO_CHAR (TO_DATE (:from_date, 'RRRR/MM/DD HH24:MI:SS'),
                  'DD/MM/YYYY'
                 ) AS fromdate,
         TO_CHAR (TO_DATE (:TO_DATE, 'RRRR/MM/DD HH24:MI:SS'),
                  'DD/MM/YYYY'
                 ) AS todate,
         (SELECT NAME
            FROM hr_all_organization_units
           WHERE organization_id = a.organization_id) ou,
            d.segment1
         || '-'
         || d.segment2
         || '-'
         || d.segment3
         || '-'
         || d.segment4
         || '-'
         || d.segment5 AS item_code,
         c.inventory_item_id, d.description,
         DECODE (c.line_type,
                 -1, 'Ingredient',
                 1, 'Product',
                 2,'By-Product'
                ) TYPE,
         SUM (e.transaction_quantity) quantity, c.dtl_um,
         DECODE (d.segment1,
                 'FGP', ynp_rjt_pcs2 (c.inventory_item_id,
                                      a.organization_id,
                                      :from_date,
                                      :TO_DATE
                                     )
                ) AS rjt_pcs
    FROM apps.gme_batch_header a,
         apps.gmd_recipes b,
         gmd_recipe_validity_rules grr,
         apps.gme_material_details c,
         apps.mtl_system_items_kfv d,
         apps.mtl_material_transactions e
   WHERE a.formula_id = b.formula_id
     AND a.routing_id = b.routing_id
     AND a.recipe_validity_rule_id = grr.recipe_validity_rule_id
     AND grr.recipe_id = b.recipe_id
     AND a.batch_id = c.batch_id
     AND a.organization_id = c.organization_id
     AND c.inventory_item_id = d.inventory_item_id
     AND c.organization_id = d.organization_id
     AND a.batch_id = e.transaction_source_id
     AND c.material_detail_id = e.trx_source_line_id
     AND a.organization_id = e.organization_id
     AND c.inventory_item_id = e.inventory_item_id
     and c.line_type not in ('-1')
     AND a.batch_no IN (
            SELECT DISTINCT batch_no
                       FROM apps.gme_batch_header gbh,
                            gme_material_details gmd,
                            mtl_system_items_kfv msik
                      WHERE TRUNC (actual_cmplt_date)
                               BETWEEN TO_DATE (:from_date,
                                                'RRRR/MM/DD HH24:MI:SS'
                                               )
                                   AND TO_DATE (:TO_DATE,
                                                'RRRR/MM/DD HH24:MI:SS'
                                               )
                        AND gbh.batch_id = gmd.batch_id
                        AND gbh.organization_id = gmd.organization_id
                        AND gbh.organization_id = gmd.organization_id
                        AND gmd.inventory_item_id = msik.inventory_item_id
                        AND gmd.organization_id = msik.organization_id
                        AND (   msik.concatenated_segments = :p_item_code
                             OR :p_item_code IS NULL
                            )
                        AND msik.description LIKE
                                          NVL ('%' || :p_item_desc || '%',
                                               '%'))
     AND a.organization_id = :your_org_id
     AND SUBSTR (b.recipe_no, 1, 7) LIKE NVL (:type_produk, '%')
     AND SUBSTR (b.recipe_no, 1, 18) LIKE NVL (:recipe_detail, '%')
     AND b.RECIPE_DESCRIPTION like '%MIZONE%'
     and SUBSTR (d.CONCATENATED_SEGMENTS,5,3) = 'CAP'
     --and c.inventory_item_id = 2594

--AND (D.CONCATENATED_SEGMENTS = :P_ITEM_CODE OR :P_ITEM_CODE IS NULL)
--AND D.DESCRIPTION LIKE NVL(:P_ITEM_DESC,'%')
---AND B.RECIPE_NO LIKE NVL(:RECIPE_DETAIL,'%')
---AND (SUBSTR(B.RECIPE_NO,1,7) = :TYPE_PRODUK or :TYPE_PRODUK IS NULL)
---AND (B.RECIPE_NO = :RECIPE_DETAIL OR :RECIPE_DETAIL IS NULL)
--TRUNC(TO_DATE (:TGL1,'RRRR/MM/DD HH24:MI:SS'))
     AND TRUNC (e.transaction_date) BETWEEN TO_DATE (:from_date,
                                                     'RRRR/MM/DD HH24:MI:SS'
                                                    )
                                        AND TO_DATE (:TO_DATE,
                                                     'RRRR/MM/DD HH24:MI:SS'
                                                    )
GROUP BY a.organization_id,
            d.segment1
         || '-'
         || d.segment2
         || '-'
         || d.segment3
         || '-'
         || d.segment4
         || '-'
         || d.segment5,
         c.inventory_item_id,
         d.description,
         c.line_type,
         c.dtl_um,
         d.segment1
ORDER BY c.line_type