INSERT INTO deaian.grsm_dwh_dim_terminals (terminal_id, terminal_type, terminal_city, terminal_address, create_dt, update_dt)
SELECT
  stg.terminal_id,
  stg.terminal_type, 
  stg.terminal_city,  
  stg.terminal_address,
  stg.create_dt,
  CASE
    WHEN stg.terminal_id IS NOT NULL THEN to_date('2099-01-01', 'YYYY-MM-DD')
    ELSE NULL
  END
FROM deaian.grsm_stg_terminals stg
LEFT JOIN deaian.grsm_dwh_dim_terminals tgt ON stg.terminal_id = tgt.terminal_id
WHERE tgt.terminal_id IS NULL;
