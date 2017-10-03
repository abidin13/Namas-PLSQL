select * from po_headers_all
where po_header_id in (
select po_header_id from rcv_shipment_lines
where shipment_header_id in (
    select shipment_header_id from rcv_shipment_headers
where receipt_num = :receive_num
)
)