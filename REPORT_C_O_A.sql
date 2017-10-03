select MP1.ORGANIZATION_CODE,
(MP1.ORGANIZATION_CODE||'/'||:p_sample_no) NO_DOC,
GS.SAMPLE_NO,
decode(:p_io,'AEP','NSP',
substr((SELECT haou.name
          FROM HR_ALL_ORGANIZATION_UNITS HAOU
         WHERE haou.organization_id = HOI.ORG_INFORMATION3),0,length((SELECT haou.name
          FROM HR_ALL_ORGANIZATION_UNITS HAOU
         WHERE haou.organization_id = HOI.ORG_INFORMATION3))-3))
          OU_NAME,
msi.segment1
       || '-'
       || msi.segment2
       || '-'
       || msi.segment3
       || '-'
       || msi.segment4
       || '-'
       || msi.segment5
          ITEM_CODE,
 nvl(MSI.long_DESCRIPTION,msi.description) description,
 YNP_MATERIAL(:p_material) Material,
CASE
                WHEN length(gs.lot_number) = 15 THEN (substr(gs.lot_number,0,8)||substr(gs.lot_number,11,length(gs.lot_number))) 
                WHEN length(gs.lot_number) = 14 AND (substr(gs.lot_number,-1,1) = '-')  THEN (substr(gs.lot_number,0,8)||substr(gs.lot_number,11,3))
                WHEN length(gs.lot_number) = 14 THEN (substr(gs.lot_number,0,8)||substr(gs.lot_number,11,length(gs.lot_number)))                
                WHEN length(gs.lot_number) = 13 THEN (substr(gs.lot_number,0,8)||substr(gs.lot_number,11,length(gs.lot_number)))
                ELSE gs.lot_number
 END AS Lot_number,
 GW.RECIPE_ID,
 GSPEC.SPEC_ID,
 GSPEC.ATTRIBUTE1,
 GSPEC.ATTRIBUTE2,
 GR.SEQ,
 GR.TEST_ID,
 GQV.TEST_DESC,
 --(select from  where GQV.TEST_CODE,
 GQV.TEST_CODE "TEST_CODE_ORI",
 GQV.ATTRIBUTE1 TEST_CODE,
 decode(GST.MIN_VALUE_NUM,null,GST.TARGET_VALUE_CHAR,GST.MIN_VALUE_NUM) MIN_VALUE,
 decode(GST.MAX_VALUE_NUM,null,GST.TARGET_VALUE_CHAR,GST.MAX_VALUE_NUM) MAX_VALUE,
 decode(GST.MIN_VALUE_NUM,null,GST.TARGET_VALUE_CHAR,null) TEMP,
 decode(GQV.TEST_UNIT,null,'-',GQV.TEST_UNIT) UOM,
 decode(GR.RESULT_VALUE_NUM,null,GR.RESULT_VALUE_CHAR,GR.RESULT_VALUE_NUM) RESULT,
 (SELECT HLA.TOWN_OR_CITY
                    FROM HR.HR_LOCATIONS_ALL HLA,
                         HR.HR_ALL_ORGANIZATION_UNITS HAOU
                   WHERE  HAOU.ORGANIZATION_ID=GS.ORGANIZATION_ID
                         AND HAOU.LOCATION_ID = HLA.LOCATION_ID                       
                         )||', '||to_char(sysdate,'dd Month YYYY') Location_and_Date,
(SELECT PPF.FULL_NAME
                 FROM  apps.per_people_F ppf
                   WHERE     --PPF.ATTRIBUTE6 = 'QA'
                         PERSON_ID = :p_approver
                         AND PPF.EFFECTIVE_END_DATE > SYSDATE) APPROVER,
 GW.SPEC_VR_STATUS,
 GW.SPEC_VR_ID,
 orginfo.organization_id,
 orginfo.registered_name,
 orginfo.address_line_1,
 orginfo.address_line_2,
 orginfo.postal_code,
 orginfo.telephone_number_1,
 orginfo.telephone_number_2,
 orginfo.telephone_number_3,
 orginfo.loc_information13,
 GS.SOURCE_COMMENT
 --FAV.FILE_NAME,
 --FAV.FUNCTION_NAME, 
 --length(FL.FILE_DATA) 
 --null IMAGE 
--getbase64(FL.FILE_DATA)
from
GMD.GMD_SAMPLES GS,
 INV.MTL_PARAMETERS MP1,
 hr_organization_information HOI,
 MTL_SYSTEM_ITEMS_FVL MSI,
 APPS.GMD_SPECIFICATIONS_VL GSPEC,
 GMD.gmd_wip_spec_vrs GW,
 GMD.gmd_results GR,
 APPS.GMD_QC_TESTS_VL GQV,
 APPS.GMD_SPEC_TESTS_VL GST,
 APPS.GMD_ALL_SPEC_VRS_VL GASV,
 (SELECT haou.organization_id
    , (SELECT gll.description
        FROM 
            (SELECT hou.organization_id, hou.set_of_books_id
             FROM hr_operating_units hou) ou
            , gl_ledgers gll
            , hr_organization_information haoi
        WHERE 1=1
            AND haoi.organization_id = haou.organization_id
            AND haoi.org_information3 = ou.organization_id
            AND ou.set_of_books_id = gll.ledger_id) registered_name
    , hla.address_line_1
    , hla.address_line_2
    , hla.postal_code
    , hla.telephone_number_1
    , hla.telephone_number_2
    , hla.telephone_number_3
    , hla.loc_information13
FROM hr_all_organization_units haou
    , hr_locations_all hla 
WHERE 1=1
    AND hla.location_id = haou.location_id) orginfo
 --APPS.FND_ATTACHED_DOCS_FORM_VL FAV,
 --APPLSYS.fnd_lobs fl
where
 GS.SAMPLE_NO = :p_sample_no --1011300079 -- W
 AND GS.SOURCE = 'W'
 AND MP1.ORGANIZATION_CODE = :p_io --'ABP'--:p_io
 AND orginfo.organization_id = mp1.organization_id
 AND MP1.ORGANIZATION_ID = GS.ORGANIZATION_ID
 AND HOI.ORGANIZATION_ID = GS.ORGANIZATION_ID
 AND HOI.ORG_INFORMATION2 NOT IN 'Y'
 AND GS.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
 AND GS.ORGANIZATION_ID = MSI.ORGANIZATION_ID
 AND GS.INVENTORY_ITEM_ID = GSPEC.INVENTORY_ITEM_ID
 AND GS.RECIPE_ID = GW.RECIPE_ID
 AND GW.SPEC_ID = GSPEC.SPEC_ID
 AND GR.SAMPLE_ID = GS.SAMPLE_ID
 AND GQV.TEST_ID = GR.TEST_ID
 AND GST.TEST_ID = GR.TEST_ID
 AND GST.SPEC_ID = GSPEC.SPEC_ID
 AND  GW.SPEC_VR_STATUS = '700'
 AND GST.SPEC_ID = GASV.SPEC_ID
 AND GS.ORGANIZATION_ID = GASV.ORGANIZATION_ID
 AND GS.SOURCE = GASV.SPEC_TYPE
 AND GS.RECIPE_ID = GASV.RECIPE_ID
 AND (GSPEC.SPEC_ID = :P_SPEC_ID OR :P_SPEC_ID is null)
 --AND FAV.PK1_VALUE(+) = GSPEC.SPEC_ID
 --AND FAV.FUNCTION_NAME(+) = 'GMDQSPEC'
 --AND FAV.MEDIA_ID = FL.FILE_ID(+)    
 --AND nvl(length(FL.FILE_DATA),0) =0  
 AND gs.step_no=gw.step_no
 AND GS.STEP_NO = GASV.STEP_NO
 AND GASV.SPEC_VR_ID = GW.SPEC_VR_ID
 AND gs.step_no is not null
 --AND GSPEC.ATTRIBUTE1 is not null  -- harus dihilangkan ketika akan dipakai di production
UNION ALL
--========================================================
-- UNTUK YANG TIDAK PUNYA STEPP NO
--=======================================================
select MP1.ORGANIZATION_CODE,
(MP1.ORGANIZATION_CODE||'/'||:p_sample_no) NO_DOC,
GS.SAMPLE_NO,
decode(:p_io,'AEP','NSP',
substr((SELECT haou.name
          FROM HR_ALL_ORGANIZATION_UNITS HAOU
         WHERE haou.organization_id = HOI.ORG_INFORMATION3),0,length((SELECT haou.name
          FROM HR_ALL_ORGANIZATION_UNITS HAOU
         WHERE haou.organization_id = HOI.ORG_INFORMATION3))-3))
          OU_NAME,
msi.segment1
       || '-'
       || msi.segment2
       || '-'
       || msi.segment3
       || '-'
       || msi.segment4
       || '-'
       || msi.segment5
          ITEM_CODE,
 nvl(MSI.long_DESCRIPTION,msi.description) description,
 YNP_MATERIAL(:p_material) Material,
CASE
                WHEN length(gs.lot_number) = 15 THEN (substr(gs.lot_number,0,8)||substr(gs.lot_number,11,length(gs.lot_number))) 
                WHEN length(gs.lot_number) = 14 AND (substr(gs.lot_number,-1,1) = '-')  THEN (substr(gs.lot_number,0,8)||substr(gs.lot_number,11,3))
                WHEN length(gs.lot_number) = 14 THEN (substr(gs.lot_number,0,8)||substr(gs.lot_number,11,length(gs.lot_number)))                
                WHEN length(gs.lot_number) = 13 THEN (substr(gs.lot_number,0,8)||substr(gs.lot_number,11,length(gs.lot_number)))
                ELSE gs.lot_number
 END AS Lot_number,
 GW.RECIPE_ID,
 GSPEC.SPEC_ID,
 GSPEC.ATTRIBUTE1,
 GSPEC.ATTRIBUTE2,
 GR.SEQ,
 GR.TEST_ID,
 GQV.TEST_DESC,
 --(select from  where GQV.TEST_CODE,
 GQV.TEST_CODE "TEST_CODE_ORI",
 GQV.ATTRIBUTE1 TEST_CODE,
 decode(GST.MIN_VALUE_NUM,null,GST.TARGET_VALUE_CHAR,GST.MIN_VALUE_NUM) MIN_VALUE,
 decode(GST.MAX_VALUE_NUM,null,GST.TARGET_VALUE_CHAR,GST.MAX_VALUE_NUM) MAX_VALUE,
 decode(GST.MIN_VALUE_NUM,null,GST.TARGET_VALUE_CHAR,null) TEMP,
 decode(GQV.TEST_UNIT,null,'-',GQV.TEST_UNIT) UOM,
 decode(GR.RESULT_VALUE_NUM,null,GR.RESULT_VALUE_CHAR,GR.RESULT_VALUE_NUM) RESULT,
 (SELECT HLA.TOWN_OR_CITY
                    FROM HR.HR_LOCATIONS_ALL HLA,
                         HR.HR_ALL_ORGANIZATION_UNITS HAOU
                   WHERE  HAOU.ORGANIZATION_ID=GS.ORGANIZATION_ID
                         AND HAOU.LOCATION_ID = HLA.LOCATION_ID                       
                         )||', '||to_char(sysdate,'dd Month YYYY') Location_and_Date,
(SELECT PPF.FULL_NAME
                 FROM  apps.per_people_F ppf
                   WHERE     --PPF.ATTRIBUTE6 = 'QA'
                         PERSON_ID = :p_approver
                         AND PPF.EFFECTIVE_END_DATE > SYSDATE) APPROVER,
 GW.SPEC_VR_STATUS,
 GW.SPEC_VR_ID,
 orginfo.organization_id,
 orginfo.registered_name,
 orginfo.address_line_1,
 orginfo.address_line_2,
 orginfo.postal_code,
 orginfo.telephone_number_1,
 orginfo.telephone_number_2,
 orginfo.telephone_number_3,
 orginfo.loc_information13,
 GS.SOURCE_COMMENT
 --FAV.FILE_NAME,
 --FAV.FUNCTION_NAME, 
 --length(FL.FILE_DATA) 
 --null IMAGE 
--getbase64(FL.FILE_DATA)
from
GMD.GMD_SAMPLES GS,
 INV.MTL_PARAMETERS MP1,
 hr_organization_information HOI,
 MTL_SYSTEM_ITEMS_FVL MSI,
 APPS.GMD_SPECIFICATIONS_VL GSPEC,
 GMD.gmd_wip_spec_vrs GW,
 GMD.gmd_results GR,
 APPS.GMD_QC_TESTS_VL GQV,
 APPS.GMD_SPEC_TESTS_VL GST,
 APPS.GMD_ALL_SPEC_VRS_VL GASV,
 (SELECT haou.organization_id
    , (SELECT DISTINCT registered_name
        FROM xle_registrations xlr
        WHERE xlr.location_id = haou.location_id) registered_name
    , hla.address_line_1
    , hla.address_line_2
    , hla.postal_code
    , hla.telephone_number_1
    , hla.telephone_number_2
    , hla.telephone_number_3
    , hla.loc_information13
FROM hr_all_organization_units haou
    , hr_locations_all hla 
WHERE 1=1
    AND hla.location_id = haou.location_id) orginfo
 --APPS.FND_ATTACHED_DOCS_FORM_VL FAV,
 --APPLSYS.fnd_lobs fl
where
 GS.SAMPLE_NO = :p_sample_no --1011300079 -- W
 AND GS.SOURCE = 'W'
 AND MP1.ORGANIZATION_CODE = :p_io --'ABP'--:p_io
 AND orginfo.organization_id = mp1.organization_id
 AND MP1.ORGANIZATION_ID = GS.ORGANIZATION_ID
 AND HOI.ORGANIZATION_ID = GS.ORGANIZATION_ID
 AND HOI.ORG_INFORMATION2 NOT IN 'Y'
 AND GS.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
 AND GS.ORGANIZATION_ID = MSI.ORGANIZATION_ID
 AND GS.INVENTORY_ITEM_ID = GSPEC.INVENTORY_ITEM_ID
 AND GS.RECIPE_ID = GW.RECIPE_ID
 AND GW.SPEC_ID = GSPEC.SPEC_ID
 AND GR.SAMPLE_ID = GS.SAMPLE_ID
 AND GQV.TEST_ID = GR.TEST_ID
 AND GST.TEST_ID = GR.TEST_ID
 AND GST.SPEC_ID = GSPEC.SPEC_ID
 AND  GW.SPEC_VR_STATUS = '700'
 AND GST.SPEC_ID = GASV.SPEC_ID
 AND GS.ORGANIZATION_ID = GASV.ORGANIZATION_ID
 AND GS.SOURCE = GASV.SPEC_TYPE
 AND GS.RECIPE_ID = GASV.RECIPE_ID
 AND (GSPEC.SPEC_ID = :P_SPEC_ID OR :P_SPEC_ID is null)
 AND gs.step_no is null
 AND GASV.SPEC_VR_ID = GW.SPEC_VR_ID
Order by SEQ