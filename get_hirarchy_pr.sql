select distinct a.object_id, a.approval_path_id,b.position_structure_id,c.segment1, b.name from po_action_history a,
per_position_structures_v b,po_requisition_headers_all c
where b.position_structure_id =a.approval_path_id
and a.object_id = c.REQUISITION_HEADER_ID
and c.segment1 = '16102000524'