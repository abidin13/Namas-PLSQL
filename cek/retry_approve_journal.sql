//script data fix ketika pembuatan journal
//approval tidak ada di worklist yang akan approve

update gl_je_batches
set approval_status_code = 'R'
where je_batch_id = 672259