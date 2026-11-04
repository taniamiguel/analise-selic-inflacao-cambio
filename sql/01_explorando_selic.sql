-- Explorando as 10 primeiras linhas da tabela selic_meta

SELECT *
FROM selic_meta
LIMIT 10;


-- Mínima e máxima da Selic desde 2010
SELECT MIN(valor) AS minima,
       MAX(valor) AS maxima
FROM selic_meta;

-- Período em que a Selic ficou com o valor de 15%
SELECT *
FROM selic_meta
WHERE valor = 15.0;

-- Período em que a Selic ficou na máxima (15%)
-- Resultado: de 19/06/2025 a 18/03/2026, 273 dias
SELECT MIN(data) AS inicio,
       MAX(data) AS fim,
       COUNT(*)  AS dias
FROM selic_meta
WHERE valor = 15.0;

-- Período em que a Selic ficou na mínima (2%)
-- Resultado: de 06/08/2020 a 17/03/2021, 224 dias

SELECT MIN(data) AS inicio,
       MAX(data) AS fim,
       COUNT(*)  AS dias
FROM selic_meta
WHERE valor = 2.0;

-- Selic Mínima, Média, Máxima por ano
-- Selic Minima ano de 2020, 2.0
-- Selic Maxima ano de 2026, 14.43
-- Nenhum ano a min e max foram iguais 
SELECT strftime('%Y', data)  AS ano,
       ROUND(AVG(valor), 2)  AS selic_media,
       MIN(valor)            AS minima,
       MAX(valor)            AS maxima,
       COUNT(*)              AS dias
FROM selic_meta
GROUP BY ano
ORDER BY ano;