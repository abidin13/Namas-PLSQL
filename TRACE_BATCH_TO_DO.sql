/* FORMATTED ON 2017/12/08 10:59 (FORMATTER PLUS V4.8.8) */
SELECT WND.INITIAL_PICKUP_DATE
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
                               WHERE MMT.TRANSACTION_ID IN (
                                        SELECT MTLN.TRANSACTION_ID
                                          FROM MTL_TRANSACTION_LOT_NUMBERS MTLN
                                         WHERE MTLN.LOT_NUMBER IN (
                                                  SELECT MTLN.LOT_NUMBER
                                                    FROM MTL_TRANSACTION_LOT_NUMBERS MTLN
                                                   WHERE MTLN.TRANSACTION_ID IN (
                                                            SELECT MMT.TRANSACTION_ID
                                                              FROM MTL_MATERIAL_TRANSACTIONS MMT
                                                             WHERE MMT.TRX_SOURCE_LINE_ID IN (
                                                                      SELECT GMD.MATERIAL_DETAIL_ID
                                                                        FROM GME_MATERIAL_DETAILS GMD,
                                                                             GME_BATCH_HEADER GBH
                                                                       WHERE GBH.BATCH_ID =
                                                                                GMD.BATCH_ID
                                                                         AND GMD.INVENTORY_ITEM_ID = 222152
                                                                         AND GBH.ORGANIZATION_ID = 194)))))))
AND TRUNC (WND.INITIAL_PICKUP_DATE)
                  BETWEEN TO_DATE (:TGL1, 'RRRR/MM/DD HH24:MI:SS')
                      AND TO_DATE (:TGL2, 'RRRR/MM/DD HH24:MI:SS')