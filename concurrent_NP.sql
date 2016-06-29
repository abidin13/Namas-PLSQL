select abb.application_id,
        abb.CONCURRENT_PROGRAM_ID,
        abb.CONCURRENT_PROGRAM_NAME,
        abb.USER_CONCURRENT_PROGRAM_NAME,
        abb.DESCRIPTION        
 from FND_CONCURRENT_PROGRAMS_VL abb
where abb.EXECUTABLE_ID in (select EXECUTABLE_ID  from FND_EXECUTABLES_FORM_V 
where application_name = 'NP')
order by abb.CONCURRENT_PROGRAM_NAME



/* ENabled */
/* Formatted on 2016/05/27 13:52 (Formatter Plus v4.8.8) */
SELECT   *
    FROM fnd_concurrent_programs_vl abb
   WHERE abb.executable_id IN (SELECT executable_id
                                 FROM fnd_executables_form_v
                                WHERE application_name = 'NP')
     AND enabled_flag = 'Y'
ORDER BY abb.concurrent_program_name