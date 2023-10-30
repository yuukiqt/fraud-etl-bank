WITH ranked_transactions AS (
    SELECT
        event_dt,
        card_num,
        terminal_city,
        passport,
        fio,
        phone,
        ROW_NUMBER() OVER (PARTITION BY tt.card_num ORDER BY event_dt) AS rn
    FROM
        (select gdft.trans_date as event_dt,
        		trim(ggdc.card_num) as card_num,
        		gddt.terminal_city as terminal_city,
     			gddc2.passport_num as passport,
     			gddc2.last_name || ' ' || gddc2.first_name || ' ' || gddc2.patronymic as fio,
     			gddc2.phone as phone
        		from deaian.grsm_dwh_fact_transactions gdft 
			left join deaian.grsm_dwh_dim_cards ggdc on trim(gdft.card_num) = trim(ggdc.card_num)
			left join deaian.grsm_dwh_dim_accounts gdda on ggdc.account_num = gdda.account_num
			left join deaian.grsm_dwh_dim_clients gddc2 on gdda.client = gddc2.client_id
			left join deaian.grsm_dwh_dim_terminals gddt on gdft.terminal = gddt.terminal_id) as tt
)
insert into deaian.grsm_rep_fraud(event_dt, passport, fio, phone, event_type, report_dt)
SELECT
    rt1.event_dt,
    rt1.passport,
    rt1.fio,
    rt1.phone,
	'3' as event_type, -- разных городах в течение одного часа.
	to_date(%s, 'YYYY-MM-DD') as report_dt
FROM
    ranked_transactions rt1
    JOIN ranked_transactions rt2
    ON rt1.card_num = rt2.card_num
    AND rt1.rn = rt2.rn - 1
    AND rt1.terminal_city <> rt2.terminal_city
    AND rt2.event_dt - rt1.event_dt <= interval '1 hour'
    and to_date(extract(YEAR from rt1.event_dt) ||'-'|| extract(MONTH from rt1.event_dt) ||'-'|| extract(DAY from rt1.event_dt), 'YYYY-MM-DD') = to_date(%s, 'YYYY-MM-DD')
