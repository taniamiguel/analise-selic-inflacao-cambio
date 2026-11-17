import requests

url = "https://api.bcb.gov.br/dados/serie/bcdata.sgs.433/dados/ultimos/12?formato=json"

resposta = requests.get(url)
print(resposta.status_code)

dados = resposta.json()
print(dados)

import pandas as pd

tabela = pd.DataFrame(dados)
print(tabela)   

print(tabela.dtypes)

print(tabela["valor"].sum())

tabela["valor"] = pd.to_numeric(tabela["valor"])
tabela["data"] = pd.to_datetime(tabela["data"], format="%d/%m/%Y")

print(tabela.dtypes)
print(tabela["valor"].sum())

print("Média mensal:", round(tabela["valor"].mean(), 2))
print("Maior inflação:", tabela["valor"].max())
print("Menor inflação:", tabela["valor"].min())

acumulado = ((1 + tabela["valor"] / 100).prod() - 1) * 100
print("IPCA acumulado 12 meses:", round(acumulado, 2))


