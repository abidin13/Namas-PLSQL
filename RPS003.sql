SELECT * FROM (

SELECT *
  FROM (SELECT A.BATCH_NO, A.RECIPE_VALIDITY_RULE_ID, A.FORMULA_ID,
               A.ROUTING_ID,
               (SELECT B.RECIPE_DESCRIPTION
                  FROM APPS.GME_BATCH_HEADER AA,
                       APPS.GMD_RECIPES B,
                       GMD_RECIPE_VALIDITY_RULES GRR
                 WHERE AA.FORMULA_ID = B.FORMULA_ID
                   AND AA.RECIPE_VALIDITY_RULE_ID =
                                                   GRR.RECIPE_VALIDITY_RULE_ID
                   AND GRR.RECIPE_ID = B.RECIPE_ID
                   AND AA.BATCH_ID = A.BATCH_ID) AS RECIPE_DESC,
               (SELECT B.RECIPE_NO
                  FROM APPS.GME_BATCH_HEADER AA,
                       APPS.GMD_RECIPES B,
                       GMD_RECIPE_VALIDITY_RULES GRR
                 WHERE AA.FORMULA_ID = B.FORMULA_ID
                   AND AA.RECIPE_VALIDITY_RULE_ID =
                                                   GRR.RECIPE_VALIDITY_RULE_ID
                   AND GRR.RECIPE_ID = B.RECIPE_ID
                   AND AA.BATCH_ID = A.BATCH_ID) AS RECIPE,
               (SELECT B.RECIPE_VERSION
                  FROM APPS.GME_BATCH_HEADER AA,
                       APPS.GMD_RECIPES B,
                       GMD_RECIPE_VALIDITY_RULES GRR
                 WHERE AA.FORMULA_ID = B.FORMULA_ID
                   AND AA.RECIPE_VALIDITY_RULE_ID =
                                                   GRR.RECIPE_VALIDITY_RULE_ID
                   AND GRR.RECIPE_ID = B.RECIPE_ID
                   AND AA.BATCH_ID = A.BATCH_ID) AS RECIPE_VER,
               DECODE (A.BATCH_STATUS,
                       -1, 'CANCELLED',
                       1, 'PENDING',
                       2, 'WIP',
                       3, 'COMPLETED',
                       4, 'CLOSED'
                      ) AS BATCH_STATUS,
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
                 WHERE F.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
                   AND F.ORGANIZATION_ID = B.ORGANIZATION_ID) AS ITEM,
               (SELECT A.DESCRIPTION
                  FROM MTL_SYSTEM_ITEMS A
                 WHERE A.INVENTORY_ITEM_ID =
                                       B.INVENTORY_ITEM_ID
                   AND A.ORGANIZATION_ID = B.ORGANIZATION_ID)
                                                           AS ITEMDESCRIPTION,
               C.ROUTING_NO, C.ROUTING_DESC, C.ROUTING_VERS, D.FORMULA_DESC1,
               D.FORMULA_VERS, B.LINE_TYPE,
               DECODE (B.LINE_TYPE,
                       -1, 'INGREDIENTS',
                       1, 'PRODUCT',
                       2, 'BY-PRODUCT'
                      ) AS TYPE,
               F.SUBINVENTORY_CODE, B.LINE_NO AS NO,
               B.PLAN_QTY AS PLANNED_QTY, B.WIP_PLAN_QTY AS WIP_PLAN_QTY,
               B.ACTUAL_QTY AS ACTUAL_QTY, G.LOT_NUMBER,
               CASE
                  WHEN B.LINE_TYPE = 2
                     THEN B.ACTUAL_QTY
                  ELSE G.TRANSACTION_QUANTITY
               END AS TRANSACTION_QUANTITY,
               
               --G.PRIMARY_QUANTITY AS PQ,
               B.DTL_UM AS UOM,
               TO_CHAR (A.PLAN_START_DATE,
                        'MM/DD/RRRR HH24:MI:SS'
                       ) AS PLAN_START_DATE,
               TO_CHAR (A.PLAN_CMPLT_DATE,
                        'MM/DD/RRRR HH24:MI:SS'
                       ) AS PLAN_CMPLT_DATE,
               TO_CHAR (A.ACTUAL_START_DATE,
                        'MM/DD/RRRR HH24:MI:SS'
                       ) AS ACTUAL_START_DATE,
               TO_CHAR (A.ACTUAL_CMPLT_DATE,
                        'MM/DD/RRRR HH24:MI:SS'
                       ) AS ACTUAL_CMPLT_DATE,
               TO_CHAR (A.BATCH_CLOSE_DATE,
                        'MM/DD/RRRR HH24:MI:SS'
                       ) AS BATCH_CLOSE_DATE,
               DECODE (A.ORGANIZATION_ID,
                       91, 'BANDUNG',
                       98, 'BANDUNG',
                       105, 'BANDUNG',
                       112, 'BANDUNG',
                       119, 'LAMPUNG',
                       153, 'MEDAN',
                       162, 'SOLO',
                       171, 'SENTUL',
                       194, 'SURABAYA',
                       213, 'BALI',
                       231, 'MANADO'
                      ) AS PLANT
          FROM GME_BATCH_HEADER A,
               GME_MATERIAL_DETAILS B,
               GMD_ROUTINGS_VL C,
               FM_FORM_MST_VL D,
               MTL_MATERIAL_TRANSACTIONS F,
               MTL_TRANSACTION_LOT_NUMBERS G
         WHERE A.BATCH_ID = B.BATCH_ID
           AND A.ROUTING_ID = C.ROUTING_ID(+)
           AND A.FORMULA_ID = D.FORMULA_ID
           AND B.INVENTORY_ITEM_ID = F.INVENTORY_ITEM_ID(+)
           AND B.MATERIAL_DETAIL_ID = F.TRX_SOURCE_LINE_ID(+)
           AND F.TRANSACTION_ID = G.TRANSACTION_ID(+)
           AND F.ORGANIZATION_ID = G.ORGANIZATION_ID(+)
           AND F.INVENTORY_ITEM_ID = G.INVENTORY_ITEM_ID(+)
           AND (   G.TRANSACTION_SOURCE_TYPE_ID = 5
                OR G.TRANSACTION_SOURCE_TYPE_ID IS NULL
               )
           AND A.ORGANIZATION_ID = :IO
           AND A.BATCH_TYPE <> 10
           AND A.BATCH_STATUS = NVL (:BATCH_STATUS, A.BATCH_STATUS)
           AND (TRUNC (A.ACTUAL_START_DATE)
                   BETWEEN TO_DATE (:FROM_DATE, 'RRRR/MM/DD HH24:MI:SS')
                       AND TO_DATE (:TO_DATE, 'RRRR/MM/DD HH24:MI:SS')
               --OR A.BATCH_NO BETWEEN :FROM_BATCH_NO AND :TO_BATCH_NO
               )
     --AND SUBSTR(D.FORMULA_NO, 5,3)=:ITEM
--     AND B.LINE_TYPE = 2
        UNION ALL
        SELECT A.BATCH_NO, A.RECIPE_VALIDITY_RULE_ID, A.FORMULA_ID,
               A.ROUTING_ID,
               (SELECT B.RECIPE_DESCRIPTION
                  FROM APPS.GME_BATCH_HEADER AA,
                       APPS.GMD_RECIPES B,
                       GMD_RECIPE_VALIDITY_RULES GRR
                 WHERE AA.FORMULA_ID = B.FORMULA_ID
                   AND AA.RECIPE_VALIDITY_RULE_ID =
                                                   GRR.RECIPE_VALIDITY_RULE_ID
                   AND GRR.RECIPE_ID = B.RECIPE_ID
                   AND AA.BATCH_ID = A.BATCH_ID) AS RECIPE_DESC,
               (SELECT B.RECIPE_NO
                  FROM APPS.GME_BATCH_HEADER AA,
                       APPS.GMD_RECIPES B,
                       GMD_RECIPE_VALIDITY_RULES GRR
                 WHERE AA.FORMULA_ID = B.FORMULA_ID
                   AND AA.RECIPE_VALIDITY_RULE_ID =
                                                   GRR.RECIPE_VALIDITY_RULE_ID
                   AND GRR.RECIPE_ID = B.RECIPE_ID
                   AND AA.BATCH_ID = A.BATCH_ID) AS RECIPE,
               (SELECT B.RECIPE_VERSION
                  FROM APPS.GME_BATCH_HEADER AA,
                       APPS.GMD_RECIPES B,
                       GMD_RECIPE_VALIDITY_RULES GRR
                 WHERE AA.FORMULA_ID = B.FORMULA_ID
                   AND AA.RECIPE_VALIDITY_RULE_ID =
                                                   GRR.RECIPE_VALIDITY_RULE_ID
                   AND GRR.RECIPE_ID = B.RECIPE_ID
                   AND AA.BATCH_ID = A.BATCH_ID) AS RECIPE_VER,
               DECODE (A.BATCH_STATUS,
                       -1, 'CANCELLED',
                       1, 'PENDING',
                       2, 'WIP',
                       3, 'COMPLETED',
                       4, 'CLOSED'
                      ) AS BATCH_STATUS,
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
                 WHERE F.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
                   AND F.ORGANIZATION_ID = B.ORGANIZATION_ID) AS ITEM,
               (SELECT A.DESCRIPTION
                  FROM MTL_SYSTEM_ITEMS A
                 WHERE A.INVENTORY_ITEM_ID =
                                       B.INVENTORY_ITEM_ID
                   AND A.ORGANIZATION_ID = B.ORGANIZATION_ID)
                                                           AS ITEMDESCRIPTION,
               C.ROUTING_NO, C.ROUTING_DESC, C.ROUTING_VERS, D.FORMULA_DESC1,
               D.FORMULA_VERS, B.LINE_TYPE,
               DECODE (B.LINE_TYPE,
                       -1, 'INGREDIENTS',
                       1, 'PRODUCT',
                       2, 'BY-PRODUCT'
                      ) AS TYPE,
               F.SUBINVENTORY_CODE, B.LINE_NO AS NO,
               B.PLAN_QTY AS PLANNED_QTY, B.WIP_PLAN_QTY AS WIP_PLAN_QTY,
               B.ACTUAL_QTY AS ACTUAL_QTY, G.LOT_NUMBER,
               CASE
                  WHEN B.LINE_TYPE = 2
                     THEN B.ACTUAL_QTY
                  ELSE G.TRANSACTION_QUANTITY
               END AS TRANSACTION_QUANTITY,
               
               --G.PRIMARY_QUANTITY AS PQ,
               B.DTL_UM AS UOM,
               TO_CHAR (A.PLAN_START_DATE,
                        'MM/DD/RRRR HH24:MI:SS'
                       ) AS PLAN_START_DATE,
               TO_CHAR (A.PLAN_CMPLT_DATE,
                        'MM/DD/RRRR HH24:MI:SS'
                       ) AS PLAN_CMPLT_DATE,
               TO_CHAR (A.ACTUAL_START_DATE,
                        'MM/DD/RRRR HH24:MI:SS'
                       ) AS ACTUAL_START_DATE,
               TO_CHAR (A.ACTUAL_CMPLT_DATE,
                        'MM/DD/RRRR HH24:MI:SS'
                       ) AS ACTUAL_CMPLT_DATE,
               TO_CHAR (A.BATCH_CLOSE_DATE,
                        'MM/DD/RRRR HH24:MI:SS'
                       ) AS BATCH_CLOSE_DATE,
               DECODE (A.ORGANIZATION_ID,
                       91, 'BANDUNG',
                       98, 'BANDUNG',
                       105, 'BANDUNG',
                       112, 'BANDUNG',
                       119, 'LAMPUNG',
                       153, 'MEDAN',
                       162, 'SOLO',
                       171, 'SENTUL',
                       194, 'SURABAYA',
                       213, 'BALI',
                       231, 'MANADO'
                      ) AS PLANT
          FROM GME_BATCH_HEADER A,
               GME_MATERIAL_DETAILS B,
               GMD_ROUTINGS_VL C,
               FM_FORM_MST_VL D,
               MTL_MATERIAL_TRANSACTIONS F,
               MTL_TRANSACTION_LOT_NUMBERS G
         WHERE A.BATCH_ID = B.BATCH_ID
           AND A.ROUTING_ID = C.ROUTING_ID(+)
           AND A.FORMULA_ID = D.FORMULA_ID
           AND B.INVENTORY_ITEM_ID = F.INVENTORY_ITEM_ID(+)
           AND B.MATERIAL_DETAIL_ID = F.TRX_SOURCE_LINE_ID(+)
           AND F.TRANSACTION_ID = G.TRANSACTION_ID(+)
           AND F.ORGANIZATION_ID = G.ORGANIZATION_ID(+)
           AND F.INVENTORY_ITEM_ID = G.INVENTORY_ITEM_ID(+)
           AND (   G.TRANSACTION_SOURCE_TYPE_ID = 5
                OR G.TRANSACTION_SOURCE_TYPE_ID IS NULL
               )
           AND A.ORGANIZATION_ID = :IO
           AND A.BATCH_TYPE <> 10
           AND A.BATCH_STATUS = NVL (:BATCH_STATUS, A.BATCH_STATUS)
           AND A.ORGANIZATION_ID IN
                             (91, 98, 105, 112, 119, 153, 162, 171, 194, 273)
           AND   (TO_CHAR (A.ACTUAL_START_DATE, 'HH24') * 60)
               + TO_CHAR (A.ACTUAL_START_DATE, 'MI') BETWEEN 1350 AND 1439
           AND TRUNC (A.ACTUAL_START_DATE) =
                      TRUNC (TO_DATE (:FROM_DATE, 'RRRR/MM/DD HH24:MI:SS') - 1)
     --AND SUBSTR(D.FORMULA_NO, 5,3)=:ITEM
