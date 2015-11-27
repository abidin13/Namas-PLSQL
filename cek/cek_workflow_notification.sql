SELECT wfl.lookup_code
,      wfl.meaning
FROM wf_notifications        wfn
,    wf_messages             wfm
,    wf_message_attributes   wfma
,    wf_lookups              wfl
WHERE wfn.notification_id = 1035
AND   wfn.message_name = wfm.name
AND   wfn.message_type = wfm.type
AND   wfn.message_name = wfma.message_name
AND   wfn.message_type = wfma.message_type
AND   wfma.name = 'RESULT'
AND   wfl.lookup_type = wfma.format