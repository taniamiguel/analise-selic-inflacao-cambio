
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