
-- Explorando as 10 primeiras linhas da tabela dolar_medio_mensal
SELECT *
FROM dolar_medio_mensal
LIMIT 10;

-- Mínima e máxima da Dolar desde 2010
SELECT MIN(valor) AS minima,
       MAX(valor) AS maxima
FROM dolar_medio_mensal;

-- Período em que a Dolar ficou com o valor de 6.097
SELECT *
FROM dolar_medio_mensal
WHERE valor = 6.097;

-- Período em que a Dolar ficou na máxima (6.097)
-- Resultado: 12/01/2024, 1 dia
SELECT MIN(data) AS inicio,
       MAX(data) AS fim,
       COUNT(*)  AS dias
FROM dolar_medio_mensal
WHERE valor = 6.097;

-- Período em que a Dolar ficou na mínima 1.5639
-- Resultado: 01/07/2011, 1 dia

SELECT MIN(data) AS inicio,
       MAX(data) AS fim,
       COUNT(*)  AS dias
FROM dolar_medio_mensal
WHERE valor = 1.5639;

-- Dolar Mínima, Média, Máxima por ano

SELECT strftime('%Y', data)  AS ano,
       ROUND(AVG(valor), 2)  AS dolar_media,
       MIN(valor)            AS minima,
       MAX(valor)            AS maxima,
       COUNT(*)              AS dias
FROM dolar_medio_mensal
GROUP BY ano
ORDER BY ano;

-- “Amplitude do dólar dentro do ano: 2020 foi o ano mais instável”.
--2020: 5,6434 − 4,1495 = 1,4939
SELECT strftime('%Y', data)  AS ano,
       ROUND(AVG(valor), 2)  AS dolar_media,
       MIN(valor)            AS minima,
       MAX(valor)            AS maxima,
       COUNT(*)              AS dias,
       (MAX(valor) - MIN(valor)) AS variacao    
FROM dolar_medio_mensal
GROUP BY ano
ORDER BY variacao DESC
LIMIT 3;    

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
