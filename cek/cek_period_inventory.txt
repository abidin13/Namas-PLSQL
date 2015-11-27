select * from rcv_shipments_header



Select * from org_acct_periods
where organization_id = '194'
where PERIOD_YEAR = '2015'
where organization_id=(select organization_id from org_organization_definitions where organization_code='&organization_code')


org_inv_periods

select * from org_organization_definitions