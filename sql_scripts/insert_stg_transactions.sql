INSERT INTO deaian.grsm_stg_transactions(
    trans_id,
    trans_date,
    amt,
    card_num,
    oper_type,
    oper_result,
    terminal,
    create_dt)
VALUES(%s, %s, %s, %s, %s, %s, %s, %s)
