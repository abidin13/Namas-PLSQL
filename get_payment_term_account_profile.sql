 SELECT cp.cust_account_profile_id,
       cp.cust_account_id,
       cp.collector_id,
       HP.PARTY_NAME,
       col.NAME collector_name,
       cp.profile_class_id,
       cpc.NAME profile_class_name,
       cp.site_use_id,
       term.NAME standard_terms,
       cp.statement_cycle_id,
       cyc.NAME statement_cycle_name,
       cp.autocash_hierarchy_id,
       hier.hierarchy_name autocash_hierarchy_name,
       cp.grouping_rule_id,
       grp.NAME grouping_rule_name,
       cp.autocash_hierarchy_id_for_adr,
       hier_adr.hierarchy_name autocash_hierarchy_name_adr,
       cp.*
  FROM hz_customer_profiles cp,
       ar_collectors col,
       hz_cust_profile_classes cpc,
       ar_dunning_letter_sets dun_set,
       ar_statement_cycles cyc,
       ar_autocash_hierarchies hier,
       ra_grouping_rules grp,
       ra_terms term,
       ar_autocash_hierarchies hier_adr,
       HZ_CUST_ACCOUNTS hca,
       HZ_PARTIES HP
 WHERE cp.collector_id          = col.collector_id
   AND cp.profile_class_id      = cpc.profile_class_id(+)
   AND cp.dunning_letter_set_id = dun_set.dunning_letter_set_id(+)
   AND cp.statement_cycle_id    = cyc.statement_cycle_id(+)
   AND cp.autocash_hierarchy_id = hier.autocash_hierarchy_id(+)
   AND cp.grouping_rule_id      = grp.grouping_rule_id(+)
   AND cp.standard_terms        = term.term_id(+)
   AND cp.autocash_hierarchy_id_for_adr = hier_adr.autocash_hierarchy_id(+)
   and cp.cust_account_id = hca.CUST_ACCOUNT_ID
   and hca.account_number = '5316'
   and HP.PARTY_ID = HCA.PARTY_ID
--   AND cp.party_id              = vl_party_id
--   AND cp.cust_account_id       = vl_cust_account_id
--   AND cp.site_use_id           = vl_site_use_id
------------------------------------------------------------------MASTER-----------------------------------------------------------------------
/* FORMATTED ON 2017/04/07 14:43 (FORMATTER PLUS V4.8.8) */
SELECT A.CUST_ACCOUNT_ID CUSTOMER_ID, P.PARTY_ID,
       A.ACCOUNT_NUMBER CUSTOMER_NUMBER, P.PARTY_NUMBER REGISTRY_ID,
       P.PARTY_NAME CUSTOMER_NAME, L.ADDRESS1, L.ADDRESS2, L.ADDRESS3,
       L.ADDRESS4, L.CITY, L.COUNTRY, L.PO_BOX_NUMBER, SA.CUST_ACCT_SITE_ID,
       SU.SITE_USE_ID, SU.SITE_USE_CODE, L.LOCATION_ID,
       SU.LOCATION LOCATION_CODE, SA.ORG_ID,
       T.TERRITORY_SHORT_NAME COUNTRY_NAME, T.DESCRIPTION COUNTRY_DESCRIPTION,
       P.ORIG_SYSTEM_REFERENCE, A.STATUS CUST_STATUS,
       SA.STATUS CUST_SITE_STATUS,
       NVL ((SELECT OVERALL_CREDIT_LIMIT
               FROM HZ_CUST_PROFILE_AMTS CL
              WHERE CL.CUST_ACCOUNT_ID = A.CUST_ACCOUNT_ID
                AND CL.SITE_USE_ID = SU.SITE_USE_ID),
            0
           ) CREDIT_LIMIT,
       (SELECT TU.PAYMENT_TERM_ID
          FROM HZ_CUST_SITE_USES_ALL TU
         WHERE TU.SITE_USE_ID = SU.SITE_USE_ID) TERM_ID,
       (SELECT TM.NAME
          FROM HZ_CUST_SITE_USES_ALL TU, RA_TERMS_VL TM
         WHERE TM.TERM_ID = TU.PAYMENT_TERM_ID
           AND TU.SITE_USE_ID = SU.SITE_USE_ID) TERM_NAME,
       S.PARTY_SITE_NAME, HCP.PHONE_AREA_CODE AREACODE,
       HCP.PHONE_COUNTRY_CODE COUNTRY_CODE,
       HCP.PHONE_EXTENSION PHONE_EXTENSION, HCP.PHONE_NUMBER TELEPHONE,
       HCP1.PHONE_COUNTRY_CODE FAX_COUNTRY_CODE,
       HCP1.PHONE_AREA_CODE FAX_AREACODE, HCP1.PHONE_NUMBER FAX,
       HCP2.EMAIL_ADDRESS EMAIL
  FROM HZ_LOCATIONS L,
       HZ_PARTY_SITES S,
       HZ_PARTIES P,
       HZ_CUST_ACCOUNTS A,
       HZ_CUST_ACCT_SITES_ALL SA,
       HZ_CUST_SITE_USES_ALL SU,
       FND_TERRITORIES_VL T,
       HZ_CONTACT_POINTS HCP,
       HZ_CONTACT_POINTS HCP1,
       HZ_CONTACT_POINTS HCP2
 WHERE L.LOCATION_ID = S.LOCATION_ID
   AND S.PARTY_ID = P.PARTY_ID
   AND A.PARTY_ID = P.PARTY_ID
   AND SA.CUST_ACCOUNT_ID = A.CUST_ACCOUNT_ID
   AND SA.PARTY_SITE_ID = S.PARTY_SITE_ID
   AND SA.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
   AND T.TERRITORY_CODE = L.COUNTRY
