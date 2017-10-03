select * from po_headers_all
where creation_date BETWEEN trunc(to_date(:bulnpo1||'-01','MM/RRRR/DD HH24:MI:SS'))
and last_day(trunc(to_date(:bulnpo2||'-01','MM/RRRR/DD HH24:MI:SS')))
and po_header_id in (
                select po_header_id from rcv_transactions rct
                WHERE creation_date between trunc(to_date(:bulnrcv1||'-01','MM/RRRR/DD HH24:MI:SS'))
                and last_day(trunc(to_date(:bulnrcv2||'-01','MM/RRRR/DD HH24:MI:SS')))
               )
order by segment1 asc



-- contoh po = 16111400003