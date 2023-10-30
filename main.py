#global libs
import psycopg2 as pg2
import pandas as pd
import os
from datetime import datetime, timedelta

#paths
path = '/home/deaian/grsm/project'
ddl_path = f'{path}/main.ddl'
files = os.listdir(f'{path}/source')
query = None


#get dates from files for loading
terminals_src = [filename for filename in files if filename.startswith('terminals')]
terminals_src.sort()
transactions_src = [filename for filename in files if filename.startswith('transactions')]
transactions_src.sort()
passport_blacklist_src = [filename for filename in files if filename.startswith('passport_blacklist')]
passport_blacklist_src.sort()
dates = [filename[10:18] for filename in files if filename.startswith("terminals_")]
dates.sort()
for _ in range(len(dates)):
    dates[_] = dates[_][4:] + '-' + dates[_][2:4] + '-' + dates[_][:2]
try:
	date_frmt = datetime.strptime(dates[0], '%Y-%m-%d')
	report_dt_frmt = date_frmt + timedelta(days=1)
	report_dt = report_dt_frmt.strftime('%Y-%m-%d')
except:
	print('There are no more files')
	exit()

#connect to databases
conn_edu = pg2.connect(database = "db_name",
                        host = "db_host",
                        user = "db_user",
                        password = "db_pass",
                        port = "5432")
conn_edu.autocommit = False
cursor_edu = conn_edu.cursor()

conn_bank = pg2.connect(database = "db_name",
                        host = "db_host",
                        user = "db_user",
                        password = "db_pass",
                        port = "5432")
conn_bank.autocommit = False
cursor_bank = conn_bank.cursor()


#create tables or truncate stg
with conn_edu.cursor() as cursor:
    try:
        with open(ddl_path, 'r') as file:
            ddl_commands = file.read()
        cursor.execute(ddl_commands)
        conn_edu.commit()
        print(f"Tables created.")
    except:	
       conn_edu.rollback()
       stg_tables = ['grsm_stg_transactions',
                  'grsm_stg_terminals',
                  'grsm_stg_blacklist',
                  'grsm_stg_cards',
                  'grsm_stg_accounts',
                  'grsm_stg_clients']
       for table in stg_tables:
           cursor_edu.execute(f'TRUNCATE {table}')
       conn_edu.commit()
       print(f"Stage tables truncated.")


#stage transactions
transactions = pd.read_csv(f'{path}/source/{transactions_src[0]}', 
                                                   sep=';', 
                                                   encoding='utf-8')
transactions.transaction_id = transactions.transaction_id.astype(str)
transactions.amount = transactions.amount.str.replace(',', '.')
transactions['source_dt'] = dates[0]

query = open(f"{path}/sql_scripts/insert_stg_transactions.sql", "r").read()
cursor_edu.executemany(query, transactions.values.tolist())
conn_edu.commit()


#stage terminals
terminals = pd.read_excel(f'{path}/source/{terminals_src[0]}')
terminals['source_dt'] = dates[0]

query = open(f"{path}/sql_scripts/insert_stg_terminals.sql", "r").read()
cursor_edu.executemany(query, terminals.values.tolist())
conn_edu.commit()


#stage passport_blacklist
passport_blacklist = pd.read_excel(f'{path}/source/{passport_blacklist_src[0]}')
passport_blacklist['source_dt'] = dates[0]
passport_blacklist = passport_blacklist[passport_blacklist.date == dates[0]]	

query = open(f"{path}/sql_scripts/insert_stg_passport_blacklist.sql", "r").read()
cursor_edu.executemany(query, passport_blacklist.values.tolist())
conn_edu.commit()


#load stage accounts
cursor_bank.execute('SELECT * FROM info.accounts')
records = cursor_bank.fetchall()
col_names = [x[0] for x in cursor_bank.description]
bank_accounts = pd.DataFrame(records, columns = col_names)

query = open(f"{path}/sql_scripts/insert_stg_accounts.sql", "r").read()
cursor_edu.executemany(query, bank_accounts.values.tolist())
conn_edu.commit()


