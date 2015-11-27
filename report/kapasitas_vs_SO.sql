SELECT AA.*, AA.KAPASITAS - AA.QTy sisa_kapasitas
FROM
    (
    SELECT   (SELECT NAME
                FROM hr_all_organization_units
               WHERE organization_id = a.org_id) ou, mcbv.SEGMENT1  produk,
            SUM (CASE
                     WHEN b.SHIPPED_QUANTITY IS NULL
                        THEN 0
                     ELSE b.SHIPPED_QUANTITY
                  END
                 ) qty,
             YNP_GET_KAPASITAS(a.org_id,mcbv.segment1) as kapasitas
        FROM oe_order_headers_all a,
             oe_order_lines_all b,
             mtl_item_categories micv,
             mtl_categories_b_kfv mcbv
       WHERE a.header_id = b.header_id
         AND b.inventory_item_id = micv.inventory_item_id
         AND micv.category_id = mcbv.category_id
         AND micv.organization_id = 89
         AND micv.category_set_id = '1100000050'
         AND b.shipping_interfaced_flag = 'Y'
    --AND A.ORG_ID = :ORG_ID
         AND (SELECT AA.INITIAL_PICKUP_DATE 
            FROM WSH_NEW_DELIVERIES AA
            WHERE AA.DELIVERY_ID =
                (
                SELECT BB.DELIVERY_ID 
                FROM WSH_DELIVERY_ASSIGNMENTS BB
                WHERE BB.DELIVERY_DETAIL_ID = (SELECT CC.DELIVERY_DETAIL_ID 
                                                FROM WSH_DELIVERY_DETAILS CC
                                                WHERE CC.SOURCE_LINE_ID = B.LINE_ID
                                                AND CC.DELIVERY_DETAIL_ID  = (SELECT MAX(DD.DELIVERY_DETAIL_ID) 
                                                    FROM WSH_DELIVERY_DETAILS DD
                                                    WHERE DD.SOURCE_LINE_ID = B.LINE_ID)
                                              )
                )
            ) BETWEEN TRUNC(TO_DATE (:TGL1, 'RRRR/MM/DD HH24:MI:SS'))
                        AND TRUNC(TO_DATE (:TGL2,'RRRR/MM/DD HH24:MI:SS')+1)
       -- AND a.org_id = 82 
        AND mcbv.SEGMENT1 NOT IN ('RAW MATERIAL', 'SPAREPART')
        --AND YNP_GET_KAPASITAS(a.org_id,mcbv.segment1) <> 0
    GROUP BY a.org_id, mcbv.SEGMENT1 
 ) AA
 ORDER BY OU, PRODUK