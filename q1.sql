SELECT * 
from IBY_EXT_BANK_ACCOUNTS 
WHERE ext_bank_account_id in ( 
								select distinct a.instrument_id 
								from iby_pmt_instr_uses_all a 
								WHERE a.payment_flow = 'DISBURSEMENTS' 
								AND a.instrument_type = 'BANKACCOUNT' 
								AND a.EXT_PMT_PARTY_ID in (
															select EXT_PAYEE_ID 
															from IBY_EXTERNAL_PAYEES_ALL 
															where ( payee_party_id = (
																						select a.party_id 
																						from ap_suppliers a 
																						where a.vendor_id = '<&vendor_id>') 
															and party_site_id in (
																					select b.party_site_id 
																					from ap_supplier_sites_all b 
																					where b.vendor_id = '<vendor_id>' 
																					and b.vendor_site_id = nvlb.vendor_site_id)) ) )  
order by ext_bank_account_id