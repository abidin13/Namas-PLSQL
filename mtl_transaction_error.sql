select transaction_source_type_id,request_id, costed_flag, transaction_id,
transaction_group_id, inventory_item_id, transaction_source_id
from mtl_material_transactions
where costed_flag in ('N', 'E')
--and transaction_source_type_id=5
and organization_id = 278


select * from MTL_TRANSACTION_TYPES
where transaction_type_id = 5