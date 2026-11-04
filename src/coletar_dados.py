from datetime import date

import pandas as pd
import requests

HOJE = date.today().strftime("%d/%m/%Y")

PERIODOS = [
    ("01/01/2010", "31/12/2019"),
    ("01/01/2020", HOJE),
]


def buscar_periodo(codigo, data_inicial, data_final):
    url = f"https://api.bcb.gov.br/dados/serie/bcdata.sgs.{codigo}/dados"
    parametros = {
        "formato": "json",
        "dataInicial": data_inicial,
        "dataFinal": data_final,
    }
    resposta = requests.get(url, params=parametros)
    return pd.DataFrame(resposta.json())


def buscar_serie(codigo):
    pedacos = []
    for data_inicial, data_final in PERIODOS:
        pedaco = buscar_periodo(codigo, data_inicial, data_final)
        pedacos.append(pedaco)
    return pd.concat(pedacos, ignore_index=True)


series = {
    432: "selic_meta",
    433: "ipca_mensal",
    13522: "ipca_12m",
    3698: "dolar_medio_mensal",
}

for codigo, nome in series.items():
    print(f"Buscando {nome} (série {codigo})...")
    tabela = buscar_serie(codigo)
    tabela.to_csv(f"data/raw/{nome}.csv", index=False)
    print(f"   {len(tabela)} registros, de {tabela['data'].iloc[0]} a {tabela['data'].iloc[-1]}")