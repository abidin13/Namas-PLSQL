SELECT 
       (
        SELECT NAME
        FROM HR_ALL_ORGANIZATION_UNITS
        WHERE ORGANIZATION_ID = :P_CONTEXT
       ) OU, 
       (
        SELECT DESCRIPTION FROM HR_LOCATIONS_ALL WHERE  LOCATION_ID = (
                                                                       SELECT LOCATION_ID 
                                                                       FROM   HR_ALL_ORGANIZATION_UNITS
                                                                       WHERE  ORGANIZATION_ID = :P_CONTEXT
                                                                      )
       ) AS OU_NAMA,
       (
        SELECT ADDRESS_LINE_1 FROM HR_LOCATIONS_ALL WHERE  LOCATION_ID = (
                                                                       SELECT LOCATION_ID 
                                                                       FROM   HR_ALL_ORGANIZATION_UNITS
                                                                       WHERE  ORGANIZATION_ID = :P_CONTEXT
                                                                      )
       ) AS OU_ADD,
       (
        SELECT TOWN_OR_CITY FROM HR_LOCATIONS_ALL WHERE  LOCATION_ID = (
                                                                       SELECT LOCATION_ID 
                                                                       FROM   HR_ALL_ORGANIZATION_UNITS
                                                                       WHERE  ORGANIZATION_ID = :P_CONTEXT
                                                                      )
       ) AS OU_TOWN,
       (
        SELECT TELEPHONE_NUMBER_1 FROM HR_LOCATIONS_ALL WHERE  LOCATION_ID = (
                                                                       SELECT LOCATION_ID 
                                                                       FROM   HR_ALL_ORGANIZATION_UNITS
                                                                       WHERE  ORGANIZATION_ID = :P_CONTEXT
                                                                      )
       ) AS OU_TELP,
       (
        SELECT LOC_INFORMATION13 FROM HR_LOCATIONS_ALL WHERE  LOCATION_ID = (
                                                                       SELECT LOCATION_ID 
                                                                       FROM   HR_ALL_ORGANIZATION_UNITS
                                                                       WHERE  ORGANIZATION_ID = :P_CONTEXT
                                                                      )
       ) AS OU_FAX,
       ZZ.*
