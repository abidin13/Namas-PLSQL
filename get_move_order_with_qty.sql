SELECT A.REQUEST_NUMBER, A.DATE_REQUIRED,
       (
        select NAME 
        from hr_all_organization_units mm
        where mm.ORGANIZATION_ID = A.ORGANIZATION_ID
    ) AS OU,
    (
        select kk.transaction_type_name
        from mtl_transaction_types kk
        where kk.transaction_type_id = A.transaction_type_id 
    ) AS TRANSACTION_TYPE,
      
      
      
       B.LINE_ID, B.INVENTORY_ITEM_ID,
       (
        select jj.CONCATENATED_SEGMENTS
        from mtl_system_items_kfv jj
        where jj.ORGANIZATION_ID = B.ORGANIZATION_ID
        and jj.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
        ) AS ITEM_CODE,
        
       (SELECT DESCRIPTION
        FROM MTL_SYSTEM_ITEMS_B
        WHERE INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
        AND ORGANIZATION_ID = B.ORGANIZATION_ID
       ) AS ITEM_DESC,
      
        B.FROM_SUBINVENTORY_CODE, B.TO_SUBINVENTORY_CODE,
       
        CASE
            WHEN (SELECT SUM(TRANSACTION_QUANTITY) FROM MTL_MATERIAL_TRANSACTIONS WHERE MOVE_ORDER_LINE_ID = B.LINE_ID) < 0 THEN B.QUANTITY
            WHEN (Y.TRANSACTION_QUANTITY IS NOT NULL) OR (Y.TRANSACTION_QUANTITY <> '') THEN Y.TRANSACTION_QUANTITY
            WHEN (X.TRANSACTION_QUANTITY IS NOT NULL) OR (X.TRANSACTION_QUANTITY <> '') THEN X.TRANSACTION_QUANTITY
        ELSE B.QUANTITY
        END  AS QUANTITY,
       
       
        B.UOM_CODE,
       
        CASE
            WHEN X.TRANSACTION_QUANTITY IS NULL THEN
                 B.LOT_NUMBER
            ELSE
                 Y.LOT_NUMBER
        END AS LOT_NUMBER,
        
        DECODE (LINE_STATUS
                       , '1', 'Incomplete'
                       , '2', 'Pending Approval'
                       , '3', 'Approved'
                       , '4', 'Not Approved'
                       , '5', 'Closed'
                       , '6', 'Canceled'
                       , '7', 'Pre Approved'
                       , '8', 'Partially Approved'
                       , '9', 'Canceled by Source'
               ) AS LINE_STATUS
FROM MTL_TXN_REQUEST_HEADERS A, MTL_TXN_REQUEST_LINES B, MFG_LOOKUPS C, MFG_LOOKUPS D,
     HR_ALL_ORGANIZATION_UNITS E, HR_LOCATIONS_ALL F, MTL_MATERIAL_TRANSACTIONS X,
     MTL_TRANSACTION_LOT_NUMBERS Y
WHERE A.HEADER_ID = B.HEADER_ID
AND C.LOOKUP_TYPE = 'MTL_TXN_REQUEST_STATUS'
AND C.LOOKUP_CODE = TO_CHAR (B.LINE_STATUS)
AND D.LOOKUP_TYPE = 'MOVE_ORDER_TYPE'
AND D.LOOKUP_CODE = TO_CHAR (A.MOVE_ORDER_TYPE)
AND A.ORGANIZATION_ID = E.ORGANIZATION_ID
AND E.LOCATION_ID = F.LOCATION_ID
AND X.TRANSACTION_ID  = Y.TRANSACTION_ID(+)
AND B.LINE_ID = X.move_order_line_id(+)
AND A.ORGANIZATION_ID = :ORGANIZATION_ID
AND A.TRANSACTION_TYPE_ID = 127
and B.TO_SUBINVENTORY_CODE = 'ADP-PRD-06'
--AND A.REQUEST_NUMBER BETWEEN :REQUEST_NUMBER1 AND :REQUEST_NUMBER2
AND A.DATE_REQUIRED BETWEEN TRUNC(TO_DATE(:TGL1, 'RRRR/MM/DD HH24:MI:SS')) AND TRUNC(TO_DATE(:TGL2, 'RRRR/MM/DD HH24:MI:SS'))
order by A.DATE_REQUIRED asc