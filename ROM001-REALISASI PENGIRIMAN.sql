select PP.ORGANIZATION_ID, COUNT(PP.NOSJ) from (
    SELECT
    MSI.DESCRIPTION AS NAMAPRODUCT,
    wdd.released_status,
    DECODE(wl_released.meaning,'Shipped','Interfaced',wl_released.meaning) as line_status,
    WND.NAME AS NOSJ,
    WND.ROUTING_INSTRUCTIONS AS NOSJMT,
    WND.INITIAL_PICKUP_DATE AS TGLSC,
    WND.INITIAL_PICKUP_DATE AS TGLSJ,
    WND.ORGANIZATION_ID,
    WDD.ORG_ID,
    MSI.SEGMENT2 AS PRODUK,
    OOH.CUST_PO_NUMBER AS PO,
    SUM(WDD.REQUESTED_QUANTITY) AS QTY,
    SUM((SELECT AB.ACCEPTED_QUANTITY FROM YNPOM_SJK_DTL AB WHERE ROWNUM = 1 AND AB.YNPOMSJKHDR_ID = YSJH.YNPOMSJKHDR_ID
    AND AB.INVENTORY_ITEM_ID = WDD.INVENTORY_ITEM_ID)) / (SELECT COUNT(*) FROM 
    WSH_NEW_DELIVERIES WNDD, WSH_DELIVERY_ASSIGNMENTS B, WSH_DELIVERY_DETAILS C
    WHERE WNDD.DELIVERY_ID = B.DELIVERY_ID
    AND B.DELIVERY_DETAIL_ID = C.DELIVERY_DETAIL_ID
    AND C.INVENTORY_ITEM_ID = WDD.INVENTORY_ITEM_ID
    AND WNDD.DELIVERY_ID = WND.DELIVERY_ID) AS QTYTERIMACUSTOMER,
    sum(WDD.REQUESTED_QUANTITY) - SUM((SELECT AB.ACCEPTED_QUANTITY FROM YNPOM_SJK_DTL AB WHERE ROWNUM = 1 AND AB.YNPOMSJKHDR_ID = YSJH.YNPOMSJKHDR_ID
    AND AB.INVENTORY_ITEM_ID = WDD.INVENTORY_ITEM_ID)) / (SELECT COUNT(*) FROM 
    WSH_NEW_DELIVERIES WNDD, WSH_DELIVERY_ASSIGNMENTS B, WSH_DELIVERY_DETAILS C
    WHERE WNDD.DELIVERY_ID = B.DELIVERY_ID
    AND B.DELIVERY_DETAIL_ID = C.DELIVERY_DETAIL_ID
    AND C.INVENTORY_ITEM_ID = WDD.INVENTORY_ITEM_ID
    AND WNDD.DELIVERY_ID = WND.DELIVERY_ID) AS SELISIHQTY,
    HP.PARTY_NAME AS PLANT1,
    HCA.ACCOUNT_NAME AS PLANT,
    YSH.SPKNO,
    YSH.SPKDATE,
    YSH.BSTBMDATE,
    YSH.BSTBMNO,
    AP.VENDOR_NAME,
    NVL(WND.TP_ATTRIBUTE3,YV.TRUCK_NUMBER) as NOMOBIL,
    NVL(WND.TP_ATTRIBUTE4,YR.VEHICLE_TYPE) AS JENISMOBIL,
    YSD.DESTINATION AS WILAYAH,
    wdd.date_requested,
    wdd.date_scheduled,
    trunc(wdd.date_scheduled)-trunc(WND.INITIAL_PICKUP_DATE) AS SELISIH_SCHED_SJ,
    trunc(wdd.date_requested)-YSJH.ACTUAL_ARRIVAL_DATE AS SELISIH_REQ_TERIMA,
    YSJH.ACTUAL_ARRIVAL_DATE AS TGLTERIMACUSTOMER,
    YSJH.ACTUAL_ARRIVAL_DATE - YSH.BSTBMDATE AS SELISIHTGL,
    YTH.TTSJNO,
    YTH.TTSJDATE AS TGLKEMBALISJ,
    YTH.TTSJDATE - YSJH.ACTUAL_ARRIVAL_DATE AS SELISIHTGL1,
    NVL(WND.TP_ATTRIBUTE5,YV.DRIVER_NAME) AS NAMASUPIR,
    NVL(WND.TP_ATTRIBUTE6,YSH.HP) AS TELP,
    DECODE(YSH.STATUS,
                  'I', 'INITIATE',
                  'J', 'JOURNALED',
                  'L', 'CANCELED',
                  'F', 'FINAL') AS STATUS,
    MSI.SEGMENT1 || '-' || MSI.SEGMENT2 || '-' || MSI.SEGMENT3 || '-' || MSI.SEGMENT4 || '-' || MSI.SEGMENT5 AS ITEM_CODE,
    (SELECT
    MIC.CATEGORY_CONCAT_SEGS
    FROM MTL_ITEM_CATEGORIES_V MIC
    WHERE
    MIC.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
    AND MIC.ORGANIZATION_ID = MSI.ORGANIZATION_ID
    AND MIC.CATEGORY_SET_ID = 1100000051) AS TP_CATEGORY,
    YER.FROM_LOCATION || '-' || YER.TO_LOCATION AS ROUTE,
    CASE
                WHEN YSH.status = 'J'
                   THEN 'Y'
                ELSE (CASE
                WHEN ynp_rate (YSH.org_id,
                                    AP.vendor_id,
                                    ass.vendor_site_id,
                                    YSH.ynpap_exproute_id,
                                    NVL(WND.TP_ATTRIBUTE4,YR.VEHICLE_TYPE),
                                    --UPPER (mic.segment2)
                                    (case when ynpom_check_bstbm_mix(YSH.bstbmno)>1
                                    then 'MIX'
                                    else UPPER ((SELECT
    MIC.SEGMENT2
    FROM MTL_ITEM_CATEGORIES_V MIC
    WHERE
    MIC.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
    AND MIC.ORGANIZATION_ID = MSI.ORGANIZATION_ID
    AND MIC.CATEGORY_SET_ID = 1100000051))
                                    end)
                                   )
                          > 0
                   THEN 'Y'
                ELSE 'N'
             END)
             END AS master_rate,
    to_char(TO_DATE(:from_date,'RRRR/MM/DD HH24:MI:SS'),'DD/MM/YYYY') AS FROMDATE,
    to_char(TO_DATE(:to_date,'RRRR/MM/DD HH24:MI:SS'),'DD/MM/YYYY') AS TODATE,
    to_char(TO_DATE(:p_from_date_sc,'RRRR/MM/DD HH24:MI:SS'),'DD/MM/YYYY') AS FROMDATESC,
    to_char(TO_DATE(:p_to_date_sc,'RRRR/MM/DD HH24:MI:SS'),'DD/MM/YYYY') AS TODATESC,
    DECODE(YSH.ORG_ID,
    82, 'NSP-IR-LGT/01-03 Rev.01',
    161,'NSPS-IR-LGT/01-03 Rev. 00',
    192,'NSPA-IR-LGT/01-04 Rev.00',
    228,'AMM-IR-LGT/01-02','') AS DOK_ISO,
    DECODE(ship_loc.city, NULL, NULL, ship_loc.city || ', ') || DECODE(ship_loc.state, NULL, ship_loc.province||', ', ship_loc.state || ', ') || DECODE(ship_loc.postal_code, NULL, NULL, ship_loc.postal_code || ', ') || DECODE(ship_loc.country, NULL, NULL, ship_loc.country) SHIP_TO_ADDRESS5,
    WDD.ATTRIBUTE2 AS REASON_DFF,
    WDD.ATTRIBUTE3 AS CONTRIBUTOR
    FROM
    WSH_NEW_DELIVERIES WND,
    WSH_DELIVERY_ASSIGNMENTS WDA,
    WSH_DELIVERY_DETAILS WDD,
    MTL_SYSTEM_ITEMS MSI,
    HZ_CUST_ACCOUNTS HCA,
    HZ_PARTIES HP,
    YNPOM_SPKM_DTL YSD,
    YNPOM_SPKM_HDR YSH,
    NP.YNPTEMP_VEHICLE YV,
    YNPAP_REFIDVEHICLE YR,
    AP_SUPPLIERS AP,
    ap_supplier_sites_all ass,
    YNPOM_SJK_HDR YSJH,
    YNPOM_TTSJ_DTL YTD,
    YNPOM_TTSJ_HDR YTH,
    YNPAP_EXPEDITION_ROUTE YER,
    OE_ORDER_HEADERS_ALL OOH,
    OE_ORDER_LINES_ALL OOL,
    wsh_lookups wl_released,
    wsh_lookups wl_source,
    hz_cust_site_uses_all ship_su, hz_party_sites ship_ps, hz_locations ship_loc, hz_cust_acct_sites_all ship_cas
    WHERE
    WND.DELIVERY_ID = WDA.DELIVERY_ID
    AND WDA.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
    AND WDD.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
    AND WDD.ORGANIZATION_ID = MSI.ORGANIZATION_ID
    AND OOH.HEADER_ID = OOL.HEADER_ID
    AND WDD.SOURCE_HEADER_ID = OOL.HEADER_ID
    AND WDD.SOURCE_LINE_ID = OOL.LINE_ID
    AND WND.CUSTOMER_ID = HCA.CUST_ACCOUNT_ID
    --AND WND.SOURCE_HEADER_ID = OOH.HEADER_ID
    --AND HCA.CUST_ACCOUNT_ID = 
    AND OOH.ship_to_org_id = ship_su.site_use_id(+) 
    AND ship_su.cust_acct_site_id= ship_cas.cust_acct_site_id(+) 
    AND ship_cas.party_site_id = ship_ps.party_site_id(+) 
    AND ship_loc.location_id(+) = ship_ps.location_id 
    AND HCA.PARTY_ID = HP.PARTY_ID
    AND YSH.REFID = YR.REFID (+)
    AND YSH.ORG_ID = YR.ORG_ID (+)
    --AND YR.ACTIVE_FLAG <> 'N'
    AND WND.DELIVERY_ID  = YSD.DELIVERY_ID (+)
    AND YSD.SPKNO = YSH.SPKNO (+)
    AND YSH.REFERENCE_ID = YV.REFERENCE_ID (+)
    AND YV.SUPPLIER = AP.VENDOR_ID (+)
    --AND AP.VENDOR_ID = ASS.VENDOR_ID (+)
    AND YV.SUPPLIER_SITE = ASS.VENDOR_SITE_ID (+)
    AND WND.DELIVERY_ID  = YSJH.DELIVERY_ID (+)
    AND YSH.BSTBMNO  = YTD.BSBTMNO (+)
    AND YTD.TTSJNO  = YTH.TTSJNO (+)
    AND YSH.YNPAP_EXPROUTE_ID = YER.YNPAP_EXPROUTE_ID (+)
    AND (TRUNC(YSH.BSTBMDATE) BETWEEN TO_DATE(:from_date,'RRRR/MM/DD HH24:MI:SS') and TO_DATE(:to_date,'RRRR/MM/DD HH24:MI:SS')
    OR TRUNC(WND.INITIAL_PICKUP_DATE) BETWEEN TO_DATE(:p_from_date_sc,'RRRR/MM/DD HH24:MI:SS') and TO_DATE(:p_to_date_sc,'RRRR/MM/DD HH24:MI:SS')
    OR TRUNC(YSH.SPKDATE) BETWEEN TO_DATE(:p_from_date_spk,'RRRR/MM/DD HH24:MI:SS') and TO_DATE(:p_to_date_spk,'RRRR/MM/DD HH24:MI:SS'))
    --AND (WDD.ORG_ID = :ou OR YSH.ORG_ID = :ou)
    AND wl_source.lookup_type = 'SOURCE_SYSTEM'
    AND wl_source.lookup_code = wdd.source_code
    AND wl_released.lookup_type = 'PICK_STATUS'
    AND wl_released.lookup_code = NVL (wdd.released_status, 'X')
    GROUP BY
    WND.DELIVERY_ID,
    WND.NAME,
    WND.ROUTING_INSTRUCTIONS,
    WND.INITIAL_PICKUP_DATE,
    WND.ORGANIZATION_ID,
    WDD.ORG_ID,
    wdd.date_requested,
    wdd.date_scheduled,
    WDD.INVENTORY_ITEM_ID,
    OOH.CUST_PO_NUMBER,
    HP.PARTY_NAME,
    HCA.ACCOUNT_NAME,
    YSH.SPKNO,
    YSH.SPKDATE,
    YSH.BSTBMDATE,
    YSH.BSTBMNO,
    AP.VENDOR_NAME,
    MSI.DESCRIPTION,
    MSI.SEGMENT2,
    NVL(WND.TP_ATTRIBUTE4,YR.VEHICLE_TYPE),
    NVL(WND.TP_ATTRIBUTE3,YV.TRUCK_NUMBER),
    YSD.DESTINATION,
    YSJH.YNPOMSJKHDR_ID,
    YSJH.ACTUAL_ARRIVAL_DATE,
    YTH.TTSJNO,
    YTH.TTSJDATE,
    WND.TP_ATTRIBUTE5,
    NVL(WND.TP_ATTRIBUTE6,YSH.HP),
    DECODE(YSH.STATUS,
                  'I', 'INITIATE',
                  'J', 'JOURNALED',
                  'L', 'CANCELED',
                  'F', 'FINAL'), 
    MSI.SEGMENT1 || '-' || MSI.SEGMENT2 || '-' || MSI.SEGMENT3 || '-' || MSI.SEGMENT4 || '-' || MSI.SEGMENT5,
    --MIC.CATEGORY_CONCAT_SEGS,
    YER.FROM_LOCATION || '-' || YER.TO_LOCATION,
    YSH.STATUS,
    AP.VENDOR_ID,
    YSH.org_id,
    ass.vendor_site_id,
    YSH.ynpap_exproute_id,
    DECODE(ship_loc.city, NULL, NULL, ship_loc.city || ', ') || DECODE(ship_loc.state, NULL, ship_loc.province||', ', ship_loc.state || ', ') || DECODE(ship_loc.postal_code, NULL, NULL, ship_loc.postal_code || ', ') || DECODE(ship_loc.country, NULL, NULL, ship_loc.country),
    MSI.INVENTORY_ITEM_ID,
    MSI.ORGANIZATION_ID,
    NVL(WND.TP_ATTRIBUTE5,YV.DRIVER_NAME),
    wl_released.meaning,
    wdd.released_status,
    WDD.ATTRIBUTE2,
    WDD.ATTRIBUTE3
    ORDER BY YSH.BSTBMNO, YSH.BSTBMDATE
    ) pp
    where PP.STATUS = 'FINAL'
    GROUP BY PP.ORGANIZATION_ID, PP.STATUS