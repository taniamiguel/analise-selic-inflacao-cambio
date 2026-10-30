import requests

url = "https://api.bcb.gov.br/dados/serie/bcdata.sgs.433/dados/ultimos/12?formato=json"

resposta = requests.get(url)
print(resposta.status_code)

dados = resposta.json()
print(dados)

import pandas as pd

tabela = pd.DataFrame(dados)
print(tabela)