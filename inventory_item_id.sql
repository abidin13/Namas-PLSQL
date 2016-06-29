select * from 
(
SELECT 
segment1||'-'||
segment2||'-'||
segment3||'-'||
segment4||'-'||
segment5 as kode_item,
inventory_item_id
from mtl_system_items
)pp
where pp.kode_item ='FGP-PRE-29SN21-NMK-001'