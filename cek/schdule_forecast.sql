Select MDSGN.*, HOU.NAME
from MSC_DESIGNATORS MDSGN, hr_all_organization_units HOU
 
WHERE hou.ORGANIZATION_ID = mdsgn.ORGANIZATION_ID and 
    mdsgn.ORGANIZATION_ID = 162 and
    mdsgn.DESIGNATOR = '0515PETSLO'
