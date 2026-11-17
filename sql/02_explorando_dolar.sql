-- Atenção: dolar_medio_mensal é uma série MENSAL (uma linha por mês, datada no dia 1º),
-- então COUNT(*) conta meses, e não dias.

-- Explorando as 10 primeiras linhas da tabela dolar_medio_mensal
SELECT *
FROM dolar_medio_mensal
LIMIT 10;

-- Mínima e máxima do dólar desde 2010
SELECT MIN(valor) AS minima,
       MAX(valor) AS maxima
FROM dolar_medio_mensal;

-- Mês em que o dólar ficou com o valor de 6.097
SELECT *
FROM dolar_medio_mensal
WHERE valor = 6.097;

-- Mês em que o dólar ficou na máxima (6.097)
-- Resultado: dezembro de 2024 (2024-12-01), 1 mês
SELECT MIN(data) AS inicio,
       MAX(data) AS fim,
       COUNT(*)  AS meses
FROM dolar_medio_mensal
WHERE valor = 6.097;

-- Mês em que o dólar ficou na mínima (1.5639)
-- Resultado: julho de 2011 (2011-07-01), 1 mês
SELECT MIN(data) AS inicio,
       MAX(data) AS fim,
       COUNT(*)  AS meses
FROM dolar_medio_mensal
WHERE valor = 1.5639;

-- Dólar mínimo, médio e máximo por ano
SELECT strftime('%Y', data)  AS ano,
       ROUND(AVG(valor), 2)  AS dolar_media,
       MIN(valor)            AS minima,
       MAX(valor)            AS maxima,
       COUNT(*)              AS meses
FROM dolar_medio_mensal
GROUP BY ano
ORDER BY ano;

-- Amplitude do dólar dentro do ano: 2020 foi o ano mais instável
-- 2020: 5,6434 − 4,1495 = 1,4939
SELECT strftime('%Y', data)       AS ano,
       ROUND(AVG(valor), 2)       AS dolar_media,
       MIN(valor)                 AS minima,
       MAX(valor)                 AS maxima,
       COUNT(*)                   AS meses,
       (MAX(valor) - MIN(valor))  AS variacao
FROM dolar_medio_mensal
GROUP BY ano
ORDER BY variacao DESC
LIMIT 3;
