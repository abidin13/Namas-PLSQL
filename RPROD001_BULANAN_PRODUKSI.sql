Select
to_char(TO_DATE(:from_date,'RRRR/MM/DD HH24:MI:SS'),'DD/MM/YYYY') AS FROMDATE,
to_char(TO_DATE(:to_date,'RRRR/MM/DD HH24:MI:SS'),'DD/MM/YYYY') AS TODATE, 
(SELECT NAME
         FROM HR_ALL_ORGANIZATION_UNITS
         WHERE ORGANIZATION_ID = A.ORGANIZATION_ID
        ) OU,
        (SELECT HLA.DESCRIPTION  
         FROM HR_LOCATIONS_ALL HLA, HR_ALL_ORGANIZATION_UNITS HAOU 
         WHERE HLA.LOCATION_ID = HAOU.LOCATION_ID 
         AND HAOU.ORGANIZATION_ID = A.ORGANIZATION_ID
        ) AS DESCRIPTION, 
        (SELECT hla.address_line_1 || ' ' || hla.address_line_2 || ' - ' || hla.address_line_3 
         FROM HR_LOCATIONS_ALL HLA, HR_ALL_ORGANIZATION_UNITS HAOU 
         WHERE HLA.LOCATION_ID = HAOU.LOCATION_ID 
         AND HAOU.ORGANIZATION_ID = A.ORGANIZATION_ID
         ) AS ADDRESS2,
         (SELECT HLA.ADDRESS_LINE_3 
          FROM    HR_LOCATIONS_ALL HLA, HR_ALL_ORGANIZATION_UNITS HAOU 
          WHERE   HLA.LOCATION_ID = HAOU.LOCATION_ID 
          AND     HAOU.ORGANIZATION_ID = A.ORGANIZATION_ID
         ) AS ADDRESS3, 
         (SELECT HLA.POSTAL_CODE alamat1 
          FROM   HR_LOCATIONS_ALL HLA, HR_ALL_ORGANIZATION_UNITS HAOU 
          WHERE  HLA.LOCATION_ID = HAOU.LOCATION_ID 
          AND HAOU.ORGANIZATION_ID = A.ORGANIZATION_ID
         ) AS POSTAL_CODE,
        (SELECT hla.telephone_number_1 tlp1 
         FROM   HR_LOCATIONS_ALL HLA, HR_ALL_ORGANIZATION_UNITS HAOU 
         WHERE  HLA.LOCATION_ID = HAOU.LOCATION_ID 
         AND    HAOU.ORGANIZATION_ID = A.ORGANIZATION_ID
        ) AS TLP1,
        (SELECT HLA.TELEPHONE_NUMBER_2 
         FROM   HR_LOCATIONS_ALL HLA, HR_ALL_ORGANIZATION_UNITS HAOU 
         WHERE  HLA.LOCATION_ID = HAOU.LOCATION_ID 
         AND HAOU.ORGANIZATION_ID = A.ORGANIZATION_ID
        ) AS TLP2,
d.segment1
                 || '-'
                 || d.segment2
                 || '-'
                 || d.segment3
                 || '-'
                 || d.segment4
                 || '-'
                 || d.segment5 as item_code, c.INVENTORY_ITEM_ID,d.description,decode(c.line_type,-1,'Ingredient',1,'Product','By-Product') Type,
sum(e.TRANSACTION_QUANTITY) quantity, c.DTL_UM, 
CASE
WHEN D.SEGMENT1 = 'FGP' AND C.LINE_TYPE = 1
THEN YNP_RJT_PCS2(C.INVENTORY_ITEM_ID,A.ORGANIZATION_ID,:from_date,:to_date)
END AS RJT_PCS,
CASE
WHEN D.SEGMENT1 = 'FGP' AND C.LINE_TYPE = 1
THEN YNP_RJT_PCS3(C.INVENTORY_ITEM_ID,A.ORGANIZATION_ID,:from_date,:to_date)
END AS RJT_START_UP
from apps.GME_BATCH_HEADER a,apps.gmd_recipes b,gmd_recipe_validity_rules grr,apps.gme_material_details c,apps.mtl_system_items_kfv d,apps.mtl_material_transactions e
where a.FORMULA_ID=b.FORMULA_ID
and a.ROUTING_ID=b.ROUTING_ID
and a.RECIPE_VALIDITY_RULE_ID=grr.RECIPE_VALIDITY_RULE_ID
and grr.RECIPE_ID=b.recipe_id
and a.BATCH_ID=c.BATCH_ID
and a.ORGANIZATION_ID=c.ORGANIZATION_ID
and c.INVENTORY_ITEM_ID=d.INVENTORY_ITEM_ID
and c.ORGANIZATION_ID=d.organization_id
and a.batch_id=e.TRANSACTION_SOURCE_ID
and c.material_detail_id = e.trx_source_line_id
and a.ORGANIZATION_ID=e.ORGANIZATION_ID
and c.INVENTORY_ITEM_ID=e.INVENTORY_ITEM_ID
and a.batch_no in (SELECT distinct batch_no
  FROM apps.gme_batch_header gbh,
  gme_material_details gmd,
  mtl_system_items_kfv msik
 WHERE TRUNC (actual_cmplt_date) BETWEEN TO_DATE (:from_date,
                                                  'RRRR/MM/DD HH24:MI:SS'
                                                 )
                                     AND TO_DATE (:TO_DATE,
                                                  'RRRR/MM/DD HH24:MI:SS'
                                                 )
and gbh.BATCH_ID = gmd.BATCH_ID
and gbh.ORGANIZATION_ID = gmd.ORGANIZATION_ID
and gbh.ORGANIZATION_ID = gmd.ORGANIZATION_ID
and gmd.INVENTORY_ITEM_ID = msik.INVENTORY_ITEM_ID
and gmd.ORGANIZATION_ID = msik.ORGANIZATION_ID
and (MSIK.CONCATENATED_SEGMENTS = :p_item_code or :p_item_code is null)
and msik.DESCRIPTION LIKE NVL('%'||:p_item_desc||'%','%'))
and a.ORGANIZATION_ID=:your_org_id
AND SUBSTR(B.RECIPE_NO,1,7) LIKE NVL(:TYPE_PRODUK,'%') 
AND SUBSTR(B.RECIPE_NO,1,18) LIKE NVL(:RECIPE_DETAIL,'%')
--AND (D.CONCATENATED_SEGMENTS = :P_ITEM_CODE OR :P_ITEM_CODE IS NULL)
--AND D.DESCRIPTION LIKE NVL(:P_ITEM_DESC,'%') 
---AND B.RECIPE_NO LIKE NVL(:RECIPE_DETAIL,'%')
---AND (SUBSTR(B.RECIPE_NO,1,7) = :TYPE_PRODUK or :TYPE_PRODUK IS NULL) 
---AND (B.RECIPE_NO = :RECIPE_DETAIL OR :RECIPE_DETAIL IS NULL)
--TRUNC(TO_DATE (:TGL1,'RRRR/MM/DD HH24:MI:SS'))
and trunc(e.transaction_date) between to_date(:from_date,'RRRR/MM/DD HH24:MI:SS') and to_date(:to_date,'RRRR/MM/DD HH24:MI:SS')
group by a.organization_id, d.segment1
                 || '-'
                 || d.segment2
                 || '-'
                 || d.segment3
                 || '-'
                 || d.segment4
                 || '-'
                 || d.segment5,c.INVENTORY_ITEM_ID,d.description,c.line_type, c.DTL_UM, D.SEGMENT1
order by c.line_type