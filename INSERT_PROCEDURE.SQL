CREATE OR REPLACE PROCEDURE APPS.YNPMFG_CHANGE_PRODUCT_ACTUAL(p_bulan in varchar2,
                                                              p_product in varchar2,
                                                              p_io in varchar2)
AS
CURSOR c1 IS
SELECT pppp.concatenated_segments, pppp.tgl_aja, pppp.routing_no_1, substr(pppp.concatenated_segments, 5,3) product, pppp.actual_cmplt_date, pppp.batch_no
FROM 
(
    select ppp.*, TO_CHAR(ppp.actual_cmplt_date, 'RRRR-MM-DD') TGL_AJA
    from 
    (
    select pp.*, substr(routing_no, 1,2) as routing_no_1 from
    (
    SELECT  distinct             
                                     gbh.batch_no
                                    , msik.concatenated_segments
                                    --, mmt.transaction_date
                                    , gbh.actual_cmplt_date
                                    , rtg.routing_no
                                    , rtg.attribute3
                        FROM gme_batch_header gbh
                                    , mtl_material_transactions mmt
                                    , gmd_recipes gr
                                    , gmd_recipe_validity_rules gvr
                                    , gme_material_details gmd
                                    , mtl_system_items_kfv msik
                                    , GME_BATCH_STEP_RESOURCES GBSR
                                    , CR_RSRC_MST_VL CRMV
                                    , fm_rout_hdr rtg
                                WHERE 1=1
                                    --and gbh.batch_no = 1401024053
                                    AND gbh.batch_id = mmt.transaction_source_id
                                    AND gbh.organization_id = mmt.organization_id        
                                    AND gbh.recipe_validity_rule_id = gvr.recipe_validity_rule_id
                                    --AND gbh.organization_id = gvr.organization_id
                                    AND gr.recipe_id = gvr.recipe_id          
                                    AND gr.recipe_no NOT LIKE '%RP'
                                    AND gr.recipe_no NOT LIKE '%RW'
                                    AND gr.recipe_no NOT LIKE '%RT'
                                    AND gr.recipe_no NOT LIKE '%RTR-%'
                                    AND gr.recipe_no NOT LIKE '%TLO-%'
                                    --AND gr.recipe_no NOT LIKE '%TRIAL%'
                                    AND gr.recipe_status IN (700,400)
                                    AND gbh.organization_id= gmd.organization_id
                                    AND GBH.BATCH_ID = GMD.BATCH_ID
                                    AND gmd.line_type = 1
                                    AND gmd.line_no = 1
                                    AND gmd.inventory_item_id = msik.inventory_item_id
                                    --AND mmt.inventory_item_id = msik.inventory_item_id
                                    AND gmd.organization_id = msik.organization_id
                                    AND GBH.BATCH_ID = GBSR.BATCH_ID
                                    AND GBSR.RESOURCES = CRMV.RESOURCES
                                    AND CRMV.RESOURCE_DESC not like '%PUNCH%'
                                    AND CRMV.RESOURCE_DESC not like '%CVT%'
                                    AND CRMV.RESOURCE_DESC not like '%MLD%'
                                    AND GBSR.RESOURCES not like '%PUNCH%'
                                    AND GBSR.RESOURCES not like '%CVT%'
                                    AND GBSR.RESOURCES not like '%MLD%'
                                    AND rtg.routing_id = gbh.routing_id
                                    -- PARAMETERS --
                                    AND gbh.actual_cmplt_date BETWEEN TO_DATE ('01-' || p_bulan || ' 00:00:00',
                                                                                           'DD-MON-YYYY HH24:MI:SS'
                                                                                          )
                                                                              AND LAST_DAY (TO_DATE (   '01-'
                                                                                                     || p_bulan || ' 23:59:59',
                                                                                                     'DD-MON-YYYY HH24:MI:SS'
                                                                                                    )
                                                                                           )
                                    AND (gr.recipe_no LIKE 'FGP-'||p_product||'-%' OR gr.recipe_no LIKE 'WIP-'||p_product||'-%') 
                                    AND mmt.organization_id = p_io
                                    AND (msik.concatenated_segments LIKE 'FGP-'||p_product||'-%' OR msik.concatenated_segments LIKE 'WIP-'||p_product||'-%')
                                    ------------------------------                                                     
                                    AND mmt.transaction_type_id = 44
                                    AND gbh.batch_status IN (3,4)
    )pp
    order by pp.batch_no asc
    )ppp
    --where ppp.routing_no_1 = 'BB'
    --group by concatenated_segments--, TO_CHAR(ppp.actual_cmplt_date, 'RRRR-MM-DD')
    order by ppp.routing_no_1, ppp.actual_cmplt_date
) pppp;


v_id  number;
 v_urut number;
 v_temp varchar2(300);
 v_routing varchar2(300);
begin
  v_id:=0;
  v_urut := 0;
  v_temp := '';
   v_routing := '123'; 
  DELETE YNPMFG_TCHANGE_PRODUCT_ACTUAL WHERE org_id = p_io AND product = p_product AND tanggal BETWEEN TO_DATE ('01-' || p_bulan || ' 00:00:00',
                                                                                           'DD-MON-YYYY HH24:MI:SS'
                                                                                          )
                                                                              AND LAST_DAY (TO_DATE (   '01-'
                                                                                                     || p_bulan || ' 23:59:59',
                                                                                                     'DD-MON-YYYY HH24:MI:SS'
                                                                                                    )
                                                                                           );
  for r1 in c1
  loop
    begin      
        if v_temp = r1.CONCATENATED_SEGMENTS then
            if v_routing <> r1.routing_no_1 then
                 v_urut:= 0;         
            end if; 
        else 
            if v_routing = r1.routing_no_1 then
                 v_urut:=v_urut+1;    
            else  
                v_urut:= 0;
            end if;       
        end if;        
        
        v_id:=v_id+1;
        
        insert into YNPMFG_TCHANGE_PRODUCT_ACTUAL (coba_id, CONCATENATED_SEGMENTS, urut, product,  routing_no, org_id, tanggal, batch_no)
                        values(
                                v_id,
                                r1.CONCATENATED_SEGMENTS,
                                v_urut,
                                r1.product,
                                r1.routing_no_1,
                                p_io,
                                r1.actual_cmplt_date,
                                r1.batch_no
                                );
             
         v_routing := r1.routing_no_1;
        v_temp := r1.CONCATENATED_SEGMENTS;
     end;
    commit;
  end loop;
end;
/