--   AND p.PARTY_NAME like '%BHUANA%'
   and A.account_number = '5316'
   AND A.STATUS = 'A'
   AND SA.STATUS = 'A'

   
   AND P.PARTY_ID = HCP.OWNER_TABLE_ID ()
   AND HCP.OWNER_TABLE_NAME () = 'HZ_PARTIES'
   AND HCP.CONTACT_POINT_TYPE () = 'PHONE'
   AND HCP.PHONE_LINE_TYPE () = 'GEN'
   AND P.PARTY_ID = HCP1.OWNER_TABLE_ID ()
   AND HCP1.OWNER_TABLE_NAME () = 'HZ_PARTIES'
   AND HCP1.CONTACT_POINT_TYPE () = 'PHONE'
   AND HCP1.PHONE_LINE_TYPE () = 'FAX'
   AND P.PARTY_ID = HCP2.OWNER_TABLE_ID ()
   AND HCP2.OWNER_TABLE_NAME () = 'HZ_PARTIES'
   AND HCP2.CONTACT_POINT_TYPE () = 'EMAIL'
   AND A.ACCOUNT_NUMBER LIKE '23643%'
-- AND A.CUST_ACCOUNT_ID=1043
-----------------------------------------------------END MASTER KEDUA ----------------------------------------------------------------------------
--------------------------------------------------------- READY !!!!!!!-------------------------------------
 SELECT hca.account_number,
        HP.PARTY_NAME,
        term.TERM_ID,
       term.NAME standard_terms,
       SA.ORG_ID
  FROM hz_customer_profiles cp,
       ar_collectors col,
       hz_cust_profile_classes cpc,
       ar_dunning_letter_sets dun_set,
       ar_statement_cycles cyc,
       ar_autocash_hierarchies hier,
       ra_grouping_rules grp,
       ra_terms term,
       ar_autocash_hierarchies hier_adr,
       HZ_CUST_ACCOUNTS hca,
       HZ_PARTIES HP,
       HZ_CUST_ACCT_SITES_ALL SA
 WHERE cp.collector_id          = col.collector_id
   AND cp.profile_class_id      = cpc.profile_class_id(+)
   AND cp.dunning_letter_set_id = dun_set.dunning_letter_set_id(+)
   AND cp.statement_cycle_id    = cyc.statement_cycle_id(+)
   AND cp.autocash_hierarchy_id = hier.autocash_hierarchy_id(+)
   AND cp.grouping_rule_id      = grp.grouping_rule_id(+)
   AND cp.standard_terms        = term.term_id(+)
   AND cp.autocash_hierarchy_id_for_adr = hier_adr.autocash_hierarchy_id(+)
   and cp.cust_account_id = hca.CUST_ACCOUNT_ID
   and sa.CUST_ACCOUNT_ID = hca.CUST_ACCOUNT_ID
   and HP.PARTY_ID = HCA.PARTY_ID
   and hca.account_number = '3245'
--   AND cp.party_id              = vl_party_id
--   AND cp.cust_account_id       = vl_cust_account_id
--   AND cp.site_use_id           = vl_site_use_id
   ----------------------------------------------------------------END-----------------------------------------------------


   --------------------------------------------------------READY 2 !!!!!!!!!!!--------------------------------------------------
   SELECT A.CUST_ACCOUNT_PROFILE_ID, C.account_number, C.ACCOUNT_NAME, D.TERM_ID TERM_ID_ACCOUNT_PROFILE, D.NAME TERM_NAME_ACCOUNT_PROFILE,       (        SELECT TERM_ID FROM RA_TERMS_VL WHERE TERM_ID = (SELECT PAYMENT_TERM_ID                                                       FROM hz_cust_site_uses_all                                                      WHERE cust_acct_site_id = (SELECT cust_acct_site_id                                                                                  FROM hz_cust_acct_sites_all                                                                                 WHERE cust_account_id = C.cust_account_id                                                                                 AND ROWNUM = 1)                                                      AND SITE_USE_CODE = 'BILL_TO'                                                      AND ROWNUM = 1                                                      )       ) TERM_ID_BILL_TO,       (        SELECT NAME FROM RA_TERMS_VL WHERE TERM_ID = (SELECT PAYMENT_TERM_ID                                                       FROM hz_cust_site_uses_all                                                      WHERE cust_acct_site_id = (SELECT cust_acct_site_id                                                                                  FROM hz_cust_acct_sites_all                                                                                 WHERE cust_account_id = C.cust_account_id                                                                                 AND ROWNUM = 1)                                                      AND SITE_USE_CODE = 'BILL_TO'                                                      AND ROWNUM = 1                                                      )       ) TERM_NAME_BILL_TOFROM   hz_customer_profiles A, hz_cust_profile_classes B, HZ_CUST_ACCOUNTS C, ra_terms DWHERE  A.profile_class_id      = B.profile_class_id(+)AND    A.cust_account_id = C.CUST_ACCOUNT_IDAND    A.standard_terms = D.term_id(+)ORDER BY C.ACCOUNT_NAME, C.account_numberAND    C.account_number = '1418'
   