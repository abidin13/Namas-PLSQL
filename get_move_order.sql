select * from (
SELECT mtt.description, mtrh.*
            FROM mtl_txn_request_headers mtrh, mtl_transaction_types mtt
           WHERE TRUNC (mtrh.creation_date)
                    BETWEEN TO_DATE (:from_date, 'RRRR/MM/DD HH24:MI:SS')
                        AND TO_DATE (:TO_DATE, 'RRRR/MM/DD HH24:MI:SS')
             AND organization_id IN (
                    SELECT organization_id
                      FROM hr_all_organization_units
                     WHERE location_id IN (
                                SELECT location_id
                                  FROM hr_locations_all
                                 WHERE description LIKE
                                                       '%Namasindo Plas, PT.%')
                       AND mtrh.transaction_type_id = mtt.transaction_type_id
                       AND NAME LIKE '%Produksi%')
)PPP
