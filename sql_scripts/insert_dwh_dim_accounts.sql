insert into deaian.grsm_dwh_dim_accounts (account_num, valid_to, client, create_dt, update_dt)
    select
        stg.account_num, 
        stg.valid_to, 
        stg.client, 
        stg.create_dt,
        null
    from deaian.grsm_stg_accounts stg
    left join deaian.grsm_dwh_dim_accounts tgt on stg.account_num = tgt.account_num
    where tgt.account_num is null
