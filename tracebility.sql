/* FORMATTED ON 2017/12/14 08:34 (FORMATTER PLUS V4.8.8) */
SELECT GBH.PLAN_CMPLT_DATE, MTLN.LOT_NUMBER, GBH.BATCH_NO,
          MSI.SEGMENT1
       || '-'
       || MSI.SEGMENT2
       || '-'
       || MSI.SEGMENT3
       || '-'
       || MSI.SEGMENT4
       || '-'
       || MSI.SEGMENT5 ITEM_CODE,
       MSI.DESCRIPTION, TAB.LOT_NUMBER DETAIL_LOT_NUMBER, TAB.ACTUAL_QTY,
       TAB.TRANSACTION_UOM,
       (SELECT WND.INITIAL_PICKUP_DATE
          FROM WSH_NEW_DELIVERIES WND
         WHERE WND.DELIVERY_ID IN (
                  SELECT WDA.DELIVERY_ID
                    FROM WSH_DELIVERY_ASSIGNMENTS WDA
                   WHERE WDA.DELIVERY_DETAIL_ID IN (
                            SELECT WDD.DELIVERY_DETAIL_ID
                              FROM WSH_DELIVERY_DETAILS WDD
                             WHERE WDD.DELIVERY_DETAIL_ID IN (
                                      SELECT MMT.PICKING_LINE_ID
                                        FROM MTL_MATERIAL_TRANSACTIONS MMT
                                       WHERE MMT.TRANSACTION_TYPE_ID = 33
                                         AND MMT.INVENTORY_ITEM_ID = TAB.INVENTORY_ITEM_ID
                                         AND MMT.ORGANIZATION_ID = TAB.ORGANIZATION_ID
                                         AND MMT.TRANSACTION_ID IN (
                                                SELECT TRANSACTION_ID
                                                  FROM MTL_TRANSACTION_LOT_NUMBERS MTLN
                                                 WHERE MTLN.LOT_NUMBER =
                                                                TAB.LOT_NUMBER)))))
                                                                 AS TGL_KIRIM,
       (SELECT WDD.SHIPPED_QUANTITY
          FROM WSH_DELIVERY_DETAILS WDD
         WHERE WDD.DELIVERY_DETAIL_ID IN (
                  SELECT MMT.PICKING_LINE_ID
                    FROM MTL_MATERIAL_TRANSACTIONS MMT
                   WHERE MMT.TRANSACTION_TYPE_ID = 33
                     AND MMT.INVENTORY_ITEM_ID = TAB.INVENTORY_ITEM_ID
                     AND MMT.ORGANIZATION_ID = TAB.ORGANIZATION_ID
                     AND MMT.TRANSACTION_ID IN (
                                        SELECT TRANSACTION_ID
                                          FROM MTL_TRANSACTION_LOT_NUMBERS MTLN
                                         WHERE MTLN.LOT_NUMBER =
                                                                TAB.LOT_NUMBER)))
                                                                 AS QTY_KIRIM,
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
                                       WHERE WDD.DELIVERY_DETAIL_ID IN (
                                                SELECT MMT.PICKING_LINE_ID
                                                  FROM MTL_MATERIAL_TRANSACTIONS MMT
                                                 WHERE MMT.TRANSACTION_TYPE_ID =
                                                                            33
                                                   AND MMT.INVENTORY_ITEM_ID =
                                                                      TAB.INVENTORY_ITEM_ID
                                                   AND MMT.ORGANIZATION_ID = TAB.ORGANIZATION_ID
                                                   AND MMT.TRANSACTION_ID IN (
                                                          SELECT TRANSACTION_ID
                                                            FROM MTL_TRANSACTION_LOT_NUMBERS MTLN
                                                           WHERE MTLN.LOT_NUMBER =
                                                                    TAB.LOT_NUMBER))))))
                                                             AS NAMA_CUSTOMER,
       (SELECT WND.NAME
          FROM WSH_NEW_DELIVERIES WND
         WHERE WND.DELIVERY_ID IN (
                  SELECT WDA.DELIVERY_ID
                    FROM WSH_DELIVERY_ASSIGNMENTS WDA
                   WHERE WDA.DELIVERY_DETAIL_ID IN (
                            SELECT WDD.DELIVERY_DETAIL_ID
                              FROM WSH_DELIVERY_DETAILS WDD
                             WHERE WDD.DELIVERY_DETAIL_ID IN (
                                      SELECT MMT.PICKING_LINE_ID
                                        FROM MTL_MATERIAL_TRANSACTIONS MMT
                                       WHERE MMT.TRANSACTION_TYPE_ID = 33
                                         AND MMT.INVENTORY_ITEM_ID = TAB.INVENTORY_ITEM_ID
                                         AND MMT.ORGANIZATION_ID = TAB.ORGANIZATION_ID
                                         AND MMT.TRANSACTION_ID IN (
                                                SELECT TRANSACTION_ID
                                                  FROM MTL_TRANSACTION_LOT_NUMBERS MTLN
                                                 WHERE MTLN.LOT_NUMBER =
                                                                TAB.LOT_NUMBER)))))
                                                                 AS DO_NUMBER
  FROM GME_BATCH_HEADER GBH,
       GME_MATERIAL_DETAILS GBD,
       MTL_SYSTEM_ITEMS MSI,
       MTL_MATERIAL_TRANSACTIONS MTT,
       MTL_TRANSACTION_LOT_NUMBERS MTLN,
       (SELECT   A.BATCH_ID, B.INVENTORY_ITEM_ID, B.ORGANIZATION_ID,
                 A.ACTUAL_QTY, D.LOT_NUMBER, C.TRANSACTION_UOM
            FROM GME_MATERIAL_DETAILS A,
                 MTL_SYSTEM_ITEMS B,
                 MTL_MATERIAL_TRANSACTIONS C,
                 MTL_TRANSACTION_LOT_NUMBERS D
           WHERE 1 = 1
             AND A.MATERIAL_DETAIL_ID = C.TRX_SOURCE_LINE_ID
             AND C.TRANSACTION_ID = D.TRANSACTION_ID
             AND A.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
             AND B.ORGANIZATION_ID = 89
             AND A.ORGANIZATION_ID = :IO
             --AND A.INVENTORY_ITEM_ID = :ITEM_ID
        --AND A.BATCH_ID = 578323
        ORDER BY A.LINE_TYPE, A.LINE_NO, A.BATCH_ID) TAB
 WHERE 1 = 1
   AND MTT.TRANSACTION_ID = MTLN.TRANSACTION_ID
   AND GBD.MATERIAL_DETAIL_ID = MTT.TRX_SOURCE_LINE_ID
   AND GBH.BATCH_ID = GBD.BATCH_ID
   AND TAB.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
   AND TAB.ORGANIZATION_ID = MSI.ORGANIZATION_ID
   AND MSI.ORGANIZATION_ID = 89
   AND GBD.ORGANIZATION_ID = :IO
   AND GBD.BATCH_ID = TAB.BATCH_ID
   AND GBD.LINE_TYPE = 1
   AND GBD.LINE_NO = 1
   AND GBD.INVENTORY_ITEM_ID = :ITEM_ID
   AND TRUNC (GBH.ACTUAL_START_DATE)
                  BETWEEN TO_DATE (:TGL1, 'RRRR/MM/DD HH24:MI:SS') - 1
                      AND TO_DATE (:TGL2, 'RRRR/MM/DD HH24:MI:SS')
    --AND GBD.BATCH_ID = 578323