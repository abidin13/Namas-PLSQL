SELECT party_supp.party_name supplier_name
, aps.segment1 supplier_number
, ass.vendor_site_code supplier_site
, ieb.bank_account_num
, ieb.bank_account_name
, party_bank.party_name bank_name
, branch_prof.bank_or_branch_number bank_number
, party_branch.party_name branch_name
, branch_prof.bank_or_branch_number branch_number
FROM hz_parties party_supp
, ap_suppliers aps
, hz_party_sites site_supp
, ap_supplier_sites_all ass
, iby_external_payees_all iep
, iby_pmt_instr_uses_all ipi
, iby_ext_bank_accounts ieb
, hz_parties party_bank
, hz_parties party_branch
, hz_organization_profiles bank_prof
, hz_organization_profiles branch_prof
WHERE party_supp.party_id = aps.party_id
AND party_supp.party_id = site_supp.party_id
AND site_supp.party_site_id = ass.party_site_id
AND ass.vendor_id = aps.vendor_id
AND iep.payee_party_id = party_supp.party_id
AND iep.party_site_id = site_supp.party_site_id
AND iep.supplier_site_id = ass.vendor_site_id
AND iep.ext_payee_id = ipi.ext_pmt_party_id
AND ipi.instrument_id = ieb.ext_bank_account_id
AND ieb.bank_id = party_bank.party_id
AND ieb.bank_id = party_branch.party_id
AND party_branch.party_id = branch_prof.party_id
AND party_bank.party_id = bank_prof.party_id
ORDER BY party_supp.party_name
, ass.vendor_site_code; 