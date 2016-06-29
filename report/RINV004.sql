
       
       
                   and origination_date is not null
                   and rownum = 1
                   select origination_date from mtl_transaction_lot_numbers
                   where lot_number = b.LOT_NUMBER
                  ),TO_DATE(:p_date_input, 'RRRR/MM/DD HH24:MI:SS')
                 )
                 a.primary_quantity
                 b.primary_quantity
             ) "AGING"
           else
           when (b.lot_number is not null) or (b.lot_number <> '') then
       - 
       :p_category "PARAM_CATEGORY",
       a.TRANSACTION_UOM,
       b.lot_number, 
       c.description nama_barang,
       c.segment1
       c.shelf_life_days,
       case 
       end as qty,
       TO_DATE (:p_date_input, 'RRRR/MM/DD HH24:MI:SS') "PARAM_DATE",
       TRUNC (NVL((
       TRUNC (TO_DATE (:p_date_input, 'RRRR/MM/DD HH24:MI:SS'))
       || '-'
       || '-'
       || '-'
       || '-'
       || c.segment2
       || c.segment3
       || c.segment4
       || c.segment5 item_code,
(
(
)pp
)ppp
and    a.INVENTORY_ITEM_ID = c.INVENTORY_ITEM_ID
and    a.organization_id = c.organization_id
and    a.transaction_date < TO_DATE (SUBSTR (:p_date_input, 1, 10) || '23:59:59','RRRR/MM/DD HH24:MI:SS')  
and    c.organization_id = :p_user 
and    c.organization_id = d.organization_id
AND    e.attribute1 = nvl(:p_owning_warehouse,e.attribute1)
AND    e.organization_id = a.organization_id
AND    e.secondary_inventory_name = a.subinventory_code
AND    e.secondary_inventory_name = nvl(:p_subinventory,e.secondary_inventory_name)
from
from   mtl_material_transactions a, mtl_transaction_lot_numbers b, mtl_system_items_b c, hr_all_organization_units d, mtl_secondary_inventories e
group by pp.param_category, pp.param_date, pp.name, pp.item_code, pp.nama_barang, pp.shelf_life_days, pp.aging, pp.transaction_uom
select * from
select d.NAME,
select pp.param_category, pp.param_date, pp.name, pp.item_code, pp.nama_barang, pp.shelf_life_days, pp.aging, sum(qty) as qty, pp.transaction_uom
where  a.TRANSACTION_ID = b.TRANSACTION_ID(+)
where ppp.item_code = 'FGP-CAP-3025SW-DEB-029'