FROM
(
SELECT * FROM
(
SELECT DISTINCT PP.ITEM, PP.FLAG, PP.TAHUN,
       NVL((SELECT FN_SUM_PERITEM_INVOICES(:P_CONTEXT,'01',:TAHUN,PP.ITEM) FROM DUAL), 0) AS JAN,
       NVL((SELECT FN_SUM_PERITEM_INVOICES(:P_CONTEXT,'02',:TAHUN,PP.ITEM) FROM DUAL), 0) AS FEB,
       NVL((SELECT FN_SUM_PERITEM_INVOICES(:P_CONTEXT,'03',:TAHUN,PP.ITEM) FROM DUAL), 0) AS MAR,
       NVL((SELECT FN_SUM_PERITEM_INVOICES(:P_CONTEXT,'04',:TAHUN,PP.ITEM) FROM DUAL), 0) AS APR,
       NVL((SELECT FN_SUM_PERITEM_INVOICES(:P_CONTEXT,'05',:TAHUN,PP.ITEM) FROM DUAL), 0) AS MEI,
       NVL((SELECT FN_SUM_PERITEM_INVOICES(:P_CONTEXT,'06',:TAHUN,PP.ITEM) FROM DUAL), 0) AS JUN,
       NVL((SELECT FN_SUM_PERITEM_INVOICES(:P_CONTEXT,'07',:TAHUN,PP.ITEM) FROM DUAL), 0) AS JUL,
       NVL((SELECT FN_SUM_PERITEM_INVOICES(:P_CONTEXT,'08',:TAHUN,PP.ITEM) FROM DUAL), 0) AS AUG,
       NVL((SELECT FN_SUM_PERITEM_INVOICES(:P_CONTEXT,'09',:TAHUN,PP.ITEM) FROM DUAL), 0) AS SEP,
       NVL((SELECT FN_SUM_PERITEM_INVOICES(:P_CONTEXT,'10',:TAHUN,PP.ITEM) FROM DUAL), 0) AS OKT,
       NVL((SELECT FN_SUM_PERITEM_INVOICES(:P_CONTEXT,'11',:TAHUN,PP.ITEM) FROM DUAL), 0) AS NOV,
       NVL((SELECT FN_SUM_PERITEM_INVOICES(:P_CONTEXT,'12',:TAHUN,PP.ITEM) FROM DUAL), 0) AS DES
FROM
(

SELECT 'INVOICES' AS FLAG, TO_CHAR(A.TRX_DATE, 'YYYY') AS TAHUN,
       (SELECT DISTINCT(SEGMENT1||'-'||SEGMENT2)
        FROM MTL_SYSTEM_ITEMS_B
        WHERE INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
       ) AS ITEM
   
FROM   ra_customer_trx_all A, ra_customer_trx_lines_all B
WHERE  A.customer_trx_id = B.customer_trx_id 
AND    A.complete_flag = 'Y'
AND    B.UNIT_SELLING_PRICE is not null 
AND    A.ORG_ID = :P_CONTEXT
AND    TO_CHAR(A.TRX_DATE, 'YYYY')  = :TAHUN
--AND    A.ORG_ID = :P_CONTEXT
AND (
         (UPPER(:P_REPORTING_LEVEL) = 'LEDGER') 
         OR
         (UPPER(:P_REPORTING_LEVEL) = 'OPERATING UNIT' AND A.ORG_ID = :P_CONTEXT)
    )  
)PP
WHERE  SUBSTR (ITEM, 0, 3) = 'FGP'
AND    SUBSTR (ITEM, 0, 7) NOT IN ('FGP-RPT')

UNION ALL

SELECT DISTINCT PP.ITEM, PP.FLAG, PP.TAHUN,
       NVL((SELECT FN_SUM_PERITEM_INVOICES_CM(:P_CONTEXT,'01',:TAHUN,PP.ITEM) FROM DUAL), 0) AS JAN,
       NVL((SELECT FN_SUM_PERITEM_INVOICES_CM(:P_CONTEXT,'02',:TAHUN,PP.ITEM) FROM DUAL), 0) AS FEB,
       NVL((SELECT FN_SUM_PERITEM_INVOICES_CM(:P_CONTEXT,'03',:TAHUN,PP.ITEM) FROM DUAL), 0) AS MAR,
       NVL((SELECT FN_SUM_PERITEM_INVOICES_CM(:P_CONTEXT,'04',:TAHUN,PP.ITEM) FROM DUAL), 0) AS APR,
       NVL((SELECT FN_SUM_PERITEM_INVOICES_CM(:P_CONTEXT,'05',:TAHUN,PP.ITEM) FROM DUAL), 0) AS MEI,
       NVL((SELECT FN_SUM_PERITEM_INVOICES_CM(:P_CONTEXT,'06',:TAHUN,PP.ITEM) FROM DUAL), 0) AS JUN,
       NVL((SELECT FN_SUM_PERITEM_INVOICES_CM(:P_CONTEXT,'07',:TAHUN,PP.ITEM) FROM DUAL), 0) AS JUL,
       NVL((SELECT FN_SUM_PERITEM_INVOICES_CM(:P_CONTEXT,'08',:TAHUN,PP.ITEM) FROM DUAL), 0) AS AUG,
       NVL((SELECT FN_SUM_PERITEM_INVOICES_CM(:P_CONTEXT,'09',:TAHUN,PP.ITEM) FROM DUAL), 0) AS SEP,
       NVL((SELECT FN_SUM_PERITEM_INVOICES_CM(:P_CONTEXT,'10',:TAHUN,PP.ITEM) FROM DUAL), 0) AS OKT,
       NVL((SELECT FN_SUM_PERITEM_INVOICES_CM(:P_CONTEXT,'11',:TAHUN,PP.ITEM) FROM DUAL), 0) AS NOV,
       NVL((SELECT FN_SUM_PERITEM_INVOICES_CM(:P_CONTEXT,'12',:TAHUN,PP.ITEM) FROM DUAL), 0) AS DES
FROM
(

SELECT 'RETUR' AS FLAG, TO_CHAR(A.TRX_DATE, 'YYYY') AS TAHUN,
       (SELECT DISTINCT(SEGMENT1||'-'||SEGMENT2)
        FROM MTL_SYSTEM_ITEMS_B
        WHERE INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
       ) AS ITEM
   
FROM   ra_customer_trx_all A, ra_customer_trx_lines_all B
WHERE  A.customer_trx_id = B.customer_trx_id 
AND    A.complete_flag = 'Y'
AND    B.UNIT_SELLING_PRICE is not null 
AND    A.ORG_ID = :P_CONTEXT
AND    TO_CHAR(A.TRX_DATE, 'YYYY')  = :TAHUN
--AND    A.ORG_ID = :P_CONTEXT
AND (
         (UPPER(:P_REPORTING_LEVEL) = 'LEDGER') 
         OR
         (UPPER(:P_REPORTING_LEVEL) = 'OPERATING UNIT' AND A.ORG_ID = :P_CONTEXT)
    )  
)PP
WHERE  SUBSTR (ITEM, 0, 3) = 'FGP'
AND    SUBSTR (ITEM, 0, 7) NOT IN ('FGP-RPT')
)XX
)ZZ
ORDER BY ZZ.ITEM, ZZ.FLAG