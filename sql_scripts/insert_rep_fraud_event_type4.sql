with ranked_transactions as (
    select
        event_dt,
        card_num,
        amount,
        passport,
        fio,
        phone,
        ROW_NUMBER() OVER (PARTITION BY card_num ORDER BY event_dt) AS rn,
        LAG(amount) OVER (PARTITION BY card_num ORDER BY event_dt) AS prev_amount,
        LAG(event_dt) OVER (PARTITION BY card_num ORDER BY event_dt) AS prev_event_dt
    from
        (select 
             gdft.trans_date as event_dt,
             trim(ggdc.card_num) as card_num,
             gdft.amt as amount,
             gddc2.passport_num as passport,
             gddc2.last_name || ' ' || gddc2.first_name || ' ' || gddc2.patronymic as fio,
             gddc2.phone as phone
         from deaian.grsm_dwh_fact_transactions gdft 
         left join deaian.grsm_dwh_dim_cards ggdc on trim(gdft.card_num) = trim(ggdc.card_num)
         left join deaian.grsm_dwh_dim_accounts gdda on ggdc.account_num = gdda.account_num
         left join deaian.grsm_dwh_dim_clients gddc2 on gdda.client = gddc2.client_id
         left join deaian.grsm_dwh_dim_terminals gddt on gdft.terminal = gddt.terminal_id) as tt)
insert into deaian.grsm_rep_fraud(event_dt, passport, fio, phone, event_type, report_dt)
select
    event_dt,
    passport,
    fio,
    phone,
    '4' as event_type, -- 3 транзакции и amt < предыдущего
    to_date(%s, 'YYYY-MM-DD') as report_dt
FROM
    ranked_transactions
WHERE
    rn >= 4
    AND amount < prev_amount
    AND event_dt - prev_event_dt <= interval '20 minutes'
    and to_date(extract(YEAR from event_dt) ||'-'|| extract(MONTH from event_dt) ||'-'|| extract(DAY from event_dt), 'YYYY-MM-DD') = to_date(%s, 'YYYY-MM-DD')
