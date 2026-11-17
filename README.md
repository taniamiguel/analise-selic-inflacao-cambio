# Análise de Selic, Inflação e Câmbio no Brasil

Projeto de análise de dados com Python, SQL e Power BI usando dados públicos do Banco Central do Brasil.

🚧 Em construção — a etapa de Power BI ainda não foi iniciada.

## Objetivo

Investigar como juros, inflação e câmbio se comportaram no Brasil desde 2010 e como se relacionam
entre si: períodos de juro real negativo, anos de maior volatilidade do dólar e o efeito da Selic
sobre o câmbio.

## Fontes de dados

Todas as séries vêm do [SGS – Sistema Gerenciador de Séries Temporais](https://www3.bcb.gov.br/sgspub/) do Banco Central, consultado pela API pública.

| Tabela               | Código SGS | Periodicidade | Descrição                                   |
|----------------------|-----------:|---------------|---------------------------------------------|
| `selic_meta`         | 432        | Diária        | Meta da taxa Selic (% a.a.)                 |
| `ipca_mensal`        | 433        | Mensal        | IPCA – variação mensal (%)                  |
| `ipca_12m`           | 13522      | Mensal        | IPCA – acumulado em 12 meses (%)            |
| `dolar_medio_mensal` | 3698       | Mensal        | Dólar comercial, média do mês (R$)          |
| `cdi_mensal`         | 4391       | Mensal        | CDI acumulado no mês (%)                    |
| `poupanca`           | 195        | Diária        | Rendimento da poupança, regra nova (desde maio de 2012) |
| `imoveis_ivgr`       | 21340      | Mensal        | Índice de valores de garantia de imóveis residenciais |

## Como rodar

```bash
python -m venv .venv
.venv\Scripts\activate            # Windows (no Linux/macOS: source .venv/bin/activate)
pip install -r requirements.txt

python src/coletar_dados.py       # baixa as séries da API -> data/raw/*.csv
python src/carregar_banco.py      # carrega os CSVs no SQLite -> data/macro.db
```

As consultas da pasta `sql/` podem ser executadas em qualquer cliente SQLite (DB Browser for SQLite,
extensão SQLite do VS Code etc.) apontando para `data/macro.db`.

## Estrutura

```
src/          coleta (API do BCB) e carga no SQLite; config.py lista as séries
sql/          consultas de análise, numeradas, com os resultados comentados
data/raw/     CSVs brutos baixados da API (versionados)
data/macro.db banco SQLite gerado pela carga (não versionado)
exploracao/   scripts de teste e rascunhos
```

## Principais conclusões até agora

- **Selic:** a mínima histórica de 2% durou de 6 de agosto de 2020 a 17 de março de 2021 (224 dias); a máxima do
  período, 15%, durou de 19 de junho de 2025 a 18 de março de 2026 (273 dias).
- **Juro real negativo por 22 meses seguidos** entre 2020 e 2022: a Selic na mínima durante a pandemia
  coincidiu com a alta da inflação. Pelo CDI acumulado em 12 meses, o período foi de outubro de 2020 a julho de 2022.
- **Dólar:** 2015 teve a maior alta da média anual (+41,6% sobre 2014) e 2020 foi o ano mais instável
  (diferença de R$ 1,49 entre o maior e o menor mês). Em 2022 e 2023, com a Selic alta atraindo
  capital estrangeiro, a média anual do dólar caiu (-4,3% e -3,3%).
- **Extremos do dólar (média mensal):** mínimo de R$ 1,56 em julho de 2011 e máximo de R$ 6,10 em
  dezembro de 2024.
