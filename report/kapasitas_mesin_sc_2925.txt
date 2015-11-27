select hou.NAME ou,
                crd.RESOURCES,
                (select operating_unit from 
                APPS.ORG_ORGANIZATION_DEFINITIONS
                where ORGANIZATION_ID = crd.organization_id ) ORG,
               crd.IDEAL_CAPACITY * 3 kapasitas ,
               decode(crmb.RESOURCE_CLASS,
                      'BBLM','Botol Belah',
                      'CGM','CAP SHIELD',
                      'CRS','Cruiser',
                      'CUP','CUP',
                      'DRYM','Dryer',
                      'GLM','GALLON',
                      'GRM','Granulator',
                      'HDM','Blow HDPE',
                      'MIXM','Mixer',
                      'PET','PET',
                      'PLM','Pellet',
                      'PLTM','Pelletizer',
                      'PRM','PREFORM',
                      'SCM','SCREW CAP',
                      'SLPM','Slep',
                      'SSM','SSP Buhler',
                      'TCM','CAP SHIELD',
                      'TLO','Toll Out',
                      'VIBM','Vibrator',
                      'WSM','Washing') as MESIN 
        from 
            CR_RSRC_DTL crd, 
            cr_rsrc_mst_b crmb,
            hr_all_organization_units hou
        where 
        crd.INACTIVE_IND = 0
        and hou.ORGANIZATION_ID = crd.ORGANIZATION_ID
        and crmb.RESOURCES = crd.RESOURCES
        AND crmb.RESOURCE_CLASS like '%SCM%'
        and crmb.RESOURCES IN (
        SELECT   D.RESOURCES
                         FROM   GME_BATCH_HEADER A,
                                CR_RSRC_MST_B B,
                                GME_MATERIAL_DETAILS C,
                                GME_BATCH_STEP_RESOURCES D,
                                MTL_SYSTEM_ITEMS E,
                                MTL_TRX
                                WHERE 1 = 1
                                AND A.BATCH_ID = D.BATCH_ID
                                AND A.BATCH_ID = C.BATCH_ID
                                AND C.LINE_TYPE = 1
                                AND E.SEGMENT1 IN ('FGP')
                                AND E.SEGMENT2 IN ('CAP')
                                AND E.SEGMENT3 like '2925%'
                                AND C.LINE_TYPE = 1
                                AND C.BATCH_ID = MTL_TRX.DOC_ID
                                AND C.INVENTORY_ITEM_ID = E.INVENTORY_ITEM_ID
                                AND C.ORGANIZATION_ID = E.ORGANIZATION_ID
                                /*AND
                                (
                                    A.ORGANIZATION_ID IN (NVL($OU1,0))
                                    OR
                                    A.ORGANIZATION_ID IN (NVL($OU2,0))
                                    OR
                                    A.ORGANIZATION_ID IN (NVL($OU3,0))
                                 )*/
                                AND B.RESOURCES = D.RESOURCES
                                --AND B.RESOURCE_CLASS In ('$r1' , '$r2' )
                                ---AND D.RESOURCES = MTL_TRX.RESOURCES
                                AND D.RESOURCES NOT IN (SELECT RESOURCES
                                                        FROM CR_RSRC_MST_B
                                                        WHERE RESOURCES like 'MLD%'
                                                                OR RESOURCES LIKE 'PUNCH%'
                                                                OR RESOURCES LIKE 'C-%'
                                                                OR RESOURCES LIKE 'C2%'
                                                                OR RESOURCES LIKE 'C3%')
                                GROUP BY D.RESOURCES, A.ORGANIZATION_ID
                                )
        
        
        
        and crmb.RESOURCES not in
        (
            SELECT RESOURCES
                                                    FROM CR_RSRC_MST_B
                                                    WHERE RESOURCES like 'MLD%'
                                                        OR RESOURCES LIKE 'PUNCH%'
                                                        OR RESOURCES LIKE 'C-%'
                                                        OR RESOURCES LIKE 'C2%'
                                                        OR RESOURCES LIKE 'C3%'
        )