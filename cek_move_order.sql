 select * from mtl_txn_request_headers mtrh
where request_number ='&request_number'

select * from mtl_txn_request_lines mtrl
where mtrl.header_id in ( select mtrh.header_id from mtl_txn_request_headers mtrh
where request_number ='&request_number') 


select mmtt.* from mtl_material_transactions_temp mmtt,mtl_txn_request_lines mtrl
where mmtt.move_order_line_id = mtrl.line_id
and mmtt.inventory_item_id = mtrl.inventory_item_id
and mmtt.organization_id = mtrl.organization_id
and mtrl.header_id in ( select mtrh.header_id from mtl_txn_request_headers mtrh
where request_number ='&request_number') --data null

select mmt.* from mtl_material_transactions mmt,mtl_txn_request_lines mtrl
where mmt.move_order_line_id = mtrl.line_id
and mmt.inventory_item_id = mtrl.inventory_item_id
and mmt.organization_id = mtrl.organization_id
and mtrl.header_id in ( select mtrh.header_id from mtl_txn_request_headers mtrh
where request_number ='&request_number') --no data
