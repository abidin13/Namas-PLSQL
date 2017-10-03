                                                SELECT COUNT(PP.STATUS) 
                                                FROM (
                                                    SELECT   CASE
                                                                  WHEN YSH.STATUS = 'F'
                                                                  AND (AP.VENDOR_NAME = 'Customer Delivery'
                                                                       OR AP.VENDOR_NAME = 'Company Delivery'
                                                                      )
                                                                     THEN 'JOURNALED'
                                                                  ELSE DECODE (YSH.STATUS,
                                                                               'I', 'INITIATE',
                                                                               'J', 'JOURNALED',
                                                                               'L', 'CANCELED',
                                                                               'F', 'FINAL',
                                                                               YSH.STATUS
                                                                              )
                                                               END AS STATUS,
                                                               YSH.BSTBMNO AS BSTBMNO, WDD.ORG_ID, AP.VENDOR_NAME,
                                                               YSH.SPKNO
                                                          FROM WSH_NEW_DELIVERIES WND,
                                                               WSH_DELIVERY_ASSIGNMENTS WDA,
                                                               WSH_DELIVERY_DETAILS WDD,
                                                               YNPOM_SPKM_DTL YSD,
                                                               YNPOM_SPKM_HDR YSH,
                                                               NP.YNPTEMP_VEHICLE YV,
                                                               AP_SUPPLIERS AP
                                                         WHERE WND.DELIVERY_ID = WDA.DELIVERY_ID
                                                           AND WDA.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
                                                           --AND YR.ACTIVE_FLAG <> 'N'
                                                           AND WND.DELIVERY_ID = YSD.DELIVERY_ID(+)
                                                           AND YSD.SPKNO = YSH.SPKNO(+)
                                                           AND YSH.REFERENCE_ID = YV.REFERENCE_ID(+)
                                                           AND YV.SUPPLIER = AP.VENDOR_ID(+)
                                                           AND TO_CHAR(WND.INITIAL_PICKUP_DATE,'MM') = :bulan
                                                           AND TO_CHAR(WND.INITIAL_PICKUP_DATE,'YYYY') = :tahun
                                                           AND TRUNC (WND.INITIAL_PICKUP_DATE)
                                                                  BETWEEN TO_DATE (:startdate, 'RRRR/MM/DD HH24:MI:SS')
                                                                      AND TO_DATE (:enddate, 'RRRR/MM/DD HH24:MI:SS')
                                                      GROUP BY WDD.ORG_ID,
                                                               CASE
                                                                  WHEN YSH.STATUS = 'F'
                                                                  AND (AP.VENDOR_NAME = 'Customer Delivery'
                                                                       OR AP.VENDOR_NAME = 'Company Delivery'
                                                                      )
                                                                     THEN 'JOURNALED'
                                                                  ELSE DECODE (YSH.STATUS,
                                                                               'I', 'INITIATE',
                                                                               'J', 'JOURNALED',
                                                                               'L', 'CANCELED',
                                                                               'F', 'FINAL',
                                                                               YSH.STATUS
                                                                              )
                                                               END,
                                                               YSH.BSTBMNO,
                                                               AP.VENDOR_NAME,
                                                               YSH.SPKNO) PP
                                                               WHERE PP.ORG_ID = 152
                                                               AND PP.STATUS = 'CANCELED'
                                                               GROUP BY PP.STATUS
===========================================================================================================================================
SELECT * FROM (
SELECT   HAOU.NAME,
                        CASE
                                                                  WHEN YSH.STATUS = 'F'
                                                                  AND (AP.VENDOR_NAME = 'Customer Delivery'
                                                                       OR AP.VENDOR_NAME = 'Company Delivery'
                                                                      )
                                                                     THEN 'JOURNALED'
                                                                  ELSE DECODE (YSH.STATUS,
                                                                               'I', 'INITIATE',
                                                                               'J', 'JOURNALED',
                                                                               'L', 'CANCELED',
                                                                               'F', 'FINAL',
                                                                               YSH.STATUS
                                                                              )
                                                               END AS STATUS,
                               YSH.BSTBMNO AS BSTBMNO
                          FROM WSH_NEW_DELIVERIES WND,
                               WSH_DELIVERY_ASSIGNMENTS WDA,
                               WSH_DELIVERY_DETAILS WDD,
                               YNPOM_SPKM_DTL YSD,
                               YNPOM_SPKM_HDR YSH,
                               NP.YNPTEMP_VEHICLE YV,
                               AP_SUPPLIERS AP,
                               HR_ALL_ORGANIZATION_UNITS HAOU
                         WHERE WDD.ORG_ID = HAOU.ORGANIZATION_ID
                           AND WND.DELIVERY_ID = WDA.DELIVERY_ID
                           AND WDA.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
                           --AND YR.ACTIVE_FLAG <> 'N'
                           AND WND.DELIVERY_ID = YSD.DELIVERY_ID(+)
                           AND YSD.SPKNO = YSH.SPKNO(+)
                           AND YSH.REFERENCE_ID = YV.REFERENCE_ID(+)
                           AND YV.SUPPLIER = AP.VENDOR_ID(+)
                           AND TO_CHAR(WND.INITIAL_PICKUP_DATE, 'MM') = :bulan
                            AND TO_CHAR(WND.INITIAL_PICKUP_DATE, 'YYYY') = :tahun
                           AND WDD.ORG_ID = :ou
                      GROUP BY HAOU.NAME,
                               CASE
                                                                  WHEN YSH.STATUS = 'F'
                                                                  AND (AP.VENDOR_NAME = 'Customer Delivery'
                                                                       OR AP.VENDOR_NAME = 'Company Delivery'
                                                                      )
                                                                     THEN 'JOURNALED'
                                                                  ELSE DECODE (YSH.STATUS,
                                                                               'I', 'INITIATE',
                                                                               'J', 'JOURNALED',
                                                                               'L', 'CANCELED',
                                                                               'F', 'FINAL',
                                                                               YSH.STATUS
                                                                              )
                                                               END,
                                YSH.BSTBMNO,
                                AP.VENDOR_NAME,
                                YSH.SPKNO
                            ORDER BY YSH.BSTBMNO
                            ) PP
                            WHERE PP.STATUS = 'INITIATE'
