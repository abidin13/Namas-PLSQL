select * from GL_INTERFACE
where USER_JE_SOURCE_NAME = 'Spreadsheet'

delete from GL_INTERFACE
where USER_JE_SOURCE_NAME = 'Spreadsheet'

create table GL_INTERFACE_030815
as 
select * from GL_INTERFACE
where USER_JE_SOURCE_NAME = 'Spreadsheet'
[11:25:47 AM] Pabenri Dela: upload TB