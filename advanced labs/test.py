# pip install snowflake-connector-python

import snowflake.connector
from vars import _pwd, _username

_account = 'TYIXBCI-BRB86839'

# with snowflake.connector.connect(user=_username, password=_pwd, account=_account, warehouse="compute_wh") as con:
#     with con.cursor() as cur:
#         try:
#             cur.execute("use demo_db")
#             cur.execute("SELECT * FROM scott.dept")
#             rows = cur.fetchall()
#             for row in rows:
#                 print(row)
#         except Exception as ex:
#             print(ex)

stages = ['~', '%MOVIES', 'MOVIES_STAGE']
file_path = r"C:\Personal\Training\movies.csv"
commands = ["USE ROLE SYSADMIN", "USE DATABASE MOVIES_DB", "USE SCHEMA MOVIES_SCHEMA"]

commands += [f"PUT file://{file_path} @{stage} auto_compress=false" for stage in stages]

with snowflake.connector.connect(user=_username, password=_pwd, account=_account, warehouse="compute_wh") as con:
    with con.cursor() as cur:
        try:
            for sql in commands:
                cur.execute(sql)
                print("Executed: ", sql)

        except Exception as ex:
            print(ex)
