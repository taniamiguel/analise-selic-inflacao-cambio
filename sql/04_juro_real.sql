-- Juro real pela fórmula de Fisher: (1 + juro) / (1 + inflação) - 1

-- 1) Selic meta x IPCA 12 meses (visão "ex-ante" aproximada)
-- Limitação: compara a taxa vigente no dia 1º do mês com a inflação dos 12 meses ANTERIORES,
-- ou seja, mistura uma taxa de hoje com uma inflação do passado.
-- Resultado: juro real negativo por 22 meses seguidos, de jul/2020 a abr/2022
-- (Selic mínima de 2% na pandemia + alta da inflação).
SELECT i.data,
       s.valor AS selic,
       i.valor AS ipca_12m,
       ROUND(((1 + s.valor / 100) / (1 + i.valor / 100) - 1) * 100, 2) AS juro_real
FROM ipca_12m AS i
JOIN selic_meta AS s
  ON s.data = i.data
ORDER BY i.data;


-- 2) CDI acumulado 12 meses x IPCA 12 meses (juro real "ex-post", o que o investidor realmente ganhou)
-- Os dois lados cobrem a mesma janela de 12 meses, então a comparação é coerente.
-- O SQLite não tem função de produto, por isso o acumulado usa EXP(SUM(LN(1 + taxa))).
-- Resultado: juro real negativo por 22 meses seguidos, de out/2020 a jul/2022
-- (o mesmo fenômeno, deslocado ~3 meses porque o CDI acumulado reage com atraso à Selic).
WITH cdi_12m AS (
    SELECT data,
           (EXP(SUM(LN(1 + valor / 100)) OVER janela) - 1) * 100 AS cdi_12m,
           COUNT(*) OVER janela                                  AS meses
    FROM cdi_mensal
    WINDOW janela AS (ORDER BY data ROWS BETWEEN 11 PRECEDING AND CURRENT ROW)
)
SELECT i.data,
       ROUND(c.cdi_12m, 2) AS cdi_12m,
       i.valor             AS ipca_12m,
       ROUND(((1 + c.cdi_12m / 100) / (1 + i.valor / 100) - 1) * 100, 2) AS juro_real
FROM ipca_12m AS i
JOIN cdi_12m AS c
  ON c.data = i.data
WHERE c.meses = 12   -- descarta os 11 primeiros meses, que ainda não têm 12 meses de histórico
ORDER BY i.data;
