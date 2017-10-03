SELECT mutasi.party_id id, vendor_name, mutasi.currency_code, mutasi.concatenated_segments,
 (
    select CCC.BEGINING_BALANCE_FC 
    from YNP_SALDO_AWAL_ACCOUNT ccc
    WHERE ccc.CONCATENATED_SEGMENTS = mutasi.concatenated_segments
    AND CCC.JENIS = 'Purchasing'
    AND CCC.PARTY_ID = mutasi.party_id
    AND CCC.PERIOD = :p_period
    AND CCC.CURRENCY_CODE = mutasi.currency_code
  )    begining_balance_fc,
  (
    select CCC.BEGINING_BALANCE_EC 
    from YNP_SALDO_AWAL_ACCOUNT ccc
    WHERE ccc.CONCATENATED_SEGMENTS = mutasi.concatenated_segments
    AND CCC.JENIS = 'Purchasing'
    AND CCC.PARTY_ID = mutasi.party_id
    AND CCC.PERIOD = :p_period
    AND CCC.CURRENCY_CODE = mutasi.currency_code
  ) begining_balance_ec,
       NVL(ynpgl_mutasi_accounted (mutasi.concatenated_segments,
                               'Purchase Invoices',
                               mutasi.party_id,
                               :p_period,
                               mutasi.currency_code
                              ),0) purchase_invoice_fc,
       NVL(ynpgl_mutasi_entered (mutasi.concatenated_segments,
                             'Purchase Invoices',
                             mutasi.party_id,
                             :p_period,
                             mutasi.currency_code
                            ),0) purchase_invoice_ec,
       NVL(ynpgl_mutasi_accounted (mutasi.concatenated_segments,
                               'Payments',
                               mutasi.party_id,
                               :p_period,
                               mutasi.currency_code
                              ),0) payments_fc,
       NVL(ynpgl_mutasi_entered (mutasi.concatenated_segments,
                             'Payments',
                             mutasi.party_id,
                             :p_period,
                             mutasi.currency_code
                            ),0) payments_ec,
       0 sales_invoices_fc, 0 sales_invoices_ec, 0 credit_memos_fc,
       0 credit_memos_ec, 0 debit_memos_fc, 0 debit_memos_ec,
       0 adjustment_fc, 0 adjustment_ec, 0 receipts_fc,
       0 receipts_ec, 0 misc_receipts_fc, 0 misc_receipts_ec,
       0 others_fc,0 others_ec,
       NVL(ynpgl_mutasi_accounted (mutasi.concatenated_segments,
                               'Receiving',
                               mutasi.party_id,
                               :p_period,
                               mutasi.currency_code
                              ),0) receiving_fc,
       NVL(ynpgl_mutasi_entered (mutasi.concatenated_segments,
                             'Receiving',
                             mutasi.party_id,
                             :p_period,
                             mutasi.currency_code
                            ),0) receiving_ec
  FROM ap_suppliers aps,
       (SELECT   h.currency_code, h.je_category, sla.party_id,
                 lines.period_name, gcc.concatenated_segments,
                 SUM (NVL (sla.entered_dr, 0) - NVL (sla.entered_cr, 0)) ec,
                 SUM (NVL (sla.accounted_dr, 0)
                      - NVL (sla.accounted_cr, 0)) fc
            FROM gl_je_lines lines,
                 gl_je_headers h,
                 gl_je_batches b,
                 gl_code_combinations_kfv gcc,
                 gl_import_references gir,
                 (SELECT xal.gl_sl_link_table, xal.gl_sl_link_id,
                         xal.accounting_date gl_date, xal.ae_line_num,
                         gcc1.concatenated_segments ACCOUNT,
                         xal.accounting_class_code, xal.currency_code,
                         xal.entered_dr, xal.entered_cr, xal.accounted_dr,
                         accounted_cr, xah.description, xal.party_id
                    FROM xla_ae_headers xah,
                         xla_ae_lines xal,
                         xla_events xe,
                         gl_code_combinations_kfv gcc1
                   WHERE xah.ae_header_id = xal.ae_header_id
                     AND xah.application_id = xal.application_id
                     AND xah.event_id = xe.event_id
                     AND xah.application_id = xe.application_id
                     AND xal.code_combination_id = gcc1.code_combination_id) sla
           WHERE b.je_batch_id = h.je_batch_id
             AND h.je_header_id = lines.je_header_id
             AND gcc.code_combination_id = lines.code_combination_id
             AND gcc.segment5 = :p_natural_account
             AND gcc.segment2 between :p_from_plant and :p_to_plant
             AND gir.gl_sl_link_id = sla.gl_sl_link_id
             AND h.je_category IN
                    ('Purchase Invoices', 'Payments','Receiving')
             --AND lines.period_name = :p_period
             AND to_date('01-'||lines.period_name,'DD-MON-YY') <= to_date('01-'||:p_period,'DD-MON-YY')
             AND gir.gl_sl_link_table = sla.gl_sl_link_table
             AND gir.je_batch_id = b.je_batch_id
             AND gir.je_header_id = h.je_header_id
             AND gir.je_line_num = lines.je_line_num
          ---HAVING SUM (NVL (sla.entered_dr, 0) - NVL (sla.entered_cr, 0)) <> 0
        GROUP BY h.currency_code,
                 h.je_category,
                 lines.period_name,
                 gcc.concatenated_segments,
                 sla.party_id) mutasi
 WHERE aps.vendor_id = mutasi.party_id