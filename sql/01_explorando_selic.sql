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