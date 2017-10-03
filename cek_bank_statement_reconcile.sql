-- cek bank account
select * from ce_bank_accounts ba
where bank_account_num like '%PETTY CASH%'

-- cek header
select * from ce_statement_headers
where bank_account_id = 10060

-- cek branch
select * from ce_bank_branches_v
where branch_party_id = 3045