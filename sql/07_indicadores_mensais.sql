-- Tabela para a página "Cenário" do Power BI:
-- uma linha por mês, com Selic, IPCA, dólar e juro real lado a lado.
-- A Selic é a do dia 1º de cada mês (mesma aproximação do arquivo 04).
SELECT i.data   AS mes,
       s.valor   AS selic,
       i.valor   AS ipca_mensal,
       i12.valor AS ipca_12m,
       d.valor   AS dolar,
       ROUND(((1 + s.valor / 100) / (1 + i12.valor / 100) - 1) * 100, 2) AS juro_real
FROM ipca_mensal AS i
LEFT JOIN ipca_12m           AS i12 ON i12.data = i.data
LEFT JOIN selic_meta         AS s   ON s.data   = i.data
LEFT JOIN dolar_medio_mensal AS d   ON d.data   = i.data
ORDER BY i.data;