--     AND B.LINE_TYPE = 2
        UNION ALL
        SELECT A.BATCH_NO, A.RECIPE_VALIDITY_RULE_ID, A.FORMULA_ID,
               A.ROUTING_ID,
               (SELECT B.RECIPE_DESCRIPTION
                  FROM APPS.GME_BATCH_HEADER AA,
                       APPS.GMD_RECIPES B,
                       GMD_RECIPE_VALIDITY_RULES GRR
                 WHERE AA.FORMULA_ID = B.FORMULA_ID
                   AND AA.RECIPE_VALIDITY_RULE_ID =
                                                   GRR.RECIPE_VALIDITY_RULE_ID
                   AND GRR.RECIPE_ID = B.RECIPE_ID
                   AND AA.BATCH_ID = A.BATCH_ID) AS RECIPE_DESC,
               (SELECT B.RECIPE_NO
                  FROM APPS.GME_BATCH_HEADER AA,
                       APPS.GMD_RECIPES B,
                       GMD_RECIPE_VALIDITY_RULES GRR
                 WHERE AA.FORMULA_ID = B.FORMULA_ID
                   AND AA.RECIPE_VALIDITY_RULE_ID =
                                                   GRR.RECIPE_VALIDITY_RULE_ID
                   AND GRR.RECIPE_ID = B.RECIPE_ID
                   AND AA.BATCH_ID = A.BATCH_ID) AS RECIPE,
               (SELECT B.RECIPE_VERSION
                  FROM APPS.GME_BATCH_HEADER AA,
                       APPS.GMD_RECIPES B,
                       GMD_RECIPE_VALIDITY_RULES GRR
                 WHERE AA.FORMULA_ID = B.FORMULA_ID
                   AND AA.RECIPE_VALIDITY_RULE_ID =
                                                   GRR.RECIPE_VALIDITY_RULE_ID
                   AND GRR.RECIPE_ID = B.RECIPE_ID
                   AND AA.BATCH_ID = A.BATCH_ID) AS RECIPE_VER,
               DECODE (A.BATCH_STATUS,
                       -1, 'CANCELLED',
                       1, 'PENDING',
                       2, 'WIP',
                       3, 'COMPLETED',
                       4, 'CLOSED'
                      ) AS BATCH_STATUS,
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
                 WHERE F.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
                   AND F.ORGANIZATION_ID = B.ORGANIZATION_ID) AS ITEM,
               (SELECT A.DESCRIPTION
                  FROM MTL_SYSTEM_ITEMS A
                 WHERE A.INVENTORY_ITEM_ID =
                                       B.INVENTORY_ITEM_ID
                   AND A.ORGANIZATION_ID = B.ORGANIZATION_ID)
                                                           AS ITEMDESCRIPTION,
               C.ROUTING_NO, C.ROUTING_DESC, C.ROUTING_VERS, D.FORMULA_DESC1,
               D.FORMULA_VERS, B.LINE_TYPE,
               DECODE (B.LINE_TYPE,
                       -1, 'INGREDIENTS',
                       1, 'PRODUCT',
                       2, 'BY-PRODUCT'
                      ) AS TYPE,
               F.SUBINVENTORY_CODE, B.LINE_NO AS NO,
               B.PLAN_QTY AS PLANNED_QTY, B.WIP_PLAN_QTY AS WIP_PLAN_QTY,
               B.ACTUAL_QTY AS ACTUAL_QTY, G.LOT_NUMBER,
               CASE
                  WHEN B.LINE_TYPE = 2
                     THEN B.ACTUAL_QTY
                  ELSE G.TRANSACTION_QUANTITY
               END AS TRANSACTION_QUANTITY,
               
               --G.PRIMARY_QUANTITY AS PQ,
               B.DTL_UM AS UOM,
               TO_CHAR (A.PLAN_START_DATE,
                        'MM/DD/RRRR HH24:MI:SS'
                       ) AS PLAN_START_DATE,
               TO_CHAR (A.PLAN_CMPLT_DATE,
                        'MM/DD/RRRR HH24:MI:SS'
                       ) AS PLAN_CMPLT_DATE,
               TO_CHAR (A.ACTUAL_START_DATE,
                        'MM/DD/RRRR HH24:MI:SS'
                       ) AS ACTUAL_START_DATE,
               TO_CHAR (A.ACTUAL_CMPLT_DATE,
                        'MM/DD/RRRR HH24:MI:SS'
                       ) AS ACTUAL_CMPLT_DATE,
               TO_CHAR (A.BATCH_CLOSE_DATE,
                        'MM/DD/RRRR HH24:MI:SS'
                       ) AS BATCH_CLOSE_DATE,
               DECODE (A.ORGANIZATION_ID,
                       91, 'BANDUNG',
                       98, 'BANDUNG',
                       105, 'BANDUNG',
                       112, 'BANDUNG',
                       119, 'LAMPUNG',
                       153, 'MEDAN',
                       162, 'SOLO',
                       171, 'SENTUL',
                       194, 'SURABAYA',
                       213, 'BALI',
                       231, 'MANADO'
                      ) AS PLANT
          FROM GME_BATCH_HEADER A,
               GME_MATERIAL_DETAILS B,
               GMD_ROUTINGS_VL C,
               FM_FORM_MST_VL D,
               MTL_MATERIAL_TRANSACTIONS F,
               MTL_TRANSACTION_LOT_NUMBERS G
         WHERE A.BATCH_ID = B.BATCH_ID
           AND A.ROUTING_ID = C.ROUTING_ID(+)
           AND A.FORMULA_ID = D.FORMULA_ID
           AND B.INVENTORY_ITEM_ID = F.INVENTORY_ITEM_ID(+)
           AND B.MATERIAL_DETAIL_ID = F.TRX_SOURCE_LINE_ID(+)
           AND F.TRANSACTION_ID = G.TRANSACTION_ID(+)
           AND F.ORGANIZATION_ID = G.ORGANIZATION_ID(+)
           AND F.INVENTORY_ITEM_ID = G.INVENTORY_ITEM_ID(+)
           AND (   G.TRANSACTION_SOURCE_TYPE_ID = 5
                OR G.TRANSACTION_SOURCE_TYPE_ID IS NULL
               )
           AND A.ORGANIZATION_ID = :IO
           AND A.BATCH_TYPE <> 10
           AND A.BATCH_STATUS = NVL (:BATCH_STATUS, A.BATCH_STATUS)
           AND A.ORGANIZATION_ID IN (213, 231)
           AND   (TO_CHAR (A.ACTUAL_START_DATE, 'HH24') * 60)
               + TO_CHAR (A.ACTUAL_START_DATE, 'MI')
               + 60 BETWEEN 1410 AND 1499
           AND TRUNC (A.ACTUAL_START_DATE) =
                      TRUNC (TO_DATE (:FROM_DATE, 'RRRR/MM/DD HH24:MI:SS') - 1)
     --AND SUBSTR(D.FORMULA_NO, 5,3)=:ITEM
