insert into deaian.grsm_dwh_dim_cards (card_num, account_num, create_dt, update_dt)
    select
        stg.card_num, 
        stg.account_num, 
        stg.create_dt, 
        null
    from deaian.grsm_stg_cards stg
    left join deaian.grsm_dwh_dim_cards tgt on stg.card_num = tgt.card_num
    where tgt.card_num is null
