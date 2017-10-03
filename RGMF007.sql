select --GBH.BATCH_ID
        :P_ORGANIZATION_ID PARAM_ORGANIZATION_ID
        , :P_PERIOD PARAM_PERIOD
        , to_char(to_date(:P_PERIOD,'MON-RR'),'Month - RR') Period
        , le.organization_name
        , (select organization_code
            from mtl_parameters mp
            where mp.organization_id = GBH.ORGANIZATION_ID
          ) organization_code
        , GBH.BATCH_NO
        , MSIB.INVENTORY_ITEM_ID
        , msib.segment1
       || '-'
       || msib.segment2
       || '-'
       || msib.segment3
       || '-'
       || msib.segment4
       || '-'
       || msib.segment5
          ITEM_CODE
        , GMD.DTL_UM UOM
        , GMD.ACTUAL_QTY
        , YNPGMF_ABP_PKG.GET_MTL_VALUE_FNC(
                GBH.BATCH_ID,
                :P_PERIOD
        ) MATERIAL_VALUE  
        , nvl(YNPGMF_ABP_PKG.GET_PKG_VALUE_FNC(
                GBH.BATCH_ID,
                :P_PERIOD
        ),0) PACKAGING_VALUE
        , GMD.COST_ALLOC
        , nvl(GMD.COST_ALLOC*YNPGMF_ABP_PKG.GET_PKG_VALUE_FNC(
                GBH.BATCH_ID,
                :P_PERIOD
        ),0) PACKAGING_VALUE_IN_PRODUCT 
        , nvl(YNPGMF_ABP_PKG.GET_VALUE_ADJ_FNC (
            MSIB.SEGMENT1,
            MSIB.INVENTORY_ITEM_ID,
            GBH.BATCH_ID,
            :P_PERIOD,
            :P_ORGANIZATION_ID
            ),0) Value_adjusment    
         , decode(GMD.ACTUAL_QTY,0,0,((YNPGMF_ABP_PKG.GET_MTL_VALUE_FNC(GBH.BATCH_ID,:P_PERIOD) * GMD.COST_ALLOC) 
         + nvl(GMD.COST_ALLOC*YNPGMF_ABP_PKG.GET_PKG_VALUE_FNC(GBH.BATCH_ID,:P_PERIOD),0) 
         + nvl(YNPGMF_ABP_PKG.GET_VALUE_ADJ_FNC (MSIB.SEGMENT1,MSIB.INVENTORY_ITEM_ID,GBH.BATCH_ID,:P_PERIOD,:P_ORGANIZATION_ID),0)) 
         / nvl(GMD.ACTUAL_QTY,1))   ITEM_COST_AFTER_ADJ
