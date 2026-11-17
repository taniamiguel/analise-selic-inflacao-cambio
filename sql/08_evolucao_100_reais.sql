-- Tabela para a página "Seu dinheiro" do Power BI:
-- o valor de R$ 100 em cada investimento, mês a mês, de junho de 2012 a setembro de 2026.
-- Formato longo: uma linha por mês e por investimento.
-- A data indica o valor no FIM daquele mês; maio de 2012 é o ponto de partida (R$ 100).
-- valor_real = poder de compra, em reais de maio de 2012 (o valor dividido pela inflação acumulada).
-- Conferência: os valores de setembro de 2026 devem ser iguais aos do ranking (arquivo 06).

WITH taxas AS (
    -- Séries em % ao mês
    SELECT 'Inflação (IPCA)' AS investimento, data, valor FROM ipca_mensal
    UNION ALL
    SELECT 'CDI', data, valor FROM cdi_mensal
    UNION ALL
    SELECT 'Poupança', data, valor FROM poupanca WHERE strftime('%d', data) = '01'
),
evolucao_taxas AS (
    -- Rendimento acumulado até cada mês, recomeçando a conta para cada investimento
    SELECT investimento,
           data,
           100 * EXP(SUM(LN(1 + valor / 100)) OVER (PARTITION BY investimento ORDER BY data)) AS valor
    FROM taxas
    WHERE data BETWEEN '2012-06-01' AND '2026-09-01'
),
indices AS (
    -- Séries de valor ou índice
    SELECT 'Imóveis' AS investimento, data, valor FROM imoveis_ivgr
    UNION ALL
    SELECT 'Dólar', data, valor FROM dolar_medio_mensal
),
evolucao_indices AS (
    -- Cada mês comparado com o valor de maio de 2012 (o ponto de partida)
    SELECT i.investimento,
           i.data,
           100 * i.valor / base.valor AS valor
    FROM indices AS i
    JOIN indices AS base
      ON base.investimento = i.investimento
     AND base.data = '2012-05-01'
    WHERE i.data BETWEEN '2012-06-01' AND '2026-09-01'
),
dinheiro_parado AS (
    SELECT 'Dinheiro parado' AS investimento, data, 100 AS valor
    FROM ipca_mensal
    WHERE data BETWEEN '2012-06-01' AND '2026-09-01'
),
todos AS (
    SELECT * FROM evolucao_taxas
    UNION ALL
    SELECT * FROM evolucao_indices
    UNION ALL
    SELECT * FROM dinheiro_parado
),
com_ponto_inicial AS (
    -- Acrescenta maio de 2012 com R$ 100 para todos, para as linhas do gráfico partirem do mesmo ponto
    SELECT * FROM todos
    UNION ALL
    SELECT DISTINCT investimento, '2012-05-01', 100 FROM todos
)
SELECT t.data                               AS mes,
       t.investimento,
       ROUND(t.valor, 2)                    AS valor,
       ROUND(t.valor / ipca.valor * 100, 2) AS valor_real
FROM com_ponto_inicial AS t
JOIN com_ponto_inicial AS ipca
  ON ipca.data = t.data
 AND ipca.investimento = 'Inflação (IPCA)'
ORDER BY t.investimento, t.data;