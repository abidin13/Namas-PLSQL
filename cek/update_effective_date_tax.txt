select * from wf_users
where name = 'TRK HR 03'

select * from hr_all_organization_units
where name like '%Magna%'
select * from zx_rules_b
where TAX_REGIME_CODE = 'MTN_REGIME'

update zx_rules_b set EFFECTIVE_FROM = '01-JAN-2000'
where TAX_RULE_CODE = 'MTN_RULE_10_IN' 