select poh.segment1 po#, pol.line_num l#,
poll.shipment_num s#, rh.segment1 req#, rl.line_num rl#
from po_headers_all poh, po_lines_all pol, po_line_locations_all poll,
po_requisition_headers_all rh, po_requisition_lines_all rl
where rh.requisition_header_id = rl.requisition_header_id
and rl.line_location_id = poll.line_location_id
and poh.po_header_id = pol.po_header_id
and pol.po_line_id = poll.po_line_id
and poh.segment1 = '&po_number';