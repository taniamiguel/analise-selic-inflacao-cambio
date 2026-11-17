import sqlite3

import pandas as pd

from config import CAMINHO_BANCO, PASTA_PROCESSED, PASTA_SQL

# Arquivo SQL -> nome do CSV que o Power BI vai ler
EXPORTACOES = {
    "07_indicadores_mensais.sql": "indicadores_mensais.csv",
    "06_ranking_investimentos.sql": "ranking_investimentos.csv",
}


def main():
    PASTA_PROCESSED.mkdir(parents=True, exist_ok=True)
    conexao = sqlite3.connect(CAMINHO_BANCO)

    for arquivo_sql, arquivo_csv in EXPORTACOES.items():
        consulta = (PASTA_SQL / arquivo_sql).read_text(encoding="utf-8")
        tabela = pd.read_sql(consulta, conexao)
        tabela.to_csv(PASTA_PROCESSED / arquivo_csv, index=False,
                      sep=";", decimal=",", encoding="utf-8-sig")
        print(f"{arquivo_csv}: {len(tabela)} linhas")

    conexao.close()


if __name__ == "__main__":
    main()