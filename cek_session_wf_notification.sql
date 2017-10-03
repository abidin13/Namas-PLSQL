select do.owner,do.object_name,do.object_type,dl.session_id,vs.serial#, vs.program,vs.machine,vs.osuser
from dba_locks dl,dba_objects do,v$session vs
where do.object_name ='WF_NOTIFICATIONS' and do.object_type='TABLE' and dl.lock_id1 =do.object_id and vs.sid = dl.session_id;



-- script alternya 
alter system kill session '64,9627' immediate