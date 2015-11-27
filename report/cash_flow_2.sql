select 'Net Income' as COA, 
    (select sum(PERIOD_NET_CR) - sum(PERIOD_NET_DR) as total from GL_BALANCES
    where code_combination_id in (select code_combination_id from coa_desc
                              where segment5 between '40000000' and '59999999'
                              and segment2 = '10102')
 and period_name = 'JAN-15') as JAN,
 (select sum(PERIOD_NET_CR) - sum(PERIOD_NET_DR) as total from GL_BALANCES
    where code_combination_id in (select code_combination_id from coa_desc
                              where segment5 between '40000000' and '59999999'
                              and segment2 = '10102')
 and period_name = 'FEB-15') as FEB
 from dual

union all

select 'Operating Activites' as COA,
    (select sum(PERIOD_NET_CR) - sum(PERIOD_NET_DR) as total from GL_BALANCES
    where code_combination_id in (select code_combination_id from coa_desc
                              where segment5 between '11030001' and '11030008'
                              and segment2 = '10102')
 and period_name = 'JAN-15') as JAN
from dual

union all

select 'Increase or Decrease in Time Deposits' as COA
from dual

union all

select 'Increase or Decrease in Trade Receivables' as COA
from dual

union all

select 'Increase or Decrease in Non Trade Account Receivables' as COA
from dual

union all

select 'Increase or Decrease in Inventories' as COA
from dual

union all

select 'Increase or Decrease in Advance Payment' as COA
from dual

union all

select 'Increase or Decrease in Prepaid Taxt' as COA
from dual

union all

select 'Increase or Decrease in Prepaid Expenses' as COA
from dual

union all

select 'Increase or Decrease in Deffered Charges' as COA
from dual

union all

select 'Increase or Decrease in Trade Accounts Payable' as COA
from dual

union all

select 'Increase or Decrease in Non Trade Payable' as COA
from dual 

union all

select 'Increase or Decrease in Advances From Customers' as COA
from dual

union all

select 'Increase or Decrease Tax Payables' as COA
from dual 

union all

select 'Net Cash used by Operating Activities' as COA
from dual

