SELECT           
    (SELECT  
        (SELECT NAME FROM HR_ALL_ORGANIZATION_UNITSWHERE ORGANIZATION_ID = BB.OPERATING_UNIT) AS NAME_OU                                      
            FROM   ORG_ORGANIZATION_DEFINITIONS BB                                     
            WHERE  ORGANIZATION_ID IN ( SELECT ORGANIZATION_ID FROM HR_ALL_ORGANIZATION_UNITS                                                                
                                        WHERE ORGANIZATION_ID = 314)
                           ) AS OU,        
        pp.item_code, 
        pp.description, 
        pp.uom, 
        pp.organization_code, 
        pp.organization_name
        FROM(
                SELECT  MSI.ORGANIZATION_ID,        
                        OOD.ORGANIZATION_CODE,        
                        OOD.ORGANIZATION_NAME,        
                        MSI.INVENTORY_ITEM_ID,        
                        MSI.SEGMENT1 ||'-'|| MSI.SEGMENT2 ||'-'|| MSI.SEGMENT3 ||'-'|| MSI.SEGMENT4 ||'-'|| MSI.SEGMENT5 ITEM_CODE,        
                        LENGTH(MSIT.LONG_DESCRIPTION) A_,
                        LENGTH(MSI.DESCRIPTION) B_,        
                        MSI.DESCRIPTION,        
                        MSIT.LONG_DESCRIPTION,        
                        MSI.INVENTORY_ITEM_STATUS_CODE ITEM_STATUS,        
                        NULL QP_KARUNG,        
                        NULL QP_RAK,        
                        NULL QP_BOX,        
                        NULL QP_BALL,        
                        MSI.PRIMARY_UOM_CODE UOM,        
                        MSI.ITEM_TYPE,        
                        NULL ITEM_ASSIGMENTS,        
                        MSI.AUTO_LOT_ALPHA_PREFIX STARTING_PREFIX,        
                        MSI.START_AUTO_LOT_NUMBER STARTING_NUMBER,        
                        (SELECT DISTINCT STATUS_CODE 
                            FROM MTL_MATERIAL_STATUSES_VL 
                            WHERE STATUS_ID = MSI.DEFAULT_LOT_STATUS_ID) DEFAULT_LOT_STATUS_ID,        
                            SHELF_LIFE_DAYS SHELF_LIFE_DAYS,        
                            (SELECT CATEGORY_CONCAT_SEGS         
                                FROM MTL_ITEM_CATEGORIES_V         
                                WHERE INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID         
                                AND ORGANIZATION_ID = MSI.ORGANIZATION_ID         
                                AND ENABLED_FLAG = 'Y'         
                                AND CATEGORY_SET_NAME = 'NP Transportation Category' ) "NP_Transportation_Category",         
                                    (SELECT CATEGORY_CONCAT_SEGS         
                                        FROM MTL_ITEM_CATEGORIES_V         
                                        WHERE INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID         
                                        AND ORGANIZATION_ID = MSI.ORGANIZATION_ID         
                                        AND ENABLED_FLAG = 'Y'         
                                        AND CATEGORY_SET_NAME = 'NP Purchasing Category' ) "NP_Purchasing_Category",         
                                            (SELECT CATEGORY_CONCAT_SEGS         
                                                FROM MTL_ITEM_CATEGORIES_V         
                                                WHERE INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID         
                                                AND ORGANIZATION_ID = MSI.ORGANIZATION_ID         
                                                AND ENABLED_FLAG = 'Y'         
                                                AND CATEGORY_SET_NAME = 'NP EAM Category' ) "NP_EAM_Category",         
                                                    (SELECT CATEGORY_CONCAT_SEGS         
                                                        FROM MTL_ITEM_CATEGORIES_V         
                                                        WHERE INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID         
                                                        AND ORGANIZATION_ID = MSI.ORGANIZATION_ID         
                                                        AND ENABLED_FLAG = 'Y'         
                                                        AND CATEGORY_SET_NAME = 'NP GL Class Category' ) "NP_GL_Class_Category",         
                                                            (SELECT CATEGORY_CONCAT_SEGS         
                                                                FROM MTL_ITEM_CATEGORIES_V         
                                                                WHERE INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID         
                                                                AND ORGANIZATION_ID = MSI.ORGANIZATION_ID         
                                                                AND ENABLED_FLAG = 'Y'         
                                                                AND CATEGORY_SET_NAME = 'NP Planning Category' ) "NP_Planning_Category",         
                                                                    (SELECT CATEGORY_CONCAT_SEGS         
                                                                        FROM MTL_ITEM_CATEGORIES_V         
                                                                        WHERE INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID         
                                                                        AND ORGANIZATION_ID = MSI.ORGANIZATION_ID         
                                                                        AND ENABLED_FLAG = 'Y'         
                                                                        AND CATEGORY_SET_NAME = 'NP Sales Class Category' ) "NP_Sales_Class_Category",         
                                                                            (SELECT CATEGORY_CONCAT_SEGS         
                                                                                FROM MTL_ITEM_CATEGORIES_V         
                                                                                WHERE INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID         
                                                                                AND ORGANIZATION_ID = MSI.ORGANIZATION_ID         
                                                                                AND ENABLED_FLAG = 'Y'         
                                                                                AND CATEGORY_SET_NAME = 'NP Inventory Category' ) "NP_Inventory_Category",         
                                                                                    (SELECT CATEGORY_CONCAT_SEGS         
                                                                                        FROM MTL_ITEM_CATEGORIES_V         
                                                                                        WHERE INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID         
                                                                                        AND ORGANIZATION_ID = MSI.ORGANIZATION_ID         
                                                                                        AND ENABLED_FLAG = 'Y'
                                                                                        AND CATEGORY_SET_NAME = 'NP Product Category' ) "NP_Product_Category",         
                                                                                        (SELECT CATEGORY_CONCAT_SEGS         
                                                                                            FROM MTL_ITEM_CATEGORIES_V         
                                                                                            WHERE INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID         
                                                                                            AND ORGANIZATION_ID = MSI.ORGANIZATION_ID         
                                                                                            AND ENABLED_FLAG = 'Y'         
                                                                                            AND CATEGORY_SET_NAME = 'NP Cost Class Category' ) "NP_Cost_Class_Category",         
                                                                                        (SELECT CATEGORY_CONCAT_SEGS         
                                                                                            FROM MTL_ITEM_CATEGORIES_V         
                                                                                            WHERE INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID         
                                                                                            AND ORGANIZATION_ID = MSI.ORGANIZATION_ID         
                                                                                            AND ENABLED_FLAG = 'Y'         
                                                                                            AND CATEGORY_SET_NAME = 'Enterprise Asset Management'         
                                                                                            AND ROWNUM = 1) "Enterprise_Asset_Management"
                                                                                            
                                                                                            FROM MTL_SYSTEM_ITEMS MSI,        
                                                                                            MTL_SYSTEM_ITEMS_TL MSIT,        
                                                                                            ORG_ORGANIZATION_DEFINITIONS OOD
                                                                                            
                                                                                            WHERE MSI.INVENTORY_ITEM_ID = MSIT.INVENTORY_ITEM_ID
                                                                                            AND MSI.ORGANIZATION_ID = MSIT.ORGANIZATION_ID
                                                                                            AND MSI.ORGANIZATION_ID = OOD.ORGANIZATION_ID   
                                                                                            AND MSI.INVENTORY_ITEM_STATUS_CODE = 'Active'
                                                                                            )pp
                                                                                            WHERE PP.ORGANIZATION_CODE NOT IN ('AMM','CMM','DMM','BMM')
                                                                                            ORDER BY (SELECT  
                                                                                                            (SELECT NAME 
                                                                                                            FROM HR_ALL_ORGANIZATION_UNITS
                                                                                                            WHERE ORGANIZATION_ID = BB.OPERATING_UNIT) AS NAME_OU                                      
                                                                                                            FROM ORG_ORGANIZATION_DEFINITIONS BB                                     
                                                                                                            WHERE ORGANIZATION_ID IN (
                                                                                                                                        SELECT ORGANIZATION_ID 
                                                                                                                                        FROM HR_ALL_ORGANIZATION_UNITS                                                                
                                                                                                                                        WHERE ORGANIZATION_ID = 314)), 
                                                                                                            PP.ORGANIZATION_CODE, 
                                                                                                            PP.ITEM_CODE