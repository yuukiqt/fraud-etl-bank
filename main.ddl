----- STG
create table deaian.grsm_stg_transactions(
	trans_id varchar(50),
	trans_date timestamp,
	card_num varchar(50),
	oper_type varchar(50),
	amt decimal(18,2),
	oper_result varchar(50),
	terminal varchar(50),
	create_dt date,
	update_dt date);
	
create table deaian.grsm_stg_terminals(
	terminal_id varchar(50),
	terminal_type varchar(50),
	terminal_city varchar(50),
	terminal_address varchar(50),
	create_dt date,
	update_dt date);

create table deaian.grsm_stg_blacklist(
	entry_dt date,
	passport varchar(50),
	create_dt date,
	update_dt date);
	
create table deaian.grsm_stg_cards(
	card_num varchar(50),
	account_num varchar(50),
	create_dt date,
	update_dt date);
	
create table deaian.grsm_stg_accounts(
	account_num varchar(50),
	valid_to date,
	client varchar(50),
	create_dt date,
	update_dt date);
	
create table deaian.grsm_stg_clients(
	client_id varchar(50),
	last_name varchar(50),
	first_name varchar(50),
	patronymic varchar(50),
	date_of_birth date,
	passport_num varchar(50),
	passport_valid_to date,
	phone varchar(50),
	create_dt date,
	update_dt date);
	
----- DWH
create table deaian.grsm_dwh_fact_transactions(
	trans_id varchar(50) primary key,
	trans_date timestamp,
	card_num varchar(50),
	oper_type varchar(50),
	amt decimal(18,2),
	oper_result varchar(50),
	terminal varchar(50),
	source_dt date);
	
create table deaian.grsm_dwh_fact_passport_blacklist(
	entry_dt date,
	passport varchar(50),
	source_dt date);
	
create table deaian.grsm_dwh_dim_terminals(
	terminal_id varchar(50) primary key,
	terminal_type varchar(50),
	terminal_city varchar(50),
	terminal_address varchar(50),
	create_dt date,
	update_dt date);
	
create table deaian.grsm_dwh_dim_cards(
	card_num varchar(50),
	account_num varchar(50),
	create_dt date,
	update_dt date);
	
create table deaian.grsm_dwh_dim_accounts(
	account_num varchar(50) unique,
	valid_to date,
	client varchar(50),
	create_dt date,
	update_dt date);
	
create table deaian.grsm_dwh_dim_clients(
	client_id varchar(50) unique,
	last_name varchar(50),
	first_name varchar(50),
	patronymic varchar(50),
	date_of_birth date,
	passport_num varchar(50),
	passport_valid_to date,
	phone varchar(50),
	create_dt date,
	update_dt date);
	
create table deaian.grsm_rep_fraud(
	event_dt timestamp,
	passport varchar(50),
	fio varchar(50),
	phone varchar(50),
	event_type int,
	report_dt date);
