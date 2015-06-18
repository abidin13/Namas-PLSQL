--collect data log squence (log start point)
SELECT MAX(log_sequence) log_start_point
FROM fnd_log_messages;


--collect data log squence (log end point)
SELECT MAX(log_sequence) log_end_point
FROM fnd_log_messages;