from GME.GME_BATCH_HEADER GBH
        , GME.gme_material_details GMD
        , INV.MTL_SYSTEM_ITEMS_B MSIB 
        , hr_organization_information HOI
        ,   (SELECT entityprofileeo.legal_entity_id,
                       entityprofileeo.NAME,
                       entityprofileeo.legal_entity_identifier,
                       entityprofileeo.geography_id,
                       entityprofileeo.transacting_entity_flag,
                       entityprofileeo.effective_from,
                       entityprofileeo.effective_to,
                       entityprofileeo.le_information_context,
                       entityprofileeo.le_information1,
                       entityprofileeo.le_information2,
                       entityprofileeo.le_information3,
                       entityprofileeo.le_information4,
                       entityprofileeo.le_information5,
                       entityprofileeo.le_information6,
                       entityprofileeo.le_information7,
                       entityprofileeo.le_information8,
                       entityprofileeo.le_information9,
                       entityprofileeo.le_information10,
                       entityprofileeo.le_information11,
                       entityprofileeo.le_information12,
                       entityprofileeo.le_information13,
                       entityprofileeo.le_information14,
                       entityprofileeo.le_information15,
                       entityprofileeo.le_information16,
                       entityprofileeo.le_information17,
                       entityprofileeo.le_information18,
                       entityprofileeo.le_information19,
                       entityprofileeo.le_information20,
                       entityprofileeo.activity_code,
                       entityprofileeo.sub_activity_code,
                       entityprofileeo.type_of_company,
                       entityprofileeo.attribute_category,
                       entityprofileeo.attribute1,
                       entityprofileeo.attribute2,
                       entityprofileeo.attribute3,
                       entityprofileeo.attribute4,
                       entityprofileeo.attribute5,
                       entityprofileeo.attribute6,
                       entityprofileeo.attribute7,
                       entityprofileeo.attribute8,
                       entityprofileeo.attribute9,
                       entityprofileeo.attribute10,
                       entityprofileeo.attribute11,
                       entityprofileeo.attribute12,
                       entityprofileeo.attribute13,
                       entityprofileeo.attribute14,
                       entityprofileeo.attribute15,
                       entityprofileeo.attribute16,
                       entityprofileeo.attribute17,
                       entityprofileeo.attribute18,
                       entityprofileeo.attribute19,
                       entityprofileeo.attribute20,
                       hg.geography_name,
                       hp.party_number organization_number,
                       hp.party_name organization_name,
                       reg.place_of_registration,
                       loc.country,
                       loc.address_line_1,
                       loc.address_line_2,
                       loc.address_line_3,
                       loc.town_or_city,
                       loc.region_1 county,
                       loc.postal_code,
                       ft.territory_short_name country_name,
                       jur.registration_code_le,
                       reg.registration_number,
                       lkp.meaning transacting_flag_meaning
                  FROM xle_entity_profiles entityprofileeo,
                       hz_geographies hg,
                       hz_parties hp,
                       xle_registrations reg,
                       hr_locations loc,
                       xle_jurisdictions_b jur,
                       fnd_territories_vl ft,
                       xle_lookups lkp
                 WHERE     hg.geography_id = entityprofileeo.geography_id
                       AND hp.party_id = entityprofileeo.party_id
                       AND reg.source_id = entityprofileeo.legal_entity_id
                       AND reg.source_table = 'XLE_ENTITY_PROFILES'
                       AND reg.location_id = loc.location_id
                       AND reg.jurisdiction_id = jur.jurisdiction_id
                       AND ft.territory_code = loc.country
                       AND lkp.lookup_type = 'XLE_YES_NO'
                       AND lkp.lookup_code =
                              entityprofileeo.transacting_entity_flag) LE
where 1 = 1
AND GBH.BATCH_ID in 
        -- untuk menyaring batch no yang itemnya wajib ada FGP atau WIP
    (
    select GBH2.BATCH_ID
    from GME.GME_BATCH_HEADER GBH2
            , GME.gme_material_details GMD2
            , INV.MTL_SYSTEM_ITEMS_B MSIB2
    where 1 = 1
            AND GBH2.BATCH_STATUS in (4,3)   --CLOSED dan complete 4496  7321
            AND GMD2.BATCH_ID = GBH.BATCH_ID
            AND GBH2.ORGANIZATION_ID = GBH.ORGANIZATION_ID
            AND GMD2.LINE_TYPE = 1 -- TAB PRODUCT
            AND GMD2.INVENTORY_ITEM_ID = MSIB2.INVENTORY_ITEM_ID
            AND GMD2.ORGANIZATION_ID = MSIB2.ORGANIZATION_ID
            AND GBH2.ORGANIZATION_ID = GMD2.ORGANIZATION_ID
            AND HOI.ORGANIZATION_ID = GBH.ORGANIZATION_ID
            AND le.legal_entity_id = TO_NUMBER (HOI.ORG_INFORMATION2)
            AND HOI.ORG_INFORMATION2 NOT IN 'Y'
            AND hoi.org_information_context='Accounting Information'
            AND MSIB2.SEGMENT1 in ('FGP','WIP')
    )
AND GBH.BATCH_ID = nvl(:p_test_batch_id,GBH.BATCH_ID)
AND to_char(GBH.ACTUAL_CMPLT_DATE,'MON-RR') = nvl(:P_PERIOD,to_char(GBH.ACTUAL_CMPLT_DATE,'MON-RR'))
AND GBH.ORGANIZATION_ID = nvl(:P_ORGANIZATION_ID,GBH.ORGANIZATION_ID)
AND GMD.BATCH_ID = GBH.BATCH_ID
AND GMD.LINE_TYPE = 1 -- TAB PRODUCT
AND GMD.INVENTORY_ITEM_ID = MSIB.INVENTORY_ITEM_ID
AND GMD.ORGANIZATION_ID = MSIB.ORGANIZATION_ID
AND GBH.ORGANIZATION_ID = GMD.ORGANIZATION_ID     
order by GBH.BATCH_NO , item_code       