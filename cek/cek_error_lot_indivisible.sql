-- table item--
# mtl_onhand_quantities_detail
# mtl_system_items_B
# mtl_onhand_quantities_detail

SELECT moqd.*,
moqd1.subinventory_code,
moqd1.locator_id
FROM Mtl_Onhand_Quantities_Detail Moqd,
Mtl_System_Items_B Msi,
Mtl_Onhand_Quantities_Detail Moqd1
WHERE Moqd.Organization_Id = Msi.Organization_Id
AND Moqd.Inventory_Item_Id = Msi.Inventory_Item_Id
AND Msi.Lot_Divisible_Flag='N'
AND moqd1.Inventory_Item_Id=Msi.Inventory_Item_Id
AND Moqd1.Lot_Number=Moqd.Lot_Number
AND Moqd.Organization_Id=Moqd1.Organization_Id
AND (moqd1.subinventory_code <>moqd.subinventory_code
OR (Moqd1.Subinventory_Code =Moqd.Subinventory_Code
AND nvl(Moqd1.Locator_Id,-1)<>nvl(Moqd.Locator_Id,-1)))
ORDER BY moqd.lot_number; 