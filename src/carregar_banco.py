import sqlite3

import pandas as pd

from config import CAMINHO_BANCO, PASTA_RAW, SERIES

# Colunas de data que vêm da API como DD/MM/AAAA e vão para o banco como AAAA-MM-DD
COLUNAS_DE_DATA = ["data", "dataFim"]


def main():
    conexao = sqlite3.connect(CAMINHO_BANCO)

    for nome in SERIES.values():
        tabela = pd.read_csv(PASTA_RAW / f"{nome}.csv")
        for coluna in COLUNAS_DE_DATA:
            if coluna in tabela.columns:
                datas = pd.to_datetime(tabela[coluna], format="%d/%m/%Y")
                tabela[coluna] = datas.dt.strftime("%Y-%m-%d")
        tabela.to_sql(nome, conexao, if_exists="replace", index=False)
        print(f"{nome}: {len(tabela)} linhas carregadas")

    conexao.close()
    print(f"Banco criado em {CAMINHO_BANCO}")


if __name__ == "__main__":
    main()
