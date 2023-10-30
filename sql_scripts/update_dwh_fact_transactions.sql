UPDATE deaian.grsm_dwh_fact_transactions AS tgt
SET 
  trans_date = stg.trans_date,
  card_num = stg.card_num,
  oper_type = stg.oper_type,
  amt = stg.amt,
  oper_result = stg.oper_result,
  terminal = stg.terminal,
  source_dt = stg.create_dt
FROM deaian.grsm_stg_transactions AS stg
WHERE tgt.trans_id = stg.trans_id;

