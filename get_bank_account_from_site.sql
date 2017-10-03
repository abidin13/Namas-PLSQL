/* Formatted on 2016/12/28 16:07 (Formatter Plus v4.8.8) */
SELECT bank_account_num
  FROM iby_ext_bank_accounts
 WHERE ext_bank_account_id IN (
          SELECT instrument_id
            FROM iby_pmt_instr_uses_all
           WHERE ext_pmt_party_id IN (
                    SELECT ext_payee_id
                      FROM iby_external_payees_all
                     WHERE supplier_site_id IN (
                              SELECT vendor_site_id
                                FROM ap_supplier_sites_all
                               WHERE vendor_id IN (SELECT vendor_id
                                                     FROM ap_suppliers
                                                    WHERE vendor_id = 379)
                                 AND org_id = 82)))