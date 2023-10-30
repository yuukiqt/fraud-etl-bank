insert into deaian.grsm_dwh_fact_passport_blacklist(entry_dt, passport, source_dt)
    select 
        entry_dt, 
        passport, 
        create_dt
    from deaian.grsm_stg_blacklist
