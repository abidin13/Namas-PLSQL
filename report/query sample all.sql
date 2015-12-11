select
c.PADDED_CONCATENATED_SEGMENTS as item_code,
a.SAMPLE_DESC,
a.SAMPLE_NO,
c.DESCRIPTION,
b.BATCH_NO,
a.LOT_NUMBER,
e.TEST_CODE,
--e.TEST_DESC,
d.ATTRIBUTE1 as sample1,
d.ATTRIBUTE2 as sample2,
d.ATTRIBUTE3 as sample3,
d.ATTRIBUTE4 as sample4,
d.ATTRIBUTE5 as sample5,
d.ATTRIBUTE6 as sample6,
d.ATTRIBUTE7 as sample7,
d.ATTRIBUTE8 as sample8,
d.ATTRIBUTE9 as sample9,
d.ATTRIBUTE10 as sample10,
d.ATTRIBUTE11 as sample11,
d.ATTRIBUTE12 as sample12,
d.ATTRIBUTE13 as sample13,
d.ATTRIBUTE14 as sample14,
d.ATTRIBUTE15 as sample15
from gmd_samples a,
gme_batch_header b,
mtl_system_items_kfv c,
gmd_results d,
APPS.GMD_QC_TESTS_VL e
where 
a.organization_id = 231
and a.BATCH_ID = b.BATCH_ID
and a.INVENTORY_ITEM_ID = c.INVENTORY_ITEM_ID
and a.ORGANIZATION_ID = c.ORGANIZATION_ID
and a.SAMPLE_ID = d.SAMPLE_ID
and e.TEST_ID = d.TEST_ID


GMD_SPECIFICATIONS_VL

mtl_parameters