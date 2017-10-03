/* Program : re_invoice_line1.sql
   Use this program to re-invoice interface a single line
   Note: Please set the correct org context before
   running the script  This is for Release 12

   For Internal Use Only  */
   
set serveroutput on size 100000;
DECLARE
v_line_id        NUMBER   := &line_id;
v_org_id         number;
l_file_val       VARCHAR2(600);
l_result_out     varchar2(30);
l_return_status  varchar2(30);
err_msg          VARCHAR2(240);
BEGIN
select org_id into v_org_id from oe_order_lines_all where line_id = v_line_id;
--dbms_output.put_line('Pass Organization_id as : ' || v_org_id);
--fnd_client_info.set_org_context('&organization_id');
 mo_global.set_policy_context(p_access_mode => 'S',p_org_id  =>  v_org_id);

oe_debug_pub.debug_on;
oe_debug_pub.initialize;
l_file_val := OE_DEBUG_PUB.Set_Debug_Mode('FILE');
oe_Debug_pub.setdebuglevel(5);
dbms_output.put_line('Passed value of line_id = '||v_line_id);
UPDATE OE_ORDER_LINES_ALL
SET    INVOICED_QUANTITY = NULL,
       INVOICE_INTERFACE_STATUS_CODE = NULL,
       OPEN_FLAG='Y',
       LAST_UPDATED_BY = -2118580,
       LAST_UPDATE_DATE = SYSDATE
WHERE  LINE_ID = v_line_id;

DELETE FROM RA_INTERFACE_LINES_ALL
WHERE  INTERFACE_LINE_ATTRIBUTE6=to_char(v_line_id);

DELETE FROM RA_INTERFACE_SALESCREDITS_ALL
WHERE  INTERFACE_LINE_ATTRIBUTE6=to_char(v_line_id);
dbms_output.put_line('Before Calling Interface Line API' );

OE_INVOICE_PUB.Interface_Line(v_line_id,'OEOL',l_result_out,l_return_status);
dbms_output.put_line('After Calling Interface Line API' );


UPDATE OE_ORDER_LINES_ALL
SET    OPEN_FLAG='N', FLOW_STATUS_CODE = 'CLOSED'
WHERE  LINE_ID = v_line_id;
dbms_output.put_line('After updating the status of line');

dbms_output.put_line('File name '||OE_DEBUG_PUB.G_DIR||'/'||OE_DEBUG_PUB.G_FILE);

EXCEPTION
    WHEN OTHERS THEN
         dbms_output.put_line('Inside Exception handling');

         err_msg := 'Error in Interface line procedure \n '||SQLERRM;
         dbms_output.put_line('Error ' ||err_msg);

         OE_DEBUG_PUB.ADD(err_msg);
end;
/
commit;
set serveroutput off;

