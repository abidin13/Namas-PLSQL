/* FORMATTED ON 2017/12/18 14:54 (FORMATTER PLUS V4.8.8) */
CREATE OR REPLACE PROCEDURE APPS.YNP_INSERT_ITEMLOT_HISTORY
AS
   CURSOR C1
   IS
      SELECT C.INVENTORY_ITEM_ID,
             (SELECT    SEGMENT1
                     || '-'
                     || SEGMENT2
                     || '-'
                     || SEGMENT3
                     || '-'
                     || SEGMENT4
                     || '-'
                     || SEGMENT5
                FROM MTL_SYSTEM_ITEMS_B
               WHERE INVENTORY_ITEM_ID = C.INVENTORY_ITEM_ID
                 AND ORGANIZATION_ID = C.ORGANIZATION_ID) AS ITEM_CODE,
             C.ITEM_DESCRIPTION AS DESCRIPTION, A.NAME AS DO_NUMBER,
             A.INITIAL_PICKUP_DATE AS TANGGAL_KIRIM, C.SUBINVENTORY,
             C.LOT_NUMBER, C.REQUESTED_QUANTITY_UOM AS UOM,
             CASE
                WHEN C.SHIPPED_QUANTITY IS NULL
                   THEN C.REQUESTED_QUANTITY
                ELSE C.SHIPPED_QUANTITY
             END AS QTY_KIRIM,
             (SELECT CASE
                        WHEN D.ACCOUNT_NAME IS NULL
                         OR D.ACCOUNT_NAME = ''
                           THEN D.ATTRIBUTE1
                        ELSE D.ACCOUNT_NAME
                     END
                FROM HZ_CUST_ACCOUNTS D
               WHERE D.CUST_ACCOUNT_ID = A.CUSTOMER_ID) AS NAMA_CUSTOMER,
             
             --CURRENT_DATE AS TANGGAL_AWAL,
             TO_DATE (ADD_MONTHS ((LAST_DAY (SYSDATE) + 1), -1),
                      'RRRR/MM/DD HH24:MI:SS'
                     ) AS TANGGAL_AWAL,
             TO_DATE (LAST_DAY (SYSDATE),
                      'RRRR/MM/DD HH24:MI:SS'
                     ) AS TANGGAL_AKHIR,
             
             --CURRENT_DATE AS TANGGAL_AKHIR,
             (SELECT ORGANIZATION_ID
                FROM HR_ALL_ORGANIZATION_UNITS
               WHERE ORGANIZATION_ID =
                          (SELECT OPERATING_UNIT
                             FROM ORG_ORGANIZATION_DEFINITIONS OOD
                            WHERE ORGANIZATION_ID = A.ORGANIZATION_ID))
                                                                      ORG_ID,
             (SELECT NAME
                FROM HR_ALL_ORGANIZATION_UNITS
               WHERE ORGANIZATION_ID =
                         (SELECT OPERATING_UNIT
                            FROM ORG_ORGANIZATION_DEFINITIONS OOD
                           WHERE ORGANIZATION_ID = A.ORGANIZATION_ID))
                                                                     OU_NAME
        FROM WSH_NEW_DELIVERIES A,
             WSH_DELIVERY_ASSIGNMENTS B,
             WSH_DELIVERY_DETAILS C
       WHERE A.DELIVERY_ID = B.DELIVERY_ID
         AND B.DELIVERY_DETAIL_ID = C.DELIVERY_DETAIL_ID
         --AND C.RELEASED_STATUS = 'C'
         AND (A.INITIAL_PICKUP_DATE
                 BETWEEN TRUNC (TO_DATE (ADD_MONTHS ((LAST_DAY (SYSDATE) + 1),
                                                     -1
                                                    ),
                                         'RRRR/MM/DD HH24:MI:SS'
                                        )
                               )
                     AND TRUNC (TO_DATE (LAST_DAY (SYSDATE),
                                         'RRRR/MM/DD HH24:MI:SS'
                                        )
                               )
             )
         AND C.LOT_NUMBER IS NOT NULL
         AND (SELECT OPERATING_UNIT
                FROM ORG_ORGANIZATION_DEFINITIONS OOD
               WHERE ORGANIZATION_ID = A.ORGANIZATION_ID) = 82;
BEGIN
   FOR R1 IN C1
   LOOP
      BEGIN
         INSERT INTO YNP_ITEMLOT_HISTORY
                     (ID_INSERT, INVENTORY_ITEM_ID,
                      ITEM_CODE, DESCRIPTION, DO_NUMBER,
                      TANGGAL_KIRIM, SUBINVENTORY, LOT_NUMBER,
                      UOM, QTY_KIRIM, NAMA_CUSTOMER,
                      TANGGAL_AWAL, TANGGAL_AKHIR, ORG_ID,
                      OU_NAME
                     )
              VALUES (YNP_ITEMLOT_HISTORY_SEQ.NEXTVAL, R1.INVENTORY_ITEM_ID,
                      R1.ITEM_CODE, R1.DESCRIPTION, R1.DO_NUMBER,
                      R1.TANGGAL_KIRIM, R1.SUBINVENTORY, R1.LOT_NUMBER,
                      R1.UOM, R1.QTY_KIRIM, R1.NAMA_CUSTOMER,
                      R1.TANGGAL_AWAL, R1.TANGGAL_AKHIR, R1.ORG_ID,
                      R1.OU_NAME
                     );
      END;

      COMMIT;
   END LOOP;
END;
/