--     AND B.LINE_TYPE = 2
       )
MINUS
SELECT * FROM (
 SELECT   A.BATCH_NO, A.RECIPE_VALIDITY_RULE_ID, A.FORMULA_ID, A.ROUTING_ID,
         (SELECT B.RECIPE_DESCRIPTION
            FROM APPS.GME_BATCH_HEADER AA,
                 APPS.GMD_RECIPES B,
                 GMD_RECIPE_VALIDITY_RULES GRR
           WHERE AA.FORMULA_ID = B.FORMULA_ID
             AND AA.RECIPE_VALIDITY_RULE_ID = GRR.RECIPE_VALIDITY_RULE_ID
             AND GRR.RECIPE_ID = B.RECIPE_ID
             AND AA.BATCH_ID = A.BATCH_ID) AS RECIPE_DESC,
         (SELECT B.RECIPE_NO
            FROM APPS.GME_BATCH_HEADER AA,
                 APPS.GMD_RECIPES B,
                 GMD_RECIPE_VALIDITY_RULES GRR
           WHERE AA.FORMULA_ID = B.FORMULA_ID
             AND AA.RECIPE_VALIDITY_RULE_ID = GRR.RECIPE_VALIDITY_RULE_ID
             AND GRR.RECIPE_ID = B.RECIPE_ID
             AND AA.BATCH_ID = A.BATCH_ID) AS RECIPE,
         (SELECT B.RECIPE_VERSION
            FROM APPS.GME_BATCH_HEADER AA,
                 APPS.GMD_RECIPES B,
                 GMD_RECIPE_VALIDITY_RULES GRR
           WHERE AA.FORMULA_ID = B.FORMULA_ID
             AND AA.RECIPE_VALIDITY_RULE_ID = GRR.RECIPE_VALIDITY_RULE_ID
             AND GRR.RECIPE_ID = B.RECIPE_ID
             AND AA.BATCH_ID = A.BATCH_ID) AS RECIPE_VER,
         
         DECODE (A.BATCH_STATUS,
                 -1, 'CANCELLED',
                 1, 'PENDING',
                 2, 'WIP',
                 3, 'COMPLETED',
                 4, 'CLOSED'
                ) AS BATCH_STATUS,
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
           WHERE F.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
             AND F.ORGANIZATION_ID = B.ORGANIZATION_ID) AS ITEM,
         (SELECT A.DESCRIPTION
            FROM MTL_SYSTEM_ITEMS A
           WHERE A.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
             AND A.ORGANIZATION_ID = B.ORGANIZATION_ID) AS ITEMDESCRIPTION,
         C.ROUTING_NO, C.ROUTING_DESC, C.ROUTING_VERS, D.FORMULA_DESC1,
         D.FORMULA_VERS, B.LINE_TYPE,
         DECODE (B.LINE_TYPE,
                 -1, 'INGREDIENTS',
                 1, 'PRODUCT',
                 2, 'BY-PRODUCT'
                ) AS TYPE,
         F.SUBINVENTORY_CODE,
         B.LINE_NO AS NO, B.PLAN_QTY AS PLANNED_QTY,
         B.WIP_PLAN_QTY AS WIP_PLAN_QTY, B.ACTUAL_QTY AS ACTUAL_QTY,
         G.LOT_NUMBER,
                      CASE 
                        WHEN B.LINE_TYPE = 2 THEN
                            B.ACTUAL_QTY
                        ELSE
                            G.TRANSACTION_QUANTITY
                        END AS TRANSACTION_QUANTITY ,
                      --G.PRIMARY_QUANTITY AS PQ,
                      B.DTL_UM AS UOM,
                      TO_CHAR(A.PLAN_START_DATE,'MM/DD/RRRR HH24:MI:SS') AS PLAN_START_DATE,
                      TO_CHAR(A.PLAN_CMPLT_DATE,'MM/DD/RRRR HH24:MI:SS') AS PLAN_CMPLT_DATE,
                      TO_CHAR(A.ACTUAL_START_DATE,'MM/DD/RRRR HH24:MI:SS') AS ACTUAL_START_DATE,
                      TO_CHAR(A.ACTUAL_CMPLT_DATE,'MM/DD/RRRR HH24:MI:SS') AS ACTUAL_CMPLT_DATE,
                      TO_CHAR(A.BATCH_CLOSE_DATE,'MM/DD/RRRR HH24:MI:SS') AS BATCH_CLOSE_DATE,
         DECODE (A.ORGANIZATION_ID,
                 91, 'BANDUNG',
                 98, 'BANDUNG',
                 105, 'BANDUNG',
                 112, 'BANDUNG',
                 119, 'LAMPUNG',
                 153, 'MEDAN',
                 162, 'SOLO',
                 171, 'SENTUL',
                 194, 'SURABAYA',
                 213, 'BALI',
                 231, 'MANADO'
                ) AS PLANT
    FROM GME_BATCH_HEADER A,
         GME_MATERIAL_DETAILS B,
         GMD_ROUTINGS_VL C,
         FM_FORM_MST_VL D,
         MTL_MATERIAL_TRANSACTIONS F,
         MTL_TRANSACTION_LOT_NUMBERS G
   WHERE A.BATCH_ID = B.BATCH_ID
     AND A.ROUTING_ID = C.ROUTING_ID(+)
     AND A.FORMULA_ID = D.FORMULA_ID
     AND B.INVENTORY_ITEM_ID = F.INVENTORY_ITEM_ID(+)
     AND B.MATERIAL_DETAIL_ID = F.TRX_SOURCE_LINE_ID(+)
     AND F.TRANSACTION_ID = G.TRANSACTION_ID(+)
     AND F.ORGANIZATION_ID = G.ORGANIZATION_ID(+)
     AND F.INVENTORY_ITEM_ID = G.INVENTORY_ITEM_ID(+)
     AND (   G.TRANSACTION_SOURCE_TYPE_ID = 5
          OR G.TRANSACTION_SOURCE_TYPE_ID IS NULL
         )
     AND A.ORGANIZATION_ID = :IO
     AND A.BATCH_TYPE <> 10
     AND A.BATCH_STATUS = NVL(:BATCH_STATUS,A.BATCH_STATUS)
     AND A.ORGANIZATION_ID IN (91, 98, 105, 112, 119, 153, 162, 171, 194, 273)
     AND (TO_CHAR(A.ACTUAL_START_DATE, 'HH24')*60) + TO_CHAR(A.ACTUAL_START_DATE, 'MI') BETWEEN 1350 AND 1439
     AND TRUNC(A.ACTUAL_START_DATE) = TRUNC(TO_DATE (:TO_DATE, 'RRRR/MM/DD HH24:MI:SS')) 
     --AND SUBSTR(D.FORMULA_NO, 5,3)=:ITEM
