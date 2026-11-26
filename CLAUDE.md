# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Visão geral

Projeto de análise de dados (Python + SQL + Power BI) com séries macroeconômicas do Banco Central do Brasil: Selic, IPCA, dólar, CDI, poupança e preços de imóveis. O painel do Power BI fica em `powerbi/` e lê os CSVs de `data/processed/`. Código, comentários, nomes de variáveis e mensagens de commit são escritos em português.

## Comandos

Os caminhos são resolvidos a partir de `src/config.py`, então os scripts podem ser executados de qualquer pasta.

```bash
pip install -r requirements.txt     # pandas e requests (ambiente virtual em .venv/)
python src/coletar_dados.py         # baixa as séries da API do BCB -> data/raw/*.csv
python src/carregar_banco.py        # carrega os CSVs no SQLite -> data/macro.db
python src/exportar_powerbi.py      # roda sql/06, 07 e 08 -> data/processed/*.csv (separador ';', decimal ',')
```

O `sqlite3` de linha de comando não está instalado nesta máquina. Para rodar SQL, use Python (`sqlite3.connect("data/macro.db")`, que tem SQLite 3.50, com funções matemáticas e window functions) ou um cliente gráfico. A pasta `exploracao/` guarda rascunhos que não fazem parte do pipeline. Não há testes automatizados nem linter configurados.

## Pipeline de dados

1. **Configuração (`src/config.py`)** — fonte única do dicionário `SERIES` (código SGS → nome) e dos caminhos (`PASTA_RAW`, `CAMINHO_BANCO`). O nome da série vira o nome do CSV e da tabela no banco. Para adicionar uma série, basta incluí-la aqui (e em `INICIO_ESPECIAL`, se começar depois de 2010).
2. **Coleta (`src/coletar_dados.py`)** — consulta a API SGS do BCB (`api.bcb.gov.br/dados/serie/bcdata.sgs.{codigo}/dados`).
   - A API limita consultas de séries diárias a ~10 anos, por isso a coleta é dividida em `PERIODOS` (2010–2019 e 2020–hoje) e os pedaços são concatenados.
   - `INICIO_ESPECIAL` sobrescreve a data inicial de séries que começam depois de 2010 (ex.: poupança, código 195, só a partir de 04/05/2012).
   - Cada período tem até `TENTATIVAS` tentativas. Se algum período falhar de vez, a série inteira é pulada e o CSV anterior é mantido, para nunca gravar uma série incompleta.
3. **Carga (`src/carregar_banco.py`)** — cada CSV vira uma tabela (`if_exists="replace"`). As colunas listadas em `COLUNAS_DE_DATA` (`data`, `dataFim`) são convertidas de `DD/MM/AAAA` para `AAAA-MM-DD` (ISO), o que permite usar `strftime('%Y', data)` e comparar datas como texto no SQLite.
4. **Análise (`sql/`)** — consultas numeradas e independentes, escritas em SQLite. Os resultados encontrados ficam registrados como comentários acima de cada consulta e as principais conclusões estão resumidas no `README.md`. Ao mudar uma consulta, confira os números no banco antes de atualizar esses comentários.
5. **Exportação (`src/exportar_powerbi.py`)** — o dicionário `EXPORTACOES` liga cada arquivo SQL a um CSV em `data/processed/`. Os CSVs usam `sep=";"`, `decimal=","` e `utf-8-sig`, para o Power BI em português ler os números e acentos corretamente.

## Formato das tabelas

- Colunas padrão: `data` (texto ISO) e `valor` (numérico no banco, pois o `pd.read_csv` faz a conversão).
- `selic_meta` e `poupanca` são **diárias** (`selic_meta` inclui todos os dias do calendário). As demais são **mensais**, datadas no dia 1º do mês, então nelas `COUNT(*)` conta meses. Joins entre a Selic e séries mensais são feitos por `s.data = i.data`, pegando a Selic do dia 1º.
- `poupanca` tem uma coluna extra, `dataFim` (fim do período de rendimento).
- `cdi_mensal` pode ter o mês corrente incompleto. Acumulados de 12 meses são calculados com `EXP(SUM(LN(1 + valor/100)))` em window function, filtrando janelas com 12 meses (ver `sql/04_juro_real.sql`).
- Juro real usa a fórmula de Fisher: `((1 + juro/100) / (1 + ipca_12m/100) - 1) * 100`.

## Arquivos versionados

`data/*.db` está no `.gitignore` (o banco é regenerado pela carga), mas os CSVs de `data/raw/` são versionados.
