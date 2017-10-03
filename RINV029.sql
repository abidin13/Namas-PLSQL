/* Formatted on 2016/09/26 10:15 (Formatter Plus v4.8.8) */
SELECT (SELECT NAME
          FROM hr_all_organization_units
         WHERE organization_id = :org_id) AS ou,
       mrth.request_number AS no_move_order, mtty.transaction_type_name,
       mrth.creation_date AS tanggal, SUBSTR (mlook.meaning, 1, 60) AS status
  FROM mtl_txn_request_headers mrth,
       mtl_transaction_types mtty,
       mtl_txn_request_lines mrtl,
       mfg_lookups mlook
 WHERE 1 = 1 
   AND mrth.organization_id = :org_id
   AND mrth.header_id = mrtl.header_id
   AND mrtl.line_status = mlook.lookup_code
   AND mlook.lookup_type = 'MTL_TXN_REQUEST_STATUS'
   AND mlook.lookup_code IN (3, 5, 6)
   AND mtty.transaction_type_id IN
          ('111',
           '112',
           '113',
           '114',
           '115',
           '116',
           '117',
           '118',
           '119',
           '120',
           '121',
           '122',
           '123',
           '124',
           '125',
           '126',
           '127',
           '143',
           '144',
           '145',
           '146',
           '147',
           '168',
           '169',
           '192',
           '193',
           '234',
           '235'
          )
   AND TRUNC (mrth.creation_date) BETWEEN TO_DATE (:p_from_date,
                                                   'RRRR/MM/DD HH24:MI:SS'
                                                  )
                                      AND TO_DATE (:p_to_date,
                                                   'RRRR/MM/DD HH24:MI:SS'
                                                  )
-- document refrence Doc ID 431479.1)