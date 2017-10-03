SELECT * FROM
(

SELECT  
        
        
        a.trx_number, a.trx_date, 
        
        case 
             when :JASA_MAKLOON = 'Y' then 
                'JASA MAKLOON' 
             else '' 
        end AS MAKLOON,
        
        (
         SELECT CASE 
                   WHEN (XX.NAME LIKE 'N%') AND (LENGTH(XX.NAME) = 4) THEN SUBSTR(XX.NAME,1,3)
                   WHEN (XX.NAME LIKE 'N%') AND (LENGTH(XX.NAME) = 5) THEN SUBSTR(XX.NAME,1,4)
                ELSE XX.NAME
                END 
         FROM   RA_TERMS_TL XX
         WHERE  XX.TERM_ID = A.TERM_ID
        ) AS Term_Name,
        
        
        (
         SELECT RR.DUE_DATE
         FROM   AR_PAYMENT_SCHEDULES_ALL RR
         WHERE  RR.CUSTOMER_TRX_ID = A.CUSTOMER_TRX_ID
        ) AS term_due_date,
         
       
        CASE WHEN b.attribute2 <> '' or b.attribute2 Is Null then
             (select CASE WHEN D.ACCOUNT_NAME IS NULL OR D.ACCOUNT_NAME =''  THEN d.attribute1 ELSE D.ACCOUNT_NAME END from hz_cust_accounts d where d.cust_account_id = a.bill_to_customer_id )
        Else b.attribute2 END as Customer_name,
        
        CASE WHEN b.attribute3 <> '' or b.attribute3 Is Null then
        (
         select 
            (select address1 from hz_locations where location_id = hz_party_sites.location_id)||' '||
            (select address2 from hz_locations where location_id = hz_party_sites.location_id)||' '||
            (select address3 from hz_locations where location_id = hz_party_sites.location_id)||' '||
            (select address4 from hz_locations where location_id = hz_party_sites.location_id)||' '||
            (select city from hz_locations where location_id = hz_party_sites.location_id)||' '|| 
            (select postal_code from hz_locations where location_id = hz_party_sites.location_id)
         from hz_party_sites where party_site_id=
        (select party_site_id from hz_cust_acct_sites_all where cust_acct_site_id=(select cust_acct_site_id from hz_cust_site_uses_all where site_use_id= A.BILL_TO_SITE_USE_ID))
        )
        ELSE  b.attribute3 END as Customer_address,
        
        
        FN_SUM_TOT_EXT_AMOUNT(a.org_id,a.trx_number,a.invoice_currency_code) AS TOTAL_EXT_AMOUNT,
        FN_SUM_TAX_INV(a.org_id,a.trx_number,a.invoice_currency_code) AS TOTAL_TAX,
        FN_SUM_TOT_INV(a.org_id,a.trx_number,a.invoice_currency_code) AS TOTAL_INV,
        FN_TERBILANG_INV(a.org_id,a.trx_number,a.invoice_currency_code) as terbilang,
        
        
        (select (select x.town_or_city from hr_locations_all x where x.location_id = z.location_id) 
         from hr_all_organization_units z
         where z.organization_id= a.org_id) as town_city,
        
        a.ATTRIBUTE1 as Bank_Name,a.ATTRIBUTE2 as Bank_Branch, a.ATTRIBUTE3 as Account_Name,a.ATTRIBUTE4 as Account_Number,
        'Payment accept if the Giro has been credited to our account' as Note,


       (
        SELECT NAMA 
        FROM   YNP_SIGNNAME 
        WHERE  ID_SIGNNAME = :SIGNNAME
       ) AS SIGN_NAME,
       
       (
        SELECT JABATAN
        FROM   YNP_SIGNNAME 
        WHERE  ID_SIGNNAME = :SIGNNAME
       ) AS POSITION,
        

        B.CUSTOMER_TRX_LINE_ID, 
        
        a.trx_number AS NOMOR, a.trx_date AS TANGGAL, 
        
        (
         SELECT CASE 
                   WHEN (XX.NAME LIKE 'N%') AND (LENGTH(XX.NAME) = 4) THEN SUBSTR(XX.NAME,1,3)
                   WHEN (XX.NAME LIKE 'N%') AND (LENGTH(XX.NAME) = 5) THEN SUBSTR(XX.NAME,1,4)
                ELSE XX.NAME
                END 
         FROM   RA_TERMS_TL XX
         WHERE  XX.TERM_ID = A.TERM_ID
        ) AS TERM,
        
        
        (
         SELECT RR.DUE_DATE
         FROM   AR_PAYMENT_SCHEDULES_ALL RR
         WHERE  RR.CUSTOMER_TRX_ID = A.CUSTOMER_TRX_ID
        ) AS DUE_DATE,
        
        1 AS FLAG, b.line_number, b.interface_line_attribute3, a.purchase_order, 
        
        /*CASE WHEN b.attribute1 <> '' or b.attribute1 is Null  then b.description
        ELSE b.attribute1 END AS description,*/
        
             NVL(
       
       (SELECT
OOLA.ATTRIBUTE1
FROM OE_ORDER_LINES_ALL OOLA
WHERE OOLA.LINE_ID = B.INTERFACE_LINE_ATTRIBUTE6),
        
        CASE 
            WHEN
                 (            
                  SELECT AA.LONG_DESCRIPTION
                  FROM   MTL_SYSTEM_ITEMS_TL AA, ORG_ORGANIZATION_DEFINITIONS BB
                  WHERE  AA.ORGANIZATION_ID = BB.ORGANIZATION_ID
                  AND    AA.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
                  AND    BB.OPERATING_UNIT = B.ORG_ID
                  AND    BB.OPERATING_UNIT IS NOT NULL
                  AND    ROWNUM = 1
                 ) IS NOT NULL
                 OR 
                 (
                  SELECT AA.LONG_DESCRIPTION
                  FROM   MTL_SYSTEM_ITEMS_TL AA, ORG_ORGANIZATION_DEFINITIONS BB
                  WHERE  AA.ORGANIZATION_ID = BB.ORGANIZATION_ID
                  AND    AA.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
                  AND    BB.OPERATING_UNIT = B.ORG_ID
                  AND    BB.OPERATING_UNIT IS NOT NULL
                  AND    ROWNUM = 1
                 ) <> ''
            THEN
                 (
                  SELECT AA.LONG_DESCRIPTION
                  FROM   MTL_SYSTEM_ITEMS_TL AA, ORG_ORGANIZATION_DEFINITIONS BB
                  WHERE  AA.ORGANIZATION_ID = BB.ORGANIZATION_ID
                  AND    AA.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
                  AND    BB.OPERATING_UNIT = B.ORG_ID
                  AND    BB.OPERATING_UNIT IS NOT NULL
                  AND    ROWNUM = 1
                 )
            WHEN
                 (
                  SELECT AA.DESCRIPTION
                  FROM   MTL_SYSTEM_ITEMS_TL AA, ORG_ORGANIZATION_DEFINITIONS BB
                  WHERE  AA.ORGANIZATION_ID = BB.ORGANIZATION_ID
                  AND    AA.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
                  AND    BB.OPERATING_UNIT = B.ORG_ID
                  AND    BB.OPERATING_UNIT IS NOT NULL
                  AND    ROWNUM = 1
                 ) IS NOT NULL
                 OR 
                 (
                  SELECT AA.DESCRIPTION
                  FROM   MTL_SYSTEM_ITEMS_TL AA, ORG_ORGANIZATION_DEFINITIONS BB
                  WHERE  AA.ORGANIZATION_ID = BB.ORGANIZATION_ID
                  AND    AA.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
                  AND    BB.OPERATING_UNIT = B.ORG_ID
                  AND    BB.OPERATING_UNIT IS NOT NULL
                  AND    ROWNUM = 1
                 ) <> '' 
            THEN
                 (
                  SELECT AA.DESCRIPTION
                  FROM   MTL_SYSTEM_ITEMS_TL AA, ORG_ORGANIZATION_DEFINITIONS BB
                  WHERE  AA.ORGANIZATION_ID = BB.ORGANIZATION_ID
                  AND    AA.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
                  AND    BB.OPERATING_UNIT = B.ORG_ID
                  AND    BB.OPERATING_UNIT IS NOT NULL
                  AND    ROWNUM = 1
                 )
        ELSE  B.DESCRIPTION        
        END) AS description,
        
        case when b.quantity_credited is not null then b.quantity_credited else b.quantity_invoiced end as quantity_invoiced , 
        
        b.unit_selling_price, a.invoice_currency_code, b.extended_amount
        
        
        

FROM  ra_customer_trx_all a, ra_customer_trx_lines_all b
   WHERE a.customer_trx_id = b.customer_trx_id 
   AND   a.complete_flag = 'Y'
   AND   b.UNIT_SELLING_PRICE is not null 
   AND   a.org_id = :org_id
   AND   A.TRX_NUMBER BETWEEN :trx_number1 and :trx_number2
   
UNION ALL

SELECT  
       
        
        (SELECT TRX_NUMBER 
         FROM   RA_CUSTOMER_TRX_ALL
         WHERE  CUSTOMER_TRX_ID = (
                                   SELECT APPLIED_CUSTOMER_TRX_ID
                                   FROM   AR_RECEIVABLE_APPLICATIONS_ALL
                                   WHERE  CUSTOMER_TRX_ID = A.CUSTOMER_TRX_ID
                                   AND    DISPLAY = 'Y'
                                   AND    ROWNUM = 1
                                  )
        ) AS TRX_NUMBER,

        
        (SELECT TRX_DATE
         FROM   RA_CUSTOMER_TRX_ALL
         WHERE  CUSTOMER_TRX_ID = (
                                   SELECT APPLIED_CUSTOMER_TRX_ID 
                                   FROM   AR_RECEIVABLE_APPLICATIONS_ALL
                                   WHERE  CUSTOMER_TRX_ID = A.CUSTOMER_TRX_ID
                                   AND    DISPLAY = 'Y'
                                   AND    ROWNUM = 1
                                  )
        ) AS TRX_DATE,
        
        case 
            when :JASA_MAKLOON = 'Y' then 
                 'JASA MAKLOON' 
            else '' 
        end AS MAKLOON,

        (
         SELECT CASE 
                   WHEN (XX.NAME LIKE 'N%') AND (LENGTH(XX.NAME) = 4) THEN SUBSTR(XX.NAME,1,3)
                   WHEN (XX.NAME LIKE 'N%') AND (LENGTH(XX.NAME) = 5) THEN SUBSTR(XX.NAME,1,4)
                ELSE XX.NAME
                END 
         FROM   RA_TERMS_TL XX
         WHERE  XX.TERM_ID = (
                              SELECT TERM_ID
                              FROM   RA_CUSTOMER_TRX_ALL
                              WHERE  CUSTOMER_TRX_ID = (
                                                        SELECT APPLIED_CUSTOMER_TRX_ID 
                                                        FROM   AR_RECEIVABLE_APPLICATIONS_ALL
                                                        WHERE  CUSTOMER_TRX_ID = A.CUSTOMER_TRX_ID
                                                        AND    DISPLAY = 'Y'
                                                        AND    ROWNUM = 1
                                                       )
                              )--A.TERM_ID
        ) AS Term_Name,


        
        (
         SELECT AA.DUE_DATE
         FROM   AR_PAYMENT_SCHEDULES_ALL AA
         WHERE  AA.CUSTOMER_TRX_ID = (
                                      SELECT APPLIED_CUSTOMER_TRX_ID 
                                      FROM   AR_RECEIVABLE_APPLICATIONS_ALL
                                      WHERE  CUSTOMER_TRX_ID = A.CUSTOMER_TRX_ID
                                      AND    DISPLAY = 'Y'
                                      AND    ROWNUM = 1
                                     )
         
         
                                     --A.CUSTOMER_TRX_ID
        ) AS term_due_date,
        

        
        CASE WHEN b.attribute2 <> '' or b.attribute2 Is Null then
             (select CASE WHEN D.ACCOUNT_NAME IS NULL OR D.ACCOUNT_NAME =''  THEN d.attribute1 ELSE D.ACCOUNT_NAME END from hz_cust_accounts d where d.cust_account_id = a.bill_to_customer_id )
        Else b.attribute2 END as Customer_name,
        
        CASE WHEN b.attribute3 <> '' or b.attribute3 Is Null then
        (
         select 
            (select address1 from hz_locations where location_id = hz_party_sites.location_id)||' '||
            (select address2 from hz_locations where location_id = hz_party_sites.location_id)||' '||
            (select address3 from hz_locations where location_id = hz_party_sites.location_id)||' '||
            (select address4 from hz_locations where location_id = hz_party_sites.location_id)||' '||
            (select city from hz_locations where location_id = hz_party_sites.location_id)||' '|| 
            (select postal_code from hz_locations where location_id = hz_party_sites.location_id)
         from hz_party_sites where party_site_id=
        (select party_site_id from hz_cust_acct_sites_all where cust_acct_site_id=(select cust_acct_site_id from hz_cust_site_uses_all where site_use_id= A.BILL_TO_SITE_USE_ID))
        )
        ELSE  b.attribute3 END as Customer_address,

       
        FN_SUM_TOT_EXT_AMOUNT(a.org_id,(SELECT TRX_NUMBER 
         FROM   RA_CUSTOMER_TRX_ALL
         WHERE  CUSTOMER_TRX_ID = (
                                   SELECT APPLIED_CUSTOMER_TRX_ID 
                                   FROM   AR_RECEIVABLE_APPLICATIONS_ALL
                                   WHERE  CUSTOMER_TRX_ID = A.CUSTOMER_TRX_ID
                                   AND    DISPLAY = 'Y'
                                   AND    ROWNUM = 1
                                  )),a.invoice_currency_code) AS TOTAL_EXT_AMOUNT,
        FN_SUM_TAX_INV(a.org_id,(SELECT TRX_NUMBER 
         FROM   RA_CUSTOMER_TRX_ALL
         WHERE  CUSTOMER_TRX_ID = (
                                   SELECT APPLIED_CUSTOMER_TRX_ID 
                                   FROM   AR_RECEIVABLE_APPLICATIONS_ALL
                                   WHERE  CUSTOMER_TRX_ID = A.CUSTOMER_TRX_ID
                                   AND    DISPLAY = 'Y'
                                   AND    ROWNUM = 1
                                  )),a.invoice_currency_code) AS TOTAL_TAX,
        FN_SUM_TOT_INV(a.org_id,(SELECT TRX_NUMBER 
         FROM   RA_CUSTOMER_TRX_ALL
         WHERE  CUSTOMER_TRX_ID = (
                                   SELECT APPLIED_CUSTOMER_TRX_ID 
                                   FROM   AR_RECEIVABLE_APPLICATIONS_ALL
                                   WHERE  CUSTOMER_TRX_ID = A.CUSTOMER_TRX_ID
                                   AND    DISPLAY = 'Y'
                                   AND    ROWNUM = 1
                                  )),a.invoice_currency_code) AS TOTAL_INV,
        FN_TERBILANG_INV(a.org_id,(SELECT TRX_NUMBER 
         FROM   RA_CUSTOMER_TRX_ALL
         WHERE  CUSTOMER_TRX_ID = (
                                   SELECT APPLIED_CUSTOMER_TRX_ID 
                                   FROM   AR_RECEIVABLE_APPLICATIONS_ALL
                                   WHERE  CUSTOMER_TRX_ID = A.CUSTOMER_TRX_ID
                                   AND    DISPLAY = 'Y'
                                   AND    ROWNUM = 1
                                  )),a.invoice_currency_code) as terbilang,
        
        
        (select (select x.town_or_city from hr_locations_all x where x.location_id = z.location_id) 
         from hr_all_organization_units z
         where z.organization_id= a.org_id) as town_city,
        
        a.ATTRIBUTE1 as Bank_Name,a.ATTRIBUTE2 as Bank_Branch, a.ATTRIBUTE3 as Account_Name,a.ATTRIBUTE4 as Account_Number,
        'Payment accept if the Giro has been credited to our account' as Note,


       (
        SELECT NAMA 
        FROM   YNP_SIGNNAME 
        WHERE  ID_SIGNNAME = :SIGNNAME
       ) AS SIGN_NAME,
       
       (
        SELECT JABATAN
        FROM   YNP_SIGNNAME 
        WHERE  ID_SIGNNAME = :SIGNNAME
       ) AS POSITION,
        

        B.CUSTOMER_TRX_LINE_ID, 
        
        a.trx_number AS NOMOR, a.trx_date AS TANGGAL, 
        (
         SELECT CASE 
                   WHEN (XX.NAME LIKE 'N%') AND (LENGTH(XX.NAME) = 4) THEN SUBSTR(XX.NAME,1,3)
                   WHEN (XX.NAME LIKE 'N%') AND (LENGTH(XX.NAME) = 5) THEN SUBSTR(XX.NAME,1,4)
                ELSE XX.NAME
                END 
         FROM   RA_TERMS_TL XX
         WHERE  XX.TERM_ID = A.TERM_ID
        ) AS TERM,


        
        (
         SELECT AA.DUE_DATE
         FROM   AR_PAYMENT_SCHEDULES_ALL AA
         WHERE  AA.CUSTOMER_TRX_ID = A.CUSTOMER_TRX_ID
        ) AS DUE_DATE,
        
        
        
        2 AS FLAG, b.line_number, b.interface_line_attribute3, a.purchase_order, 
        
        /*CASE WHEN b.attribute1 <> '' or b.attribute1 is Null  then b.description
        ELSE b.attribute1 END AS description,*/
        
       NVL(
       
       (SELECT
OOLA.ATTRIBUTE1
FROM OE_ORDER_LINES_ALL OOLA
WHERE OOLA.LINE_ID = B.INTERFACE_LINE_ATTRIBUTE6),
       
       CASE 
            WHEN
                 (            
                  SELECT AA.LONG_DESCRIPTION
                  FROM   MTL_SYSTEM_ITEMS_TL AA, ORG_ORGANIZATION_DEFINITIONS BB
                  WHERE  AA.ORGANIZATION_ID = BB.ORGANIZATION_ID
                  AND    AA.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
                  AND    BB.OPERATING_UNIT = B.ORG_ID
                  AND    BB.OPERATING_UNIT IS NOT NULL
                  AND    ROWNUM = 1
                 ) IS NOT NULL
                 OR 
                 (
                  SELECT AA.LONG_DESCRIPTION
                  FROM   MTL_SYSTEM_ITEMS_TL AA, ORG_ORGANIZATION_DEFINITIONS BB
                  WHERE  AA.ORGANIZATION_ID = BB.ORGANIZATION_ID
                  AND    AA.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
                  AND    BB.OPERATING_UNIT = B.ORG_ID
                  AND    BB.OPERATING_UNIT IS NOT NULL
                  AND    ROWNUM = 1
                 ) <> ''
            THEN
                 (
                  SELECT AA.LONG_DESCRIPTION
                  FROM   MTL_SYSTEM_ITEMS_TL AA, ORG_ORGANIZATION_DEFINITIONS BB
                  WHERE  AA.ORGANIZATION_ID = BB.ORGANIZATION_ID
                  AND    AA.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
                  AND    BB.OPERATING_UNIT = B.ORG_ID
                  AND    BB.OPERATING_UNIT IS NOT NULL
                  AND    ROWNUM = 1
                 )
            WHEN
                 (
                  SELECT AA.DESCRIPTION
                  FROM   MTL_SYSTEM_ITEMS_TL AA, ORG_ORGANIZATION_DEFINITIONS BB
                  WHERE  AA.ORGANIZATION_ID = BB.ORGANIZATION_ID
                  AND    AA.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
                  AND    BB.OPERATING_UNIT = B.ORG_ID
                  AND    BB.OPERATING_UNIT IS NOT NULL
                  AND    ROWNUM = 1
                 ) IS NOT NULL
                 OR 
                 (
                  SELECT AA.DESCRIPTION
                  FROM   MTL_SYSTEM_ITEMS_TL AA, ORG_ORGANIZATION_DEFINITIONS BB
                  WHERE  AA.ORGANIZATION_ID = BB.ORGANIZATION_ID
                  AND    AA.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
                  AND    BB.OPERATING_UNIT = B.ORG_ID
                  AND    BB.OPERATING_UNIT IS NOT NULL
                  AND    ROWNUM = 1
                 ) <> '' 
            THEN
                 (
                  SELECT AA.DESCRIPTION
                  FROM   MTL_SYSTEM_ITEMS_TL AA, ORG_ORGANIZATION_DEFINITIONS BB
                  WHERE  AA.ORGANIZATION_ID = BB.ORGANIZATION_ID
                  AND    AA.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
                  AND    BB.OPERATING_UNIT = B.ORG_ID
                  AND    BB.OPERATING_UNIT IS NOT NULL
                  AND    ROWNUM = 1
                 )
        ELSE  B.DESCRIPTION        
        END) AS description,
        
        case when b.quantity_credited is not null then b.quantity_credited else b.quantity_invoiced end as quantity_invoiced , 
        
        b.unit_selling_price, a.invoice_currency_code, b.extended_amount         
FROM  ra_customer_trx_all a, ra_customer_trx_lines_all b
   WHERE a.customer_trx_id = b.customer_trx_id 
   and   a.CUSTOMER_TRX_ID IN
                       (
                        SELECT CUSTOMER_TRX_ID FROM ar_receivable_applications_all
                        WHERE  APPLICATION_TYPE = 'CM'
                        AND    DISPLAY = 'Y'
                        AND    applied_customer_trx_id in 
                               (SELECT CUSTOMER_TRX_ID 
                               FROM ra_customer_trx_all 
                               WHERE TRX_NUMBER between :trx_number1 and :trx_number2)
                        )
   AND   a.complete_flag = 'Y'
   and b.line_type = 'LINE'
   ---AND   b.UNIT_SELLING_PRICE is not null 
   AND   a.org_id = :org_id
)PP
ORDER BY FLAG ASC