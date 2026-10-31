import requests
import pandas as pd


def buscar_serie(codigo):
    url = f"https://api.bcb.gov.br/dados/serie/bcdata.sgs.{codigo}/dados"
    parametros = {
        "formato": "json",
        "dataInicial": "01/01/2010",
        "dataFinal": "31/10/2026",
    }
    resposta = requests.get(url, params=parametros)
    tabela = pd.DataFrame(resposta.json())
    return tabela


series = {
    433: "ipca_mensal",
    13522: "ipca_12m",
    3698: "dolar_medio_mensal",
}

for codigo, nome in series.items():
    print(f"Buscando {nome} (série {codigo})...")
    tabela = buscar_serie(codigo)
    tabela.to_csv(f"data/raw/{nome}.csv", index=False)
    print(f"   {len(tabela)} registros salvos em {nome}.csv")