"""
Gera o dashboard interativo em HTML (docs/index.html) a partir dos CSVs de data/processed.

O HTML é montado a partir de src/dashboard_template.html: o script lê as três tabelas
que alimentam o Power BI e coloca os dados dentro do modelo, no lugar de __DADOS__.
A pasta docs/ é a que o GitHub Pages publica.

Como rodar (depois do exportar_powerbi.py):
    python src/gerar_dashboard.py
"""
import json

import pandas as pd

from config import PASTA_PROCESSED, RAIZ

MODELO = RAIZ / "src" / "dashboard_template.html"
SAIDA = RAIZ / "docs" / "index.html"

# Nome da tabela no dashboard -> CSV de data/processed
TABELAS = {
    "indicadores": "indicadores_mensais.csv",
    "ranking": "ranking_investimentos.csv",
    "evolucao": "evolucao_100_reais.csv",
}


def ler_csv(nome_arquivo):
    """Lê um CSV no padrão brasileiro (; e vírgula decimal) e devolve uma lista de linhas."""
    tabela = pd.read_csv(PASTA_PROCESSED / nome_arquivo, sep=";", decimal=",", encoding="utf-8-sig")
    # Valores vazios viram None, que no JSON vira null (o JavaScript entende como "sem dado")
    tabela = tabela.astype(object).where(tabela.notna(), None)
    return tabela.to_dict(orient="records")


def main():
    dados = {chave: ler_csv(arquivo) for chave, arquivo in TABELAS.items()}

    # ensure_ascii=False mantém os acentos; trocar "</" evita fechar a tag <script> sem querer
    dados_json = json.dumps(dados, ensure_ascii=False).replace("</", "<\\/")

    html = MODELO.read_text(encoding="utf-8").replace("__DADOS__", dados_json)
    SAIDA.parent.mkdir(parents=True, exist_ok=True)
    SAIDA.write_text(html, encoding="utf-8")

    for chave, linhas in dados.items():
        print(f"{chave}: {len(linhas)} linhas")
    print(f"Dashboard gerado em {SAIDA}")


if __name__ == "__main__":
    main()
