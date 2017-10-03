SELECT GLMUT.CONCATENATED_SEGMENTS ACCOUNT 
,:P_PERIOD PERIOD
,GLMUT.ID
,GLMUT.VENDOR_NAME
,GLMUT.CURRENCY_CODE
,GLMUT.begining_balance_fc
,GLMUT.begining_balance_ec
,glmut.purchase_invoice_fc
,glmut.purchase_invoice_ec
,glmut.payments_fc
,glmut.payments_ec
,glmut.sales_invoices_fc
,glmut.sales_invoices_ec
,glmut.credit_memos_fc
,glmut.credit_memos_ec
,glmut.debit_memos_fc 
,glmut.debit_memos_ec
,glmut.adjustment_fc
,glmut.adjustment_ec
,glmut.receipts_fc
,glmut.receipts_ec
,glmut.misc_receipts_fc
,glmut.misc_receipts_ec
,glmut.others_fc
,glmut.others_ec
,glmut.receiving_fc
,glmut.receiving_ec
FROM
(SELECT mutasi.party_id id, vendor_name, mutasi.currency_code, mutasi.concatenated_segments,
         NVL
            (ynpgl_mutasi_accounted1
                                (mutasi.concatenated_segments,
                                 'Purchase Invoices',
                                 mutasi.party_id,
                                 TO_CHAR (ADD_MONTHS (TO_DATE (   '01-'
                                                               || :p_period,
                                                               'DD-MON-YYYY'
                                                              ),
                                                      -1
                                                     ),
                                          'MON-YY'
                                         ),
                                mutasi.currency_code
                                ),
             0
            )
       + NVL
            (ynpgl_mutasi_accounted1
                                (mutasi.concatenated_segments,
                                 'Payments',
                                 mutasi.party_id,
                                 TO_CHAR (ADD_MONTHS (TO_DATE (   '01-'
                                                               || :p_period,
                                                               'DD-MON-YYYY'
                                                              ),
                                                      -1
                                                     ),
                                          'MON-YY'
                                         ),
                                mutasi.currency_code
                                ),
             0
            )
        + NVL
            (ynpgl_mutasi_accounted1
                                (mutasi.concatenated_segments,
                                 'Receiving',
                                 mutasi.party_id,
                                 TO_CHAR (ADD_MONTHS (TO_DATE (   '01-'
                                                               || :p_period,
                                                               'DD-MON-YYYY'
                                                              ),
                                                      -1
                                                     ),
                                          'MON-YY'
                                         ),
                                  mutasi.currency_code
                                 ),
             0
            ) begining_balance_fc,
         NVL
            (ynpgl_mutasi_entered1
                                (mutasi.concatenated_segments,
                                 'Payments',
                                 mutasi.party_id,
                                 TO_CHAR (ADD_MONTHS (TO_DATE (   '01-'
                                                               || :p_period,
                                                               'DD-MON-YYYY'
                                                              ),
                                                      -1
                                                     ),
                                          'MON-YY'
                                         ),
                                         mutasi.currency_code
                                ),
             0
            )
       + NVL
            (ynpgl_mutasi_entered1
                                (mutasi.concatenated_segments,
                                 'Purchase Invoices',
                                 mutasi.party_id,
                                 TO_CHAR (ADD_MONTHS (TO_DATE (   '01-'
                                                               || :p_period,
                                                               'DD-MON-YYYY'
                                                              ),
                                                      -1
                                                     ),
                                          'MON-YY'
                                         ),
                                         mutasi.currency_code
                                ),
             0
            )
          + NVL
            (ynpgl_mutasi_entered1
                                (mutasi.concatenated_segments,
                                 'Receiving',
                                 mutasi.party_id,
                                 TO_CHAR (ADD_MONTHS (TO_DATE (   '01-'
                                                               || :p_period,
                                                               'DD-MON-YYYY'
                                                              ),
                                                      -1
                                                     ),
                                          'MON-YY'
                                         ),
                                         mutasi.currency_code
                                ),
             0
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
UNION
SELECT mutasi.party_id id, hca.ACCOUNT_NAME vendor_name, mutasi.currency_code, mutasi.concatenated_segments,
       NVL
            (ynpgl_mutasi_accounted1
                                (mutasi.concatenated_segments,
                                 'Sales Invoices',
                                 mutasi.party_id,
                                 TO_CHAR (ADD_MONTHS (TO_DATE (   '01-'
                                                               || :p_period,
                                                               'DD-MON-YYYY'
                                                              ),
                                                      -1
                                                     ),
                                          'MON-YY'
                                         ),
                                   mutasi.currency_code
                                ),
             0
            )
       + NVL
            (ynpgl_mutasi_accounted1
                                (mutasi.concatenated_segments,
                                 'Credit Memos',
                                 mutasi.party_id,
                                 TO_CHAR (ADD_MONTHS (TO_DATE (   '01-'
                                                               || :p_period,
                                                               'DD-MON-YYYY'
                                                              ),
                                                      -1
                                                     ),
                                          'MON-YY'
                                         ),
                                         mutasi.currency_code
                                ),
             0
            )
       + NVL
            (ynpgl_mutasi_accounted1
                                (mutasi.concatenated_segments,
                                 'Debit Memos',
                                 mutasi.party_id,
                                 TO_CHAR (ADD_MONTHS (TO_DATE (   '01-'
                                                               || :p_period,
                                                               'DD-MON-YYYY'
                                                              ),
                                                      -1
                                                     ),
                                          'MON-YY'
                                         ),
                                         mutasi.currency_code
                                ),
             0
            )
       + NVL
            (ynpgl_mutasi_accounted1
                                (mutasi.concatenated_segments,
                                 'Adjustment',
                                 mutasi.party_id,
                                 TO_CHAR (ADD_MONTHS (TO_DATE (   '01-'
                                                               || :p_period,
                                                               'DD-MON-YYYY'
                                                              ),
                                                      -1
                                                     ),
                                          'MON-YY'
                                         ),
                                         mutasi.currency_code
                                ),
             0
            )
       + NVL
            (ynpgl_mutasi_accounted1
                                (mutasi.concatenated_segments,
                                 'Receipts',
                                 mutasi.party_id,
                                 TO_CHAR (ADD_MONTHS (TO_DATE (   '01-'
                                                               || :p_period,
                                                               'DD-MON-YYYY'
                                                              ),
                                                      -1
                                                     ),
                                          'MON-YY'
                                         ),
                                         mutasi.currency_code
                                ),
             0
            ) begining_balance_fc,
         NVL
            (ynpgl_mutasi_entered1
                                (mutasi.concatenated_segments,
                                 'Sales Invoices',
                                 mutasi.party_id,
                                 TO_CHAR (ADD_MONTHS (TO_DATE (   '01-'
                                                               || :p_period,
                                                               'DD-MON-YYYY'
                                                              ),
                                                      -1
                                                     ),
                                          'MON-YY'
                                         ),
                                         mutasi.currency_code
                                ),
             0
            )
       + NVL
            (ynpgl_mutasi_entered1
                                (mutasi.concatenated_segments,
                                 'Credit Memos',
                                 mutasi.party_id,
                                 TO_CHAR (ADD_MONTHS (TO_DATE (   '01-'
                                                               || :p_period,
                                                               'DD-MON-YYYY'
                                                              ),
                                                      -1
                                                     ),
                                          'MON-YY'
                                         ),
                                         mutasi.currency_code
                                ),
             0
            )
       + NVL
            (ynpgl_mutasi_entered1
                                (mutasi.concatenated_segments,
                                 'Debit Memos',
                                 mutasi.party_id,
                                 TO_CHAR (ADD_MONTHS (TO_DATE (   '01-'
                                                               || :p_period,
                                                               'DD-MON-YYYY'
                                                              ),
                                                      -1
                                                     ),
                                          'MON-YY'
                                         ),
                                         mutasi.currency_code
                                ),
             0
            )
       + NVL
            (ynpgl_mutasi_entered1
                                (mutasi.concatenated_segments,
                                 'Adjustment',
                                 mutasi.party_id,
                                 TO_CHAR (ADD_MONTHS (TO_DATE (   '01-'
                                                               || :p_period,
                                                               'DD-MON-YYYY'
                                                              ),
                                                      -1
                                                     ),
                                          'MON-YY'
                                         ),
                                         mutasi.currency_code
                                ),
             0
            )
       + NVL
            (ynpgl_mutasi_entered1
                                (mutasi.concatenated_segments,
                                 'Receipts',
                                 mutasi.party_id,
                                 TO_CHAR (ADD_MONTHS (TO_DATE (   '01-'
                                                               || :p_period,
                                                               'DD-MON-YYYY'
                                                              ),
                                                      -1
                                                     ),
                                          'MON-YY'
                                         ),
                                         mutasi.currency_code
                                ),
             0
            ) begining_balance_ec,
       0 purchase_invoice_fc,
       0 purchase_invoice_ec,
       0 payments_fc,
       0 payments_ec,
       NVL(ynpgl_mutasi_accounted (mutasi.concatenated_segments,
                               'Sales Invoices',
                               mutasi.party_id,
                               :p_period,
                               mutasi.currency_code
                              ),0) sales_invoices_fc,
       NVL(ynpgl_mutasi_entered (mutasi.concatenated_segments,
                             'Sales Invoices',
                             mutasi.party_id,
                             :p_period,
                             mutasi.currency_code
                            ),0) sales_invoices_ec,
       NVL(ynpgl_mutasi_accounted (mutasi.concatenated_segments,
                               'Credit Memos',
                               mutasi.party_id,
                               :p_period,
                               mutasi.currency_code
                              ),0) credit_memos_fc,
       NVL(ynpgl_mutasi_entered (mutasi.concatenated_segments,
                             'Credit Memos',
                             mutasi.party_id,
                             :p_period,
                             mutasi.currency_code
                            ),0) credit_memos_ec,
       NVL(ynpgl_mutasi_accounted (mutasi.concatenated_segments,
                               'Debit Memos',
                               mutasi.party_id,
                               :p_period,
                               mutasi.currency_code
                              ),0) debit_memos_fc,
       NVL(ynpgl_mutasi_entered (mutasi.concatenated_segments,
                             'Debit Memos',
                             mutasi.party_id,
                             :p_period,
                             mutasi.currency_code
                            ),0) debit_memos_ec,
       NVL(ynpgl_mutasi_accounted (mutasi.concatenated_segments,
                               'Adjustment',
                               mutasi.party_id,
                               :p_period,
                               mutasi.currency_code
                              ),0) adjustment_fc,
       NVL(ynpgl_mutasi_entered (mutasi.concatenated_segments,
                             'Adjustment',
                             mutasi.party_id,
                             :p_period,
                             mutasi.currency_code
                            ),0) adjustment_ec,
       NVL(ynpgl_mutasi_accounted (mutasi.concatenated_segments,
                               'Receipts',
                               mutasi.party_id,
                               :p_period,
                               mutasi.currency_code
                              ),0) receipts_fc,
       NVL(ynpgl_mutasi_entered (mutasi.concatenated_segments,
                             'Receipts',
                             mutasi.party_id,
                             :p_period,
                             mutasi.currency_code
                            ),0) receipts_ec,
       0 misc_receipts_fc, 0 misc_receipts_ec,
       0 others_fc,0 others_ec,
       0 receiving_fc, 0 receiving_ec
  FROM hz_parties hp,
       hz_cust_accounts hca,
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
                    ('Sales Invoices','Credit Memos', 'Debit Memos', 'Adjustment', 'Receipts')
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
 WHERE hp.party_id = hca.party_id AND mutasi.party_id = hca.cust_account_id
UNION
SELECT NULL id, NULL vendor_name, mutasi.currency_code, mutasi.concatenated_segments,
       NVL
          (ynpgl_mutasi_acct_no_party1
                                (mutasi.concatenated_segments,
                                 mutasi.je_category,
                                 mutasi.currency_code,
                                 TO_CHAR (ADD_MONTHS (TO_DATE (   '01-'
                                                               || :p_period,
                                                               'DD-MON-YYYY'
                                                              ),
                                                      -1
                                                     ),
                                          'MON-YY'
                                         )
                                ),
           0
          ) begining_balance_fc,
       NVL
          (ynpgl_mutasi_entr_no_party1
                                (mutasi.concatenated_segments,
                                 mutasi.je_category,
                                 mutasi.currency_code,
                                 TO_CHAR (ADD_MONTHS (TO_DATE (   '01-'
                                                               || :p_period,
                                                               'DD-MON-YYYY'
                                                              ),
                                                      -1
                                                     ),
                                          'MON-YY'
                                         )
                                ),
           0
          ) begining_balance_ec,0 purchase_invoice_fc,
       0 purchase_invoice_ec, 0 payments_fc, 0 payments_ec,
       0 sales_invoices_fc, 0 sales_invoices_ec, 0 credit_memos_fc,
       0 credit_memos_ec, 0 debit_memos_fc, 0 debit_memos_ec,
       0 adjustment_fc, 0 adjustment_ec, 0 receipts_fc, 0 receipts_ec,
       NVL(ynpgl_mutasi_acct_no_party (mutasi.concatenated_segments,
                                   mutasi.je_category,
                                   mutasi.currency_code,
                                   :p_period
                                  ),0) misc_receipts_fc,
       NVL(ynpgl_mutasi_entr_no_party (mutasi.concatenated_segments,
                                   mutasi.je_category,
                                   mutasi.currency_code,
                                   :p_period
                                  ),0) misc_receipts_ec,
       0 others_fc,0 others_ec,
       0 receiving_fc,0 receiving_ec
  FROM (SELECT   h.currency_code, h.je_category, sla.party_id,
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
             AND h.je_category IN ('Misc Receipts') 
             --AND lines.period_name = :p_period
             AND to_date('01-'||lines.period_name,'DD-MON-YY') <= to_date('01-'||:p_period,'DD-MON-YY')
             AND gir.gl_sl_link_table = sla.gl_sl_link_table
             AND gir.je_batch_id = b.je_batch_id
             AND gir.je_header_id = h.je_header_id
             AND gir.je_line_num = lines.je_line_num
          HAVING SUM (NVL (sla.entered_dr, 0) - NVL (sla.entered_cr, 0)) <> 0
        GROUP BY h.currency_code,
                 h.je_category,
                 lines.period_name,
                 gcc.concatenated_segments,
                 sla.party_id) mutasi
UNION
SELECT NULL id, NULL vendor_name, mutasi.currency_code, mutasi.concatenated_segments,
       NVL
          (ynpgl_mutasi_acct_no_party1
                                (mutasi.concatenated_segments,
                                 mutasi.je_category,
                                 mutasi.currency_code,
                                 TO_CHAR (ADD_MONTHS (TO_DATE (   '01-'
                                                               || :p_period,
                                                               'DD-MON-YYYY'
                                                              ),
                                                      -1
                                                     ),
                                          'MON-YY'
                                         )
                                ),
           0
          ) begining_balance_fc,
       NVL
          (ynpgl_mutasi_entr_no_party1
                                (mutasi.concatenated_segments,
                                 mutasi.je_category,
                                 mutasi.currency_code,
                                 TO_CHAR (ADD_MONTHS (TO_DATE (   '01-'
                                                               || :p_period,
                                                               'DD-MON-YYYY'
                                                              ),
                                                      -1
                                                     ),
                                          'MON-YY'
                                         )
                                ),
           0
          ) begining_balance_ec,0 purchase_invoice_fc,
       0 purchase_invoice_ec, 0 payments_fc, 0 payments_ec,
       0 sales_invoices_fc, 0 sales_invoices_ec, 0 credit_memos_fc,
       0 credit_memos_ec, 0 debit_memos_fc, 0 debit_memos_ec,
       0 adjustment_fc, 0 adjustment_ec, 0 receipts_fc,0 receipts_ec,
       0 misc_receipts_fc,
       0 misc_receipts_ec,
       NVL(ynpgl_mutasi_acct_no_party (mutasi.concatenated_segments,
                                   mutasi.je_category,
                                   mutasi.currency_code,
                                   :p_period
                                  ),0) others_fc,
       NVL(ynpgl_mutasi_entr_no_party (mutasi.concatenated_segments,
                                   mutasi.je_category,
                                   mutasi.currency_code,
                                   :p_period
                                  ),0) others_ec,
       0 receiving_fc,0 receiving_ec
  FROM (SELECT   h.currency_code, h.je_category, sla.party_id,
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
             AND h.je_category not in ('Sales Invoices','Credit Memos', 'Debit Memos', 'Adjustment', 'Receipts','Purchase Invoices', 'Payments','Receiving','Misc Receipts')
             --AND lines.period_name = :p_period
             AND to_date('01-'||lines.period_name,'DD-MON-YY') <= to_date('01-'||:p_period,'DD-MON-YY')
             AND gir.gl_sl_link_table = sla.gl_sl_link_table
             AND gir.je_batch_id = b.je_batch_id
             AND gir.je_header_id = h.je_header_id
             AND gir.je_line_num = lines.je_line_num
          HAVING SUM (NVL (sla.entered_dr, 0) - NVL (sla.entered_cr, 0)) <> 0
        GROUP BY h.currency_code,
                 h.je_category,
                 lines.period_name,
                 gcc.concatenated_segments,
                 sla.party_id) mutasi
)GLMUT
order by GLMUT.VENDOR_NAME