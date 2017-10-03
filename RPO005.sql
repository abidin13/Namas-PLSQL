/* Formatted on 12/1/2013 12:44:10 PM (QP5 v5.149.1003.31008) 
Created By : Bima Shakti Ramadhan Utomo
*/
  SELECT tab.INVOICE_NUM,
         tab.CREATION_DATE,
         tab.NO_PENGAJUAN,
         tab.VENDOR_ID,
         tab.VENDOR_NAME,
         tab.attribute7,
         tab.NO_PO,
         tab.SITE,
         tab.TERM_PAYMENT,
         tab.DESCRIPTION,
         tab.BANK,
         tab.BRANCH,
         tab.BENEFICIARY_NAME,
         tab.NO_REKENING,
         tab.SWIFT_CODE,
         tab.IBAN,
         LISTAGG (tab.DUE_DATE, ',') WITHIN GROUP (ORDER BY tab.DUE_DATE)
            DUE_DATE,
         tab.CURRENCY,
         tab.AMOUNT,
         tab.BANK_KELUAR,
         tab.LOCATION_AND_DATE,
         tab.USER_NAME,
         tab.STATUS
    FROM (SELECT AI.INVOICE_NUM,
                 AI.CREATION_DATE,
                 --AI.INVOICE_ID,
                 AI.DOC_SEQUENCE_VALUE NO_PENGAJUAN,
                 AI.VENDOR_ID,
                 case when (pha.attribute2 = 'None') or (pha.attribute2 = '') or (pha.attribute2 is null) then
                      pv.vendor_name
                 else
                      (SELECT address_line3
                       FROM ap_supplier_sites_all
                       WHERE vendor_site_id = pha.vendor_site_id
                       AND org_id = pha.org_id)     
                 end as vendor_name,
                 -- update vendor name veranda pv.vendor_name
                 AI.attribute7 attribute7,
                 pha.segment1 NO_PO,
                (select city from ap_supplier_sites_all apss
                 where apss.vendor_id = AI.VENDOR_ID
                    AND ORG_ID = AI.ORG_ID) AS SITE,
                 --AI.TERMS_ID,
                 ATT.DESCRIPTION TERM_PAYMENT,
                 AI.DESCRIPTION,
                 (SELECT HP.PARTY_NAME
                    FROM ar.hz_parties hp, ar.hz_party_usg_assignments hpua
                   WHERE     hp.party_id = IBYBNK.BANK_ID
                         AND hp.party_id = hpua.party_id
                         AND hpua.party_usage_code = 'BANK')
                    BANK,
                 (SELECT HP.PARTY_NAME
                    FROM ar.hz_parties hp, ar.hz_party_usg_assignments hpua
                   WHERE     hp.party_id = IBYBNK.BRANCH_ID
                         AND hp.party_id = hpua.party_id
                         AND hpua.party_usage_code = 'BANK_BRANCH')
                    Branch,
                 ibybnk.bank_account_name BENEFICIARY_NAME,
                 IBYBNK.BANK_ACCOUNT_NUM NO_REKENING,
                 --IBYBNK.EXT_BANK_ACCOUNT_ID,
                 IBYBNK.ATTRIBUTE1 Swift_Code,
                 IBYBNK.ATTRIBUTE2 IBAN,
                 APSA.DUE_DATE,
                 AI.PAYMENT_CURRENCY_CODE CURRENCY,
                 AI.INVOICE_AMOUNT AMOUNT,
                 AI.ATTRIBUTE3 BANK_KELUAR,
                 (SELECT HLA.TOWN_OR_CITY
                    FROM HR.HR_LOCATIONS_ALL HLA,
                         HR.HR_ALL_ORGANIZATION_UNITS HAOU
                   WHERE AI.ORG_ID = HAOU.ORGANIZATION_ID
                         AND HAOU.LOCATION_ID = HLA.LOCATION_ID)
                 || ' , '
                 || TO_CHAR (AI.CREATION_DATE, 'dd Mon rrrr')
                    Location_and_Date,
                 (SELECT PPF.FULL_NAME
                    FROM applsys.FND_USER fu, apps.per_people_F ppf
                   WHERE     FU.USER_ID = AI.CREATED_BY
                         AND ppf.person_id = FU.EMPLOYEE_ID
                         AND PPF.EFFECTIVE_END_DATE > SYSDATE)
                    user_name,
                 AP_INVOICES_PKG.
                  GET_APPROVAL_STATUS (AI.INVOICE_ID,
                                       AI.INVOICE_AMOUNT,
                                       AI.PAYMENT_STATUS_FLAG,
                                       AI.INVOICE_TYPE_LOOKUP_CODE)
                    Status,
                 PHA.PO_HEADER_ID,
                 ai.po_header_id
            FROM AP.AP_INVOICES_ALL AI,
                 APPS.PO_VENDORS PV,
                 APPS.AP_TERMS AT,
                 IBY.iby_ext_bank_accounts IBYBNK,
                 AP.ap_payment_schedules_all APSA,
                 PO_HEADERS_ALL PHA,
                 AP_TERMS_TL ATT
           WHERE /*AP_INVOICES_PKG.
                  GET_APPROVAL_STATUS (AI.INVOICE_ID,
                                       AI.INVOICE_AMOUNT,
                                       AI.PAYMENT_STATUS_FLAG,
                                       AI.INVOICE_TYPE_LOOKUP_CODE) = 'UNPAID'
                 AND*/ AI.attribute7 = PHA.segment1
                 --AND (pha.segment1 = :p_po_num OR :p_po_num IS NULL)
                 AND (AI.ATTRIBUTE7 = :p_po_num OR :p_po_num IS NULL)
                 AND PV.VENDOR_ID = :p_vendor_id
                 AND (AI.DOC_SEQUENCE_VALUE = :p_voucher_num
                      OR :p_voucher_num IS NULL)
                 --                 AND (AI.CREATION_DATE = TRUNC (
                 --                                                  TO_DATE (
                 --                                                     :p_date,
                 --                                                     'RRRR/MM/DD HH24:MI:SS'))OR :p_date is Null)
                 AND APSA.INVOICE_ID = AI.INVOICE_ID
                 AND PV.VENDOR_ID(+) = AI.VENDOR_ID
                 AND AI.INVOICE_TYPE_LOOKUP_CODE = 'PREPAYMENT'
                 AND AI.TERMS_ID = AT.TERM_ID(+)
                 AND IBYBNK.EXT_BANK_ACCOUNT_ID(+) =
                        AI.EXTERNAL_BANK_ACCOUNT_ID
                 AND AT.NAME = ATT.NAME
                 AND :p_po_num not in '-'
                 ) tab
