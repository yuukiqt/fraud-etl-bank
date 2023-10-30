insert into deaian.grsm_dwh_dim_clients (client_id, last_name, first_name, patronymic, date_of_birth, passport_num,
                                                                                  passport_valid_to, phone, create_dt, update_dt)
    select
        stg.client_id, 
        stg.last_name, 
        stg.first_name, 
        stg.patronymic,
        stg.date_of_birth,
        stg.passport_num,
        stg.passport_valid_to,
        stg.phone,
        stg.create_dt,
        null
    from deaian.grsm_stg_clients  stg
    left join deaian.grsm_dwh_dim_clients tgt on stg.client_id = tgt.client_id
    where tgt.client_id is null
