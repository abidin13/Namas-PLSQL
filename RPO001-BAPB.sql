/* Formatted on 2016/06/13 07:53 (Formatter Plus v4.8.8) */
SELECT pp.*,
       CASE
          WHEN :nomor_iso = 'Y'
             THEN (SELECT nomor_doc
                     FROM ynp_nomor_doc_iso
                    WHERE organization_id = pp.org_id
                      AND nama_doc = 'BAPB')
          ELSE ''
       END AS nomor_iso,
       (SELECT flag_logo
          FROM ynp_nomor_doc_iso
         WHERE organization_id = pp.org_id AND nama_doc = 'BAPB')
                                                                 AS flag_logo
  FROM (SELECT a.receipt_num AS nomor_bapb,
               a.receipt_num AS nomor_bapb_tampil,
               (SELECT transaction_date
                  FROM rcv_vrc_txs_v
                 WHERE shipment_header_id = a.shipment_header_id
                   AND transaction_type = 'RECEIVE'
                   AND ROWNUM = 1) AS tgl_bapb,
               a.packing_slip AS no_sj, a.waybill_airbill_num AS no_awb_bl,
               (SELECT aa.segment1
                  FROM po_headers_all aa
                 WHERE aa.po_header_id = b.po_header_id) AS nomor_po,
               (SELECT operating_unit
                  FROM org_organization_definitions
                 WHERE organization_id = a.ship_to_org_id) AS org_id,
               (SELECT NAME
                  FROM xle_entity_profiles aa
                 WHERE aa.legal_entity_id =
                          (SELECT default_legal_context_id
                             FROM hr_operating_units bb
                            WHERE bb.organization_id =
                                     (SELECT operating_unit
                                        FROM org_organization_definitions
                                       WHERE organization_id =
                                                              a.ship_to_org_id)))
                                                                AS name_legal,
               (SELECT    dd.address_line_1
                       || ' '
                       || dd.address_line_2
                       || ' '
                       || dd.address_line_3
                  FROM hr_all_organization_units cc, hr_locations_all dd
                 WHERE cc.location_id = dd.location_id
                   AND cc.organization_id =
                                   (SELECT operating_unit
                                      FROM org_organization_definitions
                                     WHERE organization_id = a.ship_to_org_id))
                                                                 AS alamat_ou,
               (SELECT dd.town_or_city
                  FROM hr_all_organization_units cc,
                       hr_locations_all dd
                 WHERE cc.location_id = dd.location_id
                   AND cc.organization_id =
                                   (SELECT operating_unit
                                      FROM org_organization_definitions
                                     WHERE organization_id = a.ship_to_org_id))
                                                                   AS city_ou,
               (SELECT dd.telephone_number_1
                  FROM hr_all_organization_units cc,
                       hr_locations_all dd
                 WHERE cc.location_id = dd.location_id
                   AND cc.organization_id =
                                   (SELECT operating_unit
                                      FROM org_organization_definitions
                                     WHERE organization_id = a.ship_to_org_id))
                                                                   AS telp_ou,
               (SELECT vendor_name
                  FROM ap_suppliers bb
                 WHERE bb.vendor_id = a.vendor_id) AS sup_nama,
               (SELECT aa.vendor_site_code
                  FROM ap_supplier_sites_all aa
                 WHERE aa.vendor_site_id = a.vendor_site_id
                   AND aa.vendor_id = a.vendor_id
                   AND aa.org_id = (SELECT operating_unit
                                      FROM org_organization_definitions
                                     WHERE organization_id = a.ship_to_org_id))
                                                                  AS sup_site,
               (SELECT    first_name
                       || ' '
                       || middle_names
                       || ' '
                       || last_name
                  FROM per_all_people_f
                 WHERE person_id = a.employee_id
                   AND (   (    TRUNC (a.creation_date)
                                   BETWEEN per_all_people_f.effective_start_date
                                       AND per_all_people_f.effective_end_date
                            AND (   per_all_people_f.employee_number IS NOT NULL
                                 OR (    per_all_people_f.employee_number IS NULL
                                     AND per_all_people_f.npw_number IS NOT NULL
                                    )
                                )
                           )
                        OR per_all_people_f.person_id IS NULL
                       )) AS dibuat,
               b.line_num AS nomor, b.item_description,
               cari_no_pr (b.po_line_location_id) AS no_pr,
               b.quantity_received,
               (SELECT uom_code
                  FROM mtl_units_of_measure
                 WHERE unit_of_measure = b.unit_of_measure) AS uom,
               (SELECT note_to_receiver
                  FROM po_line_locations_all
                 WHERE line_location_id = b.po_line_location_id) AS ket,
               (SELECT attribute1
                  FROM rcv_transactions
                 WHERE shipment_line_id = b.shipment_line_id
                   AND transaction_type = 'RECEIVE') AS no_plat_kend
          FROM rcv_shipment_headers a, rcv_shipment_lines b
         WHERE a.shipment_header_id = b.shipment_header_id
           AND a.receipt_num BETWEEN :receipt_num1 AND :receipt_num2) pp
 WHERE org_id = :p_context