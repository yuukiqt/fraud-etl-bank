UPDATE deaian.grsm_dwh_dim_terminals AS tgt
SET 
  terminal_type = stg.terminal_type,
  terminal_city = stg.terminal_city,
  terminal_address = stg.terminal_address,
  update_dt = %s
FROM deaian.grsm_stg_terminals AS stg
WHERE tgt.terminal_id = stg.terminal_id and tgt.create_dt <> %s

