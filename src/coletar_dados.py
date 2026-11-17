import time
from datetime import date

import pandas as pd
import requests

from config import PASTA_RAW, SERIES

HOJE = date.today().strftime("%d/%m/%Y")
DATA_INICIAL = "01/01/2010"

# A API do BCB limita séries diárias a 10 anos por consulta, por isso a coleta é dividida
PERIODOS = [
    (DATA_INICIAL, "31/12/2019"),
    ("01/01/2020", HOJE),
]

# Séries que começam depois da DATA_INICIAL
INICIO_ESPECIAL = {
    195: "04/05/2012",  # a poupança com a regra nova só existe a partir desta data
}

TENTATIVAS = 3
ESPERA_SEGUNDOS = 5


def buscar_periodo(codigo, data_inicial, data_final):
    """Busca um período da série. Tenta de novo se a API falhar; devolve None se todas falharem."""
    url = f"https://api.bcb.gov.br/dados/serie/bcdata.sgs.{codigo}/dados"
    parametros = {
        "formato": "json",
        "dataInicial": data_inicial,
        "dataFinal": data_final,
    }

    for tentativa in range(1, TENTATIVAS + 1):
        try:
            resposta = requests.get(url, params=parametros, timeout=60)
            resposta.raise_for_status()
            return pd.DataFrame(resposta.json())
        except (requests.RequestException, ValueError) as erro:
            print(f"   Tentativa {tentativa}/{TENTATIVAS} falhou ({data_inicial} a {data_final}): {erro}")
            if tentativa < TENTATIVAS:
                time.sleep(ESPERA_SEGUNDOS * tentativa)

    return None


def buscar_serie(codigo):
    """Junta todos os períodos. Se algum falhar, devolve None para não gravar uma série incompleta."""
    pedacos = []
    for data_inicial, data_final in PERIODOS:
        # No primeiro período, usa a data especial se a série estiver na lista
        if data_inicial == DATA_INICIAL and codigo in INICIO_ESPECIAL:
            data_inicial = INICIO_ESPECIAL[codigo]
        pedaco = buscar_periodo(codigo, data_inicial, data_final)
        if pedaco is None:
            return None
        pedacos.append(pedaco)
    return pd.concat(pedacos, ignore_index=True)


def main():
    for codigo, nome in SERIES.items():
        print(f"Buscando {nome} (série {codigo})...")
        tabela = buscar_serie(codigo)

        # Se a série falhou ou veio vazia, mantém o CSV anterior e segue para a próxima
        if tabela is None or tabela.empty:
            print("   Nenhum dado completo retornado, série ignorada (CSV anterior mantido)")
            continue

        tabela.to_csv(PASTA_RAW / f"{nome}.csv", index=False)
        print(f"   {len(tabela)} registros, de {tabela['data'].iloc[0]} a {tabela['data'].iloc[-1]}")


if __name__ == "__main__":
    main()
