/* FORMATTED ON 2017/08/15 11:26 (FORMATTER PLUS V4.8.8) */
--IO = 194
-- ITEM_ID = 222152

SELECT (SELECT GBH.PLAN_CMPLT_DATE
          FROM GME_BATCH_HEADER GBH,
               GME_MATERIAL_DETAILS GMD
         WHERE GBH.BATCH_ID = MMT.TRANSACTION_SOURCE_ID
           AND GMD.INVENTORY_ITEM_ID = MMT.INVENTORY_ITEM_ID
           AND GBH.BATCH_ID = GMD.BATCH_ID
           AND GMD.MATERIAL_DETAIL_ID = MMT.TRX_SOURCE_LINE_ID
           AND TRUNC (GBH.PLAN_CMPLT_DATE)
                  BETWEEN TO_DATE (:TGL1, 'RRRR/MM/DD HH24:MI:SS')
                      AND TO_DATE (:TGL2, 'RRRR/MM/DD HH24:MI:SS')
           AND rownum = 1)
                                                           AS PRODUCTION_DATE,
       (SELECT CASE
                  WHEN TO_CHAR (GBH.PLAN_CMPLT_DATE, 'HH24:MI') =
                                                        '07:00'
                     THEN '1'
                  WHEN TO_CHAR (GBH.PLAN_CMPLT_DATE, 'HH24:MI') =
                                                        '15:00'
                     THEN '2'
                  WHEN TO_CHAR (GBH.PLAN_CMPLT_DATE, 'HH24:MI') =
                                                       '23:00'
                     THEN '3'
                  ELSE 'N/A'
               END AS SHIFT
          FROM GME_BATCH_HEADER GBH, GME_MATERIAL_DETAILS GMD
         WHERE GBH.BATCH_ID = MMT.TRANSACTION_SOURCE_ID
           AND GMD.INVENTORY_ITEM_ID = MMT.INVENTORY_ITEM_ID
           AND GBH.BATCH_ID = GMD.BATCH_ID
           AND GMD.MATERIAL_DETAIL_ID = MMT.TRX_SOURCE_LINE_ID
           
           AND TRUNC (GBH.PLAN_CMPLT_DATE)
                  BETWEEN TO_DATE (:TGL1, 'RRRR/MM/DD HH24:MI:SS')
                      AND TO_DATE (:TGL2, 'RRRR/MM/DD HH24:MI:SS')
           AND rownum = 1) AS SHIFT,
       (SELECT    F.SEGMENT1
               || '-'
               || F.SEGMENT2
               || '-'
               || F.SEGMENT3
               || '-'
               || F.SEGMENT4
               || '-'
               || F.SEGMENT5
          FROM MTL_SYSTEM_ITEMS F
         WHERE F.INVENTORY_ITEM_ID = MMT.INVENTORY_ITEM_ID
           AND F.ORGANIZATION_ID = MMT.ORGANIZATION_ID) AS ITEM,
       (SELECT GBH.BATCH_NO
          FROM GME_BATCH_HEADER GBH, GME_MATERIAL_DETAILS GMD
         WHERE GBH.BATCH_ID = MMT.TRANSACTION_SOURCE_ID
           AND GMD.INVENTORY_ITEM_ID = MMT.INVENTORY_ITEM_ID
           AND GBH.BATCH_ID = GMD.BATCH_ID
           AND GMD.MATERIAL_DETAIL_ID = MMT.TRX_SOURCE_LINE_ID
           AND TRUNC (GBH.PLAN_CMPLT_DATE)
                  BETWEEN TO_DATE (:TGL1, 'RRRR/MM/DD HH24:MI:SS')
                      AND TO_DATE (:TGL2, 'RRRR/MM/DD HH24:MI:SS')
           
           AND rownum = 1)
                                                                  AS BATCH_NO,
       (SELECT F.DESCRIPTION
          FROM MTL_SYSTEM_ITEMS F
         WHERE F.INVENTORY_ITEM_ID = MMT.INVENTORY_ITEM_ID
           AND F.ORGANIZATION_ID = MMT.ORGANIZATION_ID) AS DESCRIPTION,
           carilotnumberdua
           (
            MMT.TRANSACTION_ID
           ) AS LOT_NUMBER,
       /*(SELECT MTLN.LOT_NUMBER
          FROM MTL_TRANSACTION_LOT_NUMBERS MTLN
         WHERE MTLN.TRANSACTION_ID = MMT.TRANSACTION_ID) AS LOT_NUMBER,*/
       (SELECT GMD.ACTUAL_QTY
          FROM GME_BATCH_HEADER GBH, GME_MATERIAL_DETAILS GMD
         WHERE GBH.BATCH_ID = MMT.TRANSACTION_SOURCE_ID
           AND GMD.INVENTORY_ITEM_ID = MMT.INVENTORY_ITEM_ID
           AND GBH.BATCH_ID = GMD.BATCH_ID
           AND GMD.MATERIAL_DETAIL_ID = MMT.TRX_SOURCE_LINE_ID
           AND TRUNC (GBH.PLAN_CMPLT_DATE)
                  BETWEEN TO_DATE (:TGL1, 'RRRR/MM/DD HH24:MI:SS')
                      AND TO_DATE (:TGL2, 'RRRR/MM/DD HH24:MI:SS')
           
           AND rownum = 1)
                                                                AS ACTUAL_QTY,
       (SELECT GMD.DTL_UM
          FROM GME_BATCH_HEADER GBH, GME_MATERIAL_DETAILS GMD
         WHERE GBH.BATCH_ID = MMT.TRANSACTION_SOURCE_ID
           AND GMD.INVENTORY_ITEM_ID = MMT.INVENTORY_ITEM_ID
           AND GBH.BATCH_ID = GMD.BATCH_ID
           AND GMD.MATERIAL_DETAIL_ID = MMT.TRX_SOURCE_LINE_ID
           AND TRUNC (GBH.PLAN_CMPLT_DATE)
                  BETWEEN TO_DATE (:TGL1, 'RRRR/MM/DD HH24:MI:SS')
                      AND TO_DATE (:TGL2, 'RRRR/MM/DD HH24:MI:SS')
           
          AND rownum = 1) AS UOM,
          (SELECT WND.INITIAL_PICKUP_DATE
         FROM WSH_NEW_DELIVERIES WND
        WHERE WND.DELIVERY_ID IN (
                 SELECT WDA.DELIVERY_ID
                   FROM WSH_DELIVERY_ASSIGNMENTS WDA
                   WHERE WDA.DELIVERY_DETAIL_ID IN (
                            SELECT WDD.DELIVERY_DETAIL_ID
                              FROM WSH_DELIVERY_DETAILS WDD
                             WHERE WDD.DELIVERY_DETAIL_ID =
                                             MMT.PICKING_LINE_ID)))
                                                                AS TGL_KIRIM,
       (SELECT WDD.SHIPPED_QUANTITY
          FROM WSH_DELIVERY_DETAILS WDD
         WHERE WDD.DELIVERY_DETAIL_ID = MMT.PICKING_LINE_ID) AS QTY_KIRIM,
       (SELECT CASE
                  WHEN D.ACCOUNT_NAME IS NULL
                   OR D.ACCOUNT_NAME = ''
                     THEN D.ATTRIBUTE1
                 ELSE D.ACCOUNT_NAME
               END
          FROM HZ_CUST_ACCOUNTS D
         WHERE D.CUST_ACCOUNT_ID IN (
                  SELECT WND.CUSTOMER_ID
                    FROM WSH_NEW_DELIVERIES WND
                   WHERE WND.DELIVERY_ID IN (
                            SELECT WDA.DELIVERY_ID
                              FROM WSH_DELIVERY_ASSIGNMENTS WDA
                             WHERE WDA.DELIVERY_DETAIL_ID IN (
                                      SELECT WDD.DELIVERY_DETAIL_ID
                                        FROM WSH_DELIVERY_DETAILS WDD
                                       WHERE WDD.DELIVERY_DETAIL_ID =
                                                           MMT.PICKING_LINE_ID))))
                                                             AS NAMA_CUSTOMER,
       (SELECT WND.NAME
          FROM WSH_NEW_DELIVERIES WND
         WHERE WND.DELIVERY_ID IN (
                  SELECT WDA.DELIVERY_ID
                    FROM WSH_DELIVERY_ASSIGNMENTS WDA
                   WHERE WDA.DELIVERY_DETAIL_ID IN (
                            SELECT WDD.DELIVERY_DETAIL_ID
                              FROM WSH_DELIVERY_DETAILS WDD
                             WHERE WDD.DELIVERY_DETAIL_ID =
                                             MMT.PICKING_LINE_ID)))
                                                                 AS DO_NUMBER
  FROM MTL_MATERIAL_TRANSACTIONS MMT
 WHERE MMT.ORGANIZATION_ID = :IO
   AND MMT.INVENTORY_ITEM_ID = :ITEM_ID
   AND MMT.TRANSACTION_TYPE_ID IN ('33', '44')
--   AND GBH.BATCH_ID = MMT.TRANSACTION_SOURCE_ID
--   AND GMD.INVENTORY_ITEM_ID = MMT.INVENTORY_ITEM_ID
   AND TRUNC (MMT.TRANSACTION_DATE) BETWEEN TO_DATE (:TGL1,
                                                     'RRRR/MM/DD HH24:MI:SS'
                                                    )
                                        AND TO_DATE (:TGL2,
                                                     'RRRR/MM/DD HH24:MI:SS'
                                                    )
                                                   