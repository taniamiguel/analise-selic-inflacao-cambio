from pathlib import Path

# Pastas do projeto, calculadas a partir deste arquivo (funciona rodando de qualquer pasta)
RAIZ = Path(__file__).resolve().parent.parent
PASTA_RAW = RAIZ / "data" / "raw"
CAMINHO_BANCO = RAIZ / "data" / "macro.db"

# Código da série no SGS do Banco Central -> nome do CSV e da tabela no banco
SERIES = {
    432: "selic_meta",
    433: "ipca_mensal",
    13522: "ipca_12m",
    3698: "dolar_medio_mensal",
    4391: "cdi_mensal",
    195: "poupanca",
    21340: "imoveis_ivgr",
}
