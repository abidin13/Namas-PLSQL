select r.segment1 "Req Num",  
       p.segment1 "PO Num"  
from po_headers_all p,   
po_distributions_all d,  
po_req_distributions_all rd,   
po_requisition_lines_all rl,  
po_requisition_headers_all r   
where p.po_header_id = d.po_header_id   
and d.req_distribution_id = rd.distribution_id   
and rd.requisition_line_id = rl.requisition_line_id   
and rl.requisition_header_id = r.requisition_header_id  
AND P.SEGMENT1 ='16101300541' 