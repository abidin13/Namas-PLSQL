SELECT *
FROM rcv_shipment_headers rsh
, rcv_shipment_lines rsl
, rcv_transactions rct
, po_headers_all poh
, po_lines_all pol
WHERE 1=1
AND poh.po_header_id = pol.po_header_id
AND poh.po_header_id = rsl.po_header_id
AND rsl.shipment_header_id = rsh.shipment_header_id
AND rct.po_header_id = poh.po_header_id
AND rct.po_line_id = pol.po_line_id
AND rct.shipment_header_id = rsh.shipment_header_id
AND rct.shipment_line_id = rsl.shipment_line_id
AND poh.po_header_id='108188' 