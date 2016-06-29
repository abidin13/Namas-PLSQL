/* Formatted on 2016/01/22 15:46 (Formatter Plus v4.8.8) */
SELECT   (SELECT NAME
            FROM hr_all_organization_units hs
           WHERE hs.organization_id = aa.organization_id) ou,
         (SELECT COUNT (ab.batch_no)
            FROM gme_batch_header ab
           WHERE ab.batch_status = '1'
             AND ab.organization_id = aa.organization_id
             AND ab.plan_start_date
                    BETWEEN TRUNC (TO_DATE (:tgl1, 'RRRR/MM/DD HH24:MI:SS'))
                        AND TRUNC (TO_DATE (:tgl2, 'RRRR/MM/DD HH24:MI:SS')))
                                                                   AS pending,
         (SELECT COUNT (ab.batch_no)
            FROM gme_batch_header ab
           WHERE ab.batch_status = '2'
             AND ab.organization_id = aa.organization_id
             AND ab.plan_start_date
                    BETWEEN TRUNC (TO_DATE (:tgl1, 'RRRR/MM/DD HH24:MI:SS'))
                        AND TRUNC (TO_DATE (:tgl2, 'RRRR/MM/DD HH24:MI:SS')))
                                                                       AS wip,
         (SELECT COUNT (ab.batch_no)
            FROM gme_batch_header ab
           WHERE ab.batch_status = '3'
             AND ab.organization_id = aa.organization_id
             AND ab.plan_start_date
                    BETWEEN TRUNC (TO_DATE (:tgl1, 'RRRR/MM/DD HH24:MI:SS'))
                        AND TRUNC (TO_DATE (:tgl2, 'RRRR/MM/DD HH24:MI:SS')))
                                                                  AS COMPLETE,
         (SELECT COUNT (ab.batch_no)
            FROM gme_batch_header ab
           WHERE ab.batch_status = '4'
             AND ab.organization_id = aa.organization_id
             AND ab.plan_start_date
                    BETWEEN TRUNC (TO_DATE (:tgl1, 'RRRR/MM/DD HH24:MI:SS'))
                        AND TRUNC (TO_DATE (:tgl2, 'RRRR/MM/DD HH24:MI:SS')))
                                                                    AS closed
    FROM gme_batch_header aa
GROUP BY aa.organization_id