--     AND B.LINE_TYPE = 2

UNION ALL

SELECT   A.BATCH_NO, A.RECIPE_VALIDITY_RULE_ID, A.FORMULA_ID, A.ROUTING_ID,
         (SELECT B.RECIPE_DESCRIPTION
            FROM APPS.GME_BATCH_HEADER AA,
                 APPS.GMD_RECIPES B,
                 GMD_RECIPE_VALIDITY_RULES GRR
           WHERE AA.FORMULA_ID = B.FORMULA_ID
             AND AA.RECIPE_VALIDITY_RULE_ID = GRR.RECIPE_VALIDITY_RULE_ID
             AND GRR.RECIPE_ID = B.RECIPE_ID
             AND AA.BATCH_ID = A.BATCH_ID) AS RECIPE_DESC,
         (SELECT B.RECIPE_NO
            FROM APPS.GME_BATCH_HEADER AA,
                 APPS.GMD_RECIPES B,
                 GMD_RECIPE_VALIDITY_RULES GRR
           WHERE AA.FORMULA_ID = B.FORMULA_ID
             AND AA.RECIPE_VALIDITY_RULE_ID = GRR.RECIPE_VALIDITY_RULE_ID
             AND GRR.RECIPE_ID = B.RECIPE_ID
             AND AA.BATCH_ID = A.BATCH_ID) AS RECIPE,
         (SELECT B.RECIPE_VERSION
            FROM APPS.GME_BATCH_HEADER AA,
                 APPS.GMD_RECIPES B,
                 GMD_RECIPE_VALIDITY_RULES GRR
           WHERE AA.FORMULA_ID = B.FORMULA_ID
             AND AA.RECIPE_VALIDITY_RULE_ID = GRR.RECIPE_VALIDITY_RULE_ID
             AND GRR.RECIPE_ID = B.RECIPE_ID
             AND AA.BATCH_ID = A.BATCH_ID) AS RECIPE_VER,
         
         DECODE (A.BATCH_STATUS,
                 -1, 'CANCELLED',
                 1, 'PENDING',
                 2, 'WIP',
                 3, 'COMPLETED',
                 4, 'CLOSED'
                ) AS BATCH_STATUS,
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
           WHERE F.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
             AND F.ORGANIZATION_ID = B.ORGANIZATION_ID) AS ITEM,
         (SELECT A.DESCRIPTION
            FROM MTL_SYSTEM_ITEMS A
           WHERE A.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
             AND A.ORGANIZATION_ID = B.ORGANIZATION_ID) AS ITEMDESCRIPTION,
         C.ROUTING_NO, C.ROUTING_DESC, C.ROUTING_VERS, D.FORMULA_DESC1,
         D.FORMULA_VERS, B.LINE_TYPE,
         DECODE (B.LINE_TYPE,
                 -1, 'INGREDIENTS',
                 1, 'PRODUCT',
                 2, 'BY-PRODUCT'
                ) AS TYPE,
         F.SUBINVENTORY_CODE,
         B.LINE_NO AS NO, B.PLAN_QTY AS PLANNED_QTY,
         B.WIP_PLAN_QTY AS WIP_PLAN_QTY, B.ACTUAL_QTY AS ACTUAL_QTY,
         G.LOT_NUMBER,
                      CASE 
                        WHEN B.LINE_TYPE = 2 THEN
                            B.ACTUAL_QTY
                        ELSE
                            G.TRANSACTION_QUANTITY
                        END AS TRANSACTION_QUANTITY ,
                      --G.PRIMARY_QUANTITY AS PQ,
                      B.DTL_UM AS UOM,
                      TO_CHAR(A.PLAN_START_DATE,'MM/DD/RRRR HH24:MI:SS') AS PLAN_START_DATE,
                      TO_CHAR(A.PLAN_CMPLT_DATE,'MM/DD/RRRR HH24:MI:SS') AS PLAN_CMPLT_DATE,
                      TO_CHAR(A.ACTUAL_START_DATE,'MM/DD/RRRR HH24:MI:SS') AS ACTUAL_START_DATE,
                      TO_CHAR(A.ACTUAL_CMPLT_DATE,'MM/DD/RRRR HH24:MI:SS') AS ACTUAL_CMPLT_DATE,
                      TO_CHAR(A.BATCH_CLOSE_DATE,'MM/DD/RRRR HH24:MI:SS') AS BATCH_CLOSE_DATE,
         DECODE (A.ORGANIZATION_ID,
                 91, 'BANDUNG',
                 98, 'BANDUNG',
                 105, 'BANDUNG',
                 112, 'BANDUNG',
                 119, 'LAMPUNG',
                 153, 'MEDAN',
                 162, 'SOLO',
                 171, 'SENTUL',
                 194, 'SURABAYA',
                 213, 'BALI',
                 231, 'MANADO'
                ) AS PLANT
    FROM GME_BATCH_HEADER A,
         GME_MATERIAL_DETAILS B,
         GMD_ROUTINGS_VL C,
         FM_FORM_MST_VL D,
         MTL_MATERIAL_TRANSACTIONS F,
         MTL_TRANSACTION_LOT_NUMBERS G
   WHERE A.BATCH_ID = B.BATCH_ID
     AND A.ROUTING_ID = C.ROUTING_ID(+)
     AND A.FORMULA_ID = D.FORMULA_ID
     AND B.INVENTORY_ITEM_ID = F.INVENTORY_ITEM_ID(+)
     AND B.MATERIAL_DETAIL_ID = F.TRX_SOURCE_LINE_ID(+)
     AND F.TRANSACTION_ID = G.TRANSACTION_ID(+)
     AND F.ORGANIZATION_ID = G.ORGANIZATION_ID(+)
     AND F.INVENTORY_ITEM_ID = G.INVENTORY_ITEM_ID(+)
     AND (   G.TRANSACTION_SOURCE_TYPE_ID = 5
          OR G.TRANSACTION_SOURCE_TYPE_ID IS NULL
         )
     AND A.ORGANIZATION_ID = :IO
     AND A.BATCH_TYPE <> 10
     AND A.BATCH_STATUS = NVL(:BATCH_STATUS,A.BATCH_STATUS)
     AND A.ORGANIZATION_ID IN (213,231)
     AND (TO_CHAR(A.ACTUAL_START_DATE, 'HH24')*60) + TO_CHAR(A.ACTUAL_START_DATE, 'MI')+60 BETWEEN 1410 AND 1499
     AND TRUNC(A.ACTUAL_START_DATE) = TRUNC(TO_DATE (:FROM_DATE, 'RRRR/MM/DD HH24:MI:SS')) 
     --AND SUBSTR(D.FORMULA_NO, 5,3)=:ITEM
--     AND B.LINE_TYPE = 2
    )
) XXX
ORDER BY XXX.BATCH_NO, XXX.LINE_TYPE, XXX.NO