GROUP BY tab.INVOICE_NUM,
         tab.CREATION_DATE,
         tab.NO_PENGAJUAN,
         tab.VENDOR_ID,
         tab.VENDOR_NAME,
         tab.attribute7,
         tab.NO_PO,
         tab.SITE,
         tab.TERM_PAYMENT,
         tab.DESCRIPTION,
         tab.BANK,
         tab.BRANCH,
         tab.BENEFICIARY_NAME,
         tab.NO_REKENING,
         tab.SWIFT_CODE,
         tab.IBAN,
         tab.CURRENCY,
         tab.AMOUNT,
         tab.BANK_KELUAR,
         tab.BANK_KELUAR,
         tab.LOCATION_AND_DATE,
         tab.USER_NAME,
         tab.STATUS      
UNION ALL
SELECT tab.INVOICE_NUM,
         tab.CREATION_DATE,
         tab.NO_PENGAJUAN,
         tab.VENDOR_ID,
         tab.VENDOR_NAME,
         tab.attribute7,
         tab.NO_PO,
         tab.SITE,
         tab.TERM_PAYMENT,
         tab.DESCRIPTION,
         tab.BANK,
         tab.BRANCH,
         tab.BENEFICIARY_NAME,
         tab.NO_REKENING,
         tab.SWIFT_CODE,
         tab.IBAN,
         LISTAGG (tab.DUE_DATE, ',') WITHIN GROUP (ORDER BY tab.DUE_DATE)
            DUE_DATE,
         tab.CURRENCY,
         tab.AMOUNT,
         tab.BANK_KELUAR,
         tab.LOCATION_AND_DATE,
         tab.USER_NAME,
         tab.STATUS
    FROM (  
    SELECT AI.INVOICE_NUM,
                 AI.CREATION_DATE,
                 --AI.INVOICE_ID,
                 AI.DOC_SEQUENCE_VALUE NO_PENGAJUAN,
                 AI.VENDOR_ID,
                 case when (pha.attribute2 = 'None') or (pha.attribute2 = '') or (pha.attribute2 is null) then
                      pv.vendor_name
                 else
                      (SELECT address_line3
                       FROM ap_supplier_sites_all
                       WHERE vendor_site_id = ai.vendor_site_id
                       AND org_id = ai.org_id)     
                 end as vendor_name,
                 AI.attribute7 attribute7,
                 '-' NO_PO,
                 -- update site buat veranda
                   (select city from ap_supplier_sites_all apss
                 where apss.vendor_id = AI.VENDOR_ID
                    AND ORG_ID = AI.ORG_ID) AS SITE,
                 --AI.TERMS_ID,
                 ATT.DESCRIPTION TERM_PAYMENT,
                 AI.DESCRIPTION,
                 (SELECT HP.PARTY_NAME
                    FROM ar.hz_parties hp, ar.hz_party_usg_assignments hpua
                   WHERE     hp.party_id = IBYBNK.BANK_ID
                         AND hp.party_id = hpua.party_id
                         AND hpua.party_usage_code = 'BANK')
                    BANK,
                 (SELECT HP.PARTY_NAME
                    FROM ar.hz_parties hp, ar.hz_party_usg_assignments hpua
                   WHERE     hp.party_id = IBYBNK.BRANCH_ID
                         AND hp.party_id = hpua.party_id
                         AND hpua.party_usage_code = 'BANK_BRANCH')
                    Branch,
                 ibybnk.bank_account_name BENEFICIARY_NAME,
                 IBYBNK.BANK_ACCOUNT_NUM NO_REKENING,
                 --IBYBNK.EXT_BANK_ACCOUNT_ID,
                 IBYBNK.ATTRIBUTE1 Swift_Code,
                 IBYBNK.ATTRIBUTE2 IBAN,
                 APSA.DUE_DATE,
                 AI.PAYMENT_CURRENCY_CODE CURRENCY,
                 AI.INVOICE_AMOUNT AMOUNT,
                 AI.ATTRIBUTE3 BANK_KELUAR,
                 (SELECT HLA.TOWN_OR_CITY
                    FROM HR.HR_LOCATIONS_ALL HLA,
                         HR.HR_ALL_ORGANIZATION_UNITS HAOU
                   WHERE AI.ORG_ID = HAOU.ORGANIZATION_ID
                         AND HAOU.LOCATION_ID = HLA.LOCATION_ID)
                 || ' , '
                 || TO_CHAR (AI.CREATION_DATE, 'dd Mon rrrr')
                    Location_and_Date,
                 (SELECT PPF.FULL_NAME
                    FROM applsys.FND_USER fu, apps.per_people_F ppf
                   WHERE     FU.USER_ID = AI.CREATED_BY
                         AND ppf.person_id = FU.EMPLOYEE_ID
                         AND PPF.EFFECTIVE_END_DATE > SYSDATE)
                    user_name,
                 AP_INVOICES_PKG.
                  GET_APPROVAL_STATUS (AI.INVOICE_ID,
                                       AI.INVOICE_AMOUNT,
                                       AI.PAYMENT_STATUS_FLAG,
                                       AI.INVOICE_TYPE_LOOKUP_CODE)
                    Status,
                 null PO_HEADER_ID,
                 ai.po_header_id
            FROM AP.AP_INVOICES_ALL AI,
                 APPS.PO_VENDORS PV,
                 APPS.AP_TERMS AT,
                 IBY.iby_ext_bank_accounts IBYBNK,
                 AP.ap_payment_schedules_all APSA,
                 --PO_HEADERS_ALL PHA,
                 AP_TERMS_TL ATT
           WHERE /*AP_INVOICES_PKG.
                  GET_APPROVAL_STATUS (AI.INVOICE_ID,
                                       AI.INVOICE_AMOUNT,
                                       AI.PAYMENT_STATUS_FLAG,
                                       AI.INVOICE_TYPE_LOOKUP_CODE) = 'UNPAID'*/
                 --AND AI.attribute7 = PHA.segment1
                 --AND (pha.segment1 = :p_po_num OR :p_po_num IS NULL)
                 --AND 
                 (AI.ATTRIBUTE7 = :p_po_num OR :p_po_num IS NULL)
                 AND (PV.VENDOR_ID = :p_vendor_id OR :P_vendor_id is null)
                 AND (AI.DOC_SEQUENCE_VALUE = :p_voucher_num
                      OR :p_voucher_num IS NULL)
                 --                 AND (AI.CREATION_DATE = TRUNC (
                 --                                                  TO_DATE (
                 --                                                     :p_date,
                 --                                                     'RRRR/MM/DD HH24:MI:SS'))OR :p_date is Null)
                 AND APSA.INVOICE_ID = AI.INVOICE_ID
                 AND PV.VENDOR_ID(+) = AI.VENDOR_ID
                 AND AI.INVOICE_TYPE_LOOKUP_CODE = 'PREPAYMENT'
                 AND AI.TERMS_ID = AT.TERM_ID(+)
                 AND IBYBNK.EXT_BANK_ACCOUNT_ID(+) =
                        AI.EXTERNAL_BANK_ACCOUNT_ID
                 AND AT.NAME = ATT.NAME
                 AND :p_po_num = '-'            
                 ) tab
GROUP BY tab.INVOICE_NUM,
         tab.CREATION_DATE,
         tab.NO_PENGAJUAN,
         tab.VENDOR_ID,
         tab.VENDOR_NAME,
         tab.attribute7,
         tab.NO_PO,
        tab.SITE,
         tab.TERM_PAYMENT,
         tab.DESCRIPTION,
         tab.BANK,
         tab.BRANCH,
         tab.BENEFICIARY_NAME,
         tab.NO_REKENING,
         tab.SWIFT_CODE,
         tab.IBAN,
         tab.CURRENCY,
         tab.AMOUNT,
         tab.BANK_KELUAR,
         tab.BANK_KELUAR,
         tab.LOCATION_AND_DATE,
         tab.USER_NAME,
         tab.STATUS         