from datetime import date

import pandas as pd
import requests

HOJE = date.today().strftime("%d/%m/%Y")
DATA_INICIAL = "01/01/2010"  # NOVO

PERIODOS = [
    (DATA_INICIAL, "31/12/2019"),  # NOVO: usa a constante no lugar da data escrita
    ("01/01/2020", HOJE),
]

# NOVO: séries que começam depois da DATA_INICIAL
INICIO_ESPECIAL = {
    195: "04/05/2012",  # a poupança com a regra nova só existe a partir desta data
}


def buscar_periodo(codigo, data_inicial, data_final):
    url = f"https://api.bcb.gov.br/dados/serie/bcdata.sgs.{codigo}/dados"
    parametros = {
        "formato": "json",
        "dataInicial": data_inicial,
        "dataFinal": data_final,
    }
    resposta = requests.get(url, params=parametros, timeout=60)

    # Se a resposta não for um JSON válido, mostra o motivo e segue em frente
    try:
        return pd.DataFrame(resposta.json())
    except ValueError:
        print(f"   Falha no período {data_inicial} a {data_final} (status {resposta.status_code})")
        print(f"   Resposta da API: {resposta.text[:200]}")
        return pd.DataFrame()


def buscar_serie(codigo):
    pedacos = []
    for data_inicial, data_final in PERIODOS:
        # NOVO: no primeiro período, usa a data especial se a série estiver na lista
        if data_inicial == DATA_INICIAL and codigo in INICIO_ESPECIAL:
            data_inicial = INICIO_ESPECIAL[codigo]
        pedaco = buscar_periodo(codigo, data_inicial, data_final)
        pedacos.append(pedaco)
    return pd.concat(pedacos, ignore_index=True)


series = {
    432: "selic_meta",
    433: "ipca_mensal",
    13522: "ipca_12m",
    3698: "dolar_medio_mensal",
    4391: "cdi_mensal",
    195: "poupanca",
    21340: "imoveis_ivgr",
}

for codigo, nome in series.items():
    print(f"Buscando {nome} (série {codigo})...")
    tabela = buscar_serie(codigo)

    # Se a série veio vazia, avisa e pula para a próxima
    if tabela.empty:
        print("   Nenhum dado retornado, série ignorada")
        continue

    tabela.to_csv(f"data/raw/{nome}.csv", index=False)
    print(f"   {len(tabela)} registros, de {tabela['data'].iloc[0]} a {tabela['data'].iloc[-1]}")