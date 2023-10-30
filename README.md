# Overview
This Python project automates the ETL process for banking data. 

It includes scripts for extracting data from source files, transforming and loading it into staging and dimensional tables in a PostgreSQL database and performing fraud detection analysis.

This project implements a star schema for DWH:

  Facts:
  
    deaian.grsm_dwh_fact_transactions
    
    deaian.grsm_dwh_fact_passport_blacklist
    
  Dims:
  
    deaian.grsm_dwh_dim_terminals
    
    deaian.grsm_dwh_dim_cards
    
    deaian.grsm_dwh_dim_accounts
    
    deaian.grsm_dwh_dim_clients
    
  Store:
  
    deaian.grsm_rep_fraud
    

# Project Structure:
* source: contains source files for transactions, terminals, and passport blacklists.
* sql_scripts: contains SQL scripts for creating tables, inserting data, and detecting fraud events.
* archive: archived source files are stored here.
* main.ddl: DDL script for creating database tables.
* main.cron: crontab process runs at 0:22 every day

# Usage:
1. Clone the repository to your local machine.
2. Install required python libraries: pip install psycopg2 pandas.
3. Set up your PostgreSQL database and update the connection details in the Python script.
4. Run the python script(main.py) to automate the data loading and fraud detection process.


# Fraud Detection Criteria:
Event Type 1: expired or blocked passports.

Event Type 2: invalid contracts.

Event Type 3: transactions in different cities within an hour. (get only last transaction)

Event Type 4: three transactions within 20 minutes, each with a decreasing amount. (get only last transaction)
