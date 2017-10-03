select * from rcv_transactions rct
where transaction_type in ('RETURN TO VENDOR','RETURN TO RECEIVING')
and po_header_id in (
    select po_header_id from po_headers_all
    where segment1 = :NOPO
)