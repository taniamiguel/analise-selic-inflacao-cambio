
--“Juro real negativo por 21 meses, entre 2020 e 2022: pandemia + alta da inflação”.

SELECT i.data,
       s.valor AS selic,
       i.valor AS ipca_12m,
       ROUND(((1 + s.valor / 100) / (1 + i.valor / 100) - 1) * 100, 2) AS juro_real
FROM ipca_12m AS i
JOIN selic_meta AS s
  ON s.data = i.data
ORDER BY i.data;

