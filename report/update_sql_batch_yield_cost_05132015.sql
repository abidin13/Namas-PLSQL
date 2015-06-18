
SELECt INVENTORY_ITEM_ID, DESCRIPTION, ITEM_NUMBER, SUM(TOTAL)
FROM
(
SELECt inventory_item_id,
        ITEM_NUMBER,
        DESCRIPTION,      
        product,  
        SUM(TOTAL_BATCH_COST) TOTAL
FROM 
(
SELECT  a.BATCH_NO, a.DESCRIPTION,
         a.inventory_item_id, a.item_number, a.product, a.layer_id, a.cost_cmpntcls_code,
         a.cost_analysis_code, a.usage_ind, a.cmpnt_cost,
         a.prod_layer_pri_qty, a.primary_uom_code,
         ROUND(a.prod_layer_pri_qty * cmpnt_cost,
                :PRECISION
               ) AS total_batch_cost
    FROM (SELECT DISTINCT prd.inventory_item_id, prd.item_number, lc.layer_id, cmm.cost_mthd_code,
                          cmpt.cost_cmpntcls_code, lc.cost_analysis_code,
                          DECODE (lc.cost_level,
                                  0, 'This',
                                  1, 'Lower'
                                 ) AS cost_level,
                          DECODE (cmpt.usage_ind,
                                  1, 'Material',
                                  2, 'Overhead',
                                  3, 'Resource',
                                  4, 'Expense Alloc',
                                  5, 'Std Cost Adj'
                                 ) AS usage_ind,
                          lc.cmpnt_cost,
                          pnd.primary_quantity prod_layer_pri_qty,
                          prd.primary_uom_code,
                         (SELECT BATCH_NO FROM GME_BATCH_HEADER WHERE BATCH_ID = pnd.transaction_source_id) BATCH_NO,
                          (SELECT MICV.CATEGORY_CONCAT_SEGS 
                            FROM MTL_ITEM_CATEGORIES_V MICV 
                            WHERE MICV.INVENTORY_ITEM_ID =  prd.inventory_item_id 
                            AND MICV.ORGANIZATION_ID = pnd.organization_id
                            AND MICV.CATEGORY_SET_NAME = 'NP Product Category'
                         ) PRODUCT, DESCRIPTION
                     FROM gmf_layer_cost_details lc,
                          mtl_item_flexfields prd,
                          cm_cmpt_mst cmpt,
                          gmf_incoming_material_layers il,
                          mtl_material_transactions pnd,
                          cm_mthd_mst cmm
                    WHERE 1 = 1
                      --AND pnd.transaction_source_id = :p_batch_id
                      AND pnd.transaction_source_type_id = 5
                      AND TO_CHAR(pnd.CREATION_DATE , 'MM') = :BULAN
                      AND TO_CHAR(pnd.CREATION_DATE , 'YYYY') = :TAHUN
                      AND pnd.organization_id = :organization_id
                      AND pnd.transaction_action_id IN
                     
                            (27, 31, 32)
                      AND il.mmt_transaction_id = pnd.transaction_id
                      AND il.mmt_transaction_id IS NOT NULL
                      AND lc.layer_id = il.layer_id
                      AND lc.cost_type_id = 1000
                      AND cmm.cost_type_id = lc.cost_type_id
                      AND cmpt.cost_cmpntcls_id = lc.cost_cmpntcls_id
                      AND prd.inventory_item_id = pnd.inventory_item_id
                      AND prd.organization_id = pnd.organization_id) a
ORDER BY item_number, layer_id, a.usage_ind
)
GROUP BY BATCH_NO, inventory_item_id, ITEM_NUMBER, product, DESCRIPTION
HAVING SUM(TOTAL_BATCH_COST) <> 0
ORDER BY INVENTORY_ITEM_ID, ITEM_NUMBER, DESCRIPTION
)
GROUP BY INVENTORY_ITEM_ID, ITEM_NUMBER, DESCRIPTION
ORDER BY ITEM_NUMBER