#load stage clients
cursor_bank.execute('SELECT * FROM info.clients')
records = cursor_bank.fetchall()
col_names = [x[0] for x in cursor_bank.description]
bank_clients = pd.DataFrame(records, columns = col_names)

query = open(f"{path}/sql_scripts/insert_stg_clients.sql", "r").read()
cursor_edu.executemany(query, bank_clients.values.tolist())
conn_edu.commit()


#load stage cards
cursor_bank.execute('SELECT * FROM info.cards')
records = cursor_bank.fetchall()
col_names = [x[0] for x in cursor_bank.description]
bank_cards = pd.DataFrame(records, columns = col_names)

query = open(f"{path}/sql_scripts/insert_stg_cards.sql", "r").read()
cursor_edu.executemany(query, bank_cards.values.tolist())
conn_edu.commit()


#insert DWH terminals
query = open(f"{path}/sql_scripts/insert_dwh_dim_terminals.sql", "r").read()
cursor_edu.execute(query)
conn_edu.commit()
query = open(f"{path}/sql_scripts/update_dwh_dim_terminals.sql", "r").read()
cursor_edu.execute(query, (dates[0], dates[0]))
conn_edu.commit()


#insert DWH cards
query = open(f"{path}/sql_scripts/insert_dwh_dim_cards.sql", "r").read()
cursor_edu.execute(query)
conn_edu.commit()


#insert DWH accounts
query = open(f"{path}/sql_scripts/insert_dwh_dim_accounts.sql", "r").read()
cursor_edu.execute(query)
conn_edu.commit()


#insert DWH clients
query = open(f"{path}/sql_scripts/insert_dwh_dim_clients.sql", "r").read()
cursor_edu.execute(query)
conn_edu.commit()


#load DWH passport_blacklist
query = open(f"{path}/sql_scripts/insert_dwh_fact_passport_blacklist.sql", "r").read()
cursor_edu.execute(query)
conn_edu.commit()


# fact transaction
query = open(f"{path}/sql_scripts/insert_dwh_fact_transactions.sql", "r").read()
cursor_edu.execute(query)
conn_edu.commit()
query = open(f"{path}/sql_scripts/update_dwh_fact_transactions.sql", "r").read()
cursor_edu.execute(query)
conn_edu.commit()


#find event_type = 1 -> expired or blocked passport
query = open(f"{path}/sql_scripts/insert_rep_fraud_event_type1.sql", "r").read()
cursor_edu.execute(query, [report_dt, dates[0], dates[0]])
conn_edu.commit()


#find event_type = 2 -> invalid contract
query = open(f"{path}/sql_scripts/insert_rep_fraud_event_type2.sql", "r").read()
cursor_edu.execute(query, [report_dt, dates[0], dates[0]])
conn_edu.commit()

#find event_type = 3 -> transactions in different cities within an hour
query = open(f"{path}/sql_scripts/insert_rep_fraud_event_type3.sql", "r").read()
cursor_edu.execute(query, (report_dt, dates[0]))
conn_edu.commit()

#find event_type = 4 -> 3 transactions within 20 minutes and each amount is less than the previous one
query = open(f"{path}/sql_scripts/insert_rep_fraud_event_type4.sql", "r").read()
cursor_edu.execute(query, (report_dt, dates[0]))
conn_edu.commit()

#close connection to databases
conn_edu.close()
conn_bank.close()

print(f'Files with {dates[0]} loaded')
print(f'Fraud report created {report_dt}')
#archive loaded files
try:
    os.rename(f'{path}/source/{terminals_src[0]}', f'{path}/archive/{terminals_src[0]}.backup')
    os.rename(f'{path}/source/{transactions_src[0]}', f'{path}/archive/{transactions_src[0]}.backup')
    os.rename(f'{path}/source/{passport_blacklist_src[0]}', f'{path}/archive/{passport_blacklist_src[0]}.backup')
except IndexError:
    print("There are no more files")
