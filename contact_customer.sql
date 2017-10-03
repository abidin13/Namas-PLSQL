SELECT hp.party_id,hp.party_name customer_name, h_contact.party_name contact_person_name,hcp.phone_number,
hcp.EMAIL_ADDRESS,cust.account_name,cust.account_number
FROM
hz_parties hp,
hz_relationships hr,
hz_parties h_contact ,
hz_contact_points hcp,
hz_cust_accounts cust
where
1=1
and hr.subject_id = h_contact.PARTY_ID
and hr.object_id = hp.party_id
and hcp.owner_table_id(+) = hr.party_id
and cust.party_id = hp.party_id
and hcp.CONTACT_POINT_TYPE ='EMAIL'
and hcp.STATUS = 'A'
AND hp.party_name=:1