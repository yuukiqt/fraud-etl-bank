INSERT INTO deaian.grsm_dwh_fact_transactions(trans_id, trans_date, card_num, oper_type, amt, oper_result, terminal, source_dt)
SELECT 
  stg.trans_id, 
  stg.trans_date, 
  stg.card_num, 
  stg.oper_type,
  stg.amt,
  stg.oper_result,
  stg.terminal, 
  stg.create_dt 
FROM deaian.grsm_stg_transactions stg
LEFT JOIN deaian.grsm_dwh_fact_transactions tgt 
ON stg.trans_id = tgt.trans_id
WHERE tgt.trans_id IS NULL;
