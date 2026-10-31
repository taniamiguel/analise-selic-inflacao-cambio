import requests
import pandas as pd

codigo = 433
url = f"https://api.bcb.gov.br/dados/serie/bcdata.sgs.{codigo}/dados"

parametros = {
    "formato": "json",
    "dataInicial": "01/01/2010",
    "dataFinal": "31/10/2026",
}

resposta = requests.get(url, params=parametros)
print("Status:", resposta.status_code)

tabela = pd.DataFrame(resposta.json())
print(tabela.head())
print("Total de registros:", len(tabela))

tabela.to_csv("data/raw/ipca_mensal.csv", index=False)
print("Arquivo salvo!")