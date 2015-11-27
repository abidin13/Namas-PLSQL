select * from ap_suppliers
where vendor_name like '%TNV%'


select * from GL_BALANCES 


select * from coa_desc
where segment5 between '11030001' and '11030008'
and segment1 = '101'


select * from gl_code_combinations

select 'TEST1' as COA,
       (select sum(PERIOD_NET_CR) - sum(PERIOD_NET_DR) as total from GL_BALANCES
where code_combination_id in (select code_combination_id from coa_desc
                              where segment5 between '11030001' and '11030008'
                              and segment2 = '10102')
and period_name = 'JAN-15') as BTJ,
(select sum(PERIOD_NET_CR) - sum(PERIOD_NET_DR) as total from GL_BALANCES
where code_combination_id in (select code_combination_id from coa_desc
                              where segment5 between '11030001' and '11030008'
                              and segment2 = '10102')
and period_name = 'FEB-15') as PET
from dual




le


select * from GL_BALANCES
where code_combination_id  = '10774'
and period_name = 'JAN-15'





FN_SUM_PERITEM_INVOICES_CM



select 'TEST' as coa,
            (SELECT CASE = 'S1' THEN
            
            ELSE)           