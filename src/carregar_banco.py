import sqlite3

import pandas as pd

SERIES = ["selic_meta", "ipca_mensal", "ipca_12m", "dolar_medio_mensal"]

conexao = sqlite3.connect("data/macro.db")

for nome in SERIES:
    tabela = pd.read_csv(f"data/raw/{nome}.csv")
    datas = pd.to_datetime(tabela["data"], format="%d/%m/%Y")
    tabela["data"] = datas.dt.strftime("%Y-%m-%d")
    tabela.to_sql(nome, conexao, if_exists="replace", index=False)
    print(f"{nome}: {len(tabela)} linhas carregadas")

conexao.close()
print("Banco criado em data/macro.db")