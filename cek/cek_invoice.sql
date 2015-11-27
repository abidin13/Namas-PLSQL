select * from AP_INVOICES_ALL

select * from AP_INVOICE_LINES_ALL

select * from AP_INVOICES_INTERFACE
where INVOICE_ID = 141671

update AP_INVOICE_LINES_INTERFACE
SET ACCOUNTING_DATE = '17 Jun 2015'
where INVOICE_ID = '141671'

ynpap_trcost_gl
