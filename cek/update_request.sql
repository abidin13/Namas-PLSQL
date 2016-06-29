select * from fnd_concurrent_requests fnr
where request_id ='9663294'


update
   fnd_concurrent_requests
set
   status_code='X',
   phase_code='C'
where status_code='T'
and REQUEST_ID ='9663294' 



SELECT a.request_id, d.sid, d.serial# ,d.osuser,d.process , c.SPID
FROM apps.fnd_concurrent_requests a, apps.fnd_concurrent_processes b, v$process c, v$session d
WHERE a.controlling_manager = b.concurrent_process_id AND c.pid = b.oracle_process_id AND b.session_id=d.audsid AND a.request_id = &request_id AND a.phase_code = 'R'; 





ALTER SYSTEM KILL SESSION 'sid,serial#';


