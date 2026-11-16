
-- Variação do dólar ao ano anterior, comparando as médias  de um ano com a média do ano anterior
-- Resultado: 2015 41,6%;
WITH dolar_anual AS (
    SELECT strftime('%Y', data) AS ano,
           AVG(valor)           AS dolar_medio
    FROM dolar_medio_mensal
    GROUP BY ano
)
SELECT ano,
       ROUND(dolar_medio, 2)                                                      AS dolar_medio,
       ROUND(LAG(dolar_medio) OVER (ORDER BY ano), 2)                             AS ano_anterior,
       ROUND((dolar_medio / LAG(dolar_medio) OVER (ORDER BY ano) - 1) * 100, 1) AS variacao_pct
FROM dolar_anual
ORDER BY variacao_pct DESC
LIMIT 3;

-- Os anos de queda do dólar, comparando as médias de um ano com a média do ano anterior
-- Resultado: 2022 e 2023 anos mais baixos do dolar, selic alta atrai investimentos e dolar cai
WITH dolar_anual AS (
     SELECT strftime('%Y', data) AS ano,
           AVG(valor)           AS dolar_medio
    FROM dolar_medio_mensal
    GROUP BY ano
),
variacao AS (
    SELECT ano,
       ROUND(dolar_medio, 2)                                                      AS dolar_medio,
       ROUND(LAG(dolar_medio) OVER (ORDER BY ano), 2)                             AS ano_anterior,
       ROUND((dolar_medio / LAG(dolar_medio) OVER (ORDER BY ano) - 1) * 100, 1) AS variacao_pct
    FROM dolar_anual
)
SELECT *
FROM variacao
WHERE variacao_pct < 0
ORDER BY ano;
