insert into deaian.grsm_rep_fraud(event_dt, passport, fio, phone, event_type, report_dt)
    select 
        gdft.trans_date as event_dt,
        gddc2.passport_num as passport,
        gddc2.last_name || ' ' || gddc2.first_name || ' ' || gddc2.patronymic as fio,
        gddc2.phone as phone,
        '2' as event_type, -- недействительный договор
        to_date(%s, 'YYYY-MM-DD') as report_dt
    from deaian.grsm_dwh_fact_transactions gdft 
    left join deaian.grsm_dwh_dim_cards ggdc on trim(gdft.card_num) = trim(ggdc.card_num)
    left join deaian.grsm_dwh_dim_accounts gdda on ggdc.account_num = gdda.account_num
    left join deaian.grsm_dwh_dim_clients gddc2 on gdda.client = gddc2.client_id
    where gdda.valid_to < to_date(%s, 'YYYY-MM-DD')
         and to_date(extract(YEAR from gdft.trans_date) ||'-'|| extract(MONTH from gdft.trans_date) ||'-'|| extract(DAY from gdft.trans_date), 'YYYY-MM-DD') = to_date(%s, 'YYYY-MM-DD')
