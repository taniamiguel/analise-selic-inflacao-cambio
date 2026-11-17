-- =====================================================================
-- Simulação: quanto R$ 100 aplicados em junho de 2012 valeriam em setembro de 2026
-- =====================================================================
-- Período: de junho de 2012 a setembro de 2026 (172 meses).
-- Por que esse período: é o único em que TODAS as séries têm dados completos.
--   - Início: a poupança (regra nova) só começa em 04/05/2012, então o primeiro
--     mês completo é junho de 2012.
--   - Fim: o índice de imóveis (IVG-R) é publicado com atraso e vai só até
--     setembro de 2026.
--
-- Dois tipos de cálculo, conforme o formato da série:
--   - Séries em % ao mês (IPCA, CDI, poupança): os rendimentos se acumulam
--     multiplicando os fatores mensais. Como o SQL não tem função de produto,
--     usamos EXP(SUM(LN(1 + taxa))): o logaritmo transforma a multiplicação
--     em soma, e o EXP desfaz o logaritmo.
--   - Séries de valor ou índice (imóveis, dólar): comparamos o valor final com
--     o inicial. O ponto de partida é maio de 2012, porque a variação de junho
--     é a diferença entre o valor de maio e o de junho.
--
-- Ganho real = (valor final / valor corrigido pelo IPCA - 1) * 100
-- Limitação geral: valores brutos, sem Imposto de Renda nem taxas.


-- 1) R$ 100 corrigidos pela inflação (IPCA)
-- Resultado: R$ 221,15 em 172 meses.
-- O que custava R$ 100 em junho de 2012 custava R$ 221,15 em setembro de 2026.
-- Se os R$ 100 tivessem ficado parados na carteira, comprariam só 0,45 do que
-- compravam em 2012: uma perda de 54,78% do poder de compra.
SELECT COUNT(*)                                       AS meses,
       ROUND(100 * EXP(SUM(LN(1 + valor / 100))), 2) AS valor_final
FROM ipca_mensal
WHERE data BETWEEN '2012-06-01' AND '2026-09-01';


-- 2) R$ 100 aplicados no CDI
-- Resultado: R$ 381,71 em 172 meses. Ganho real: +72,60%.
SELECT COUNT(*)                                       AS meses,
       ROUND(100 * EXP(SUM(LN(1 + valor / 100))), 2) AS valor_final
FROM cdi_mensal
WHERE data BETWEEN '2012-06-01' AND '2026-09-01';


-- 3) Ganho real do CDI (acima da inflação)
-- Resultado: 72,60%. Os R$ 100 no CDI compram 1,73 vez o que compravam em 2012.
-- Atenção: o ganho real é calculado DIVIDINDO, não subtraindo.
-- A subtração (281,71% - 121,15% = 160,56%) daria um resultado muito errado.
WITH ipca AS (
    SELECT 100 * EXP(SUM(LN(1 + valor / 100))) AS final
    FROM ipca_mensal
    WHERE data BETWEEN '2012-06-01' AND '2026-09-01'
),
cdi AS (
    SELECT 100 * EXP(SUM(LN(1 + valor / 100))) AS final
    FROM cdi_mensal
    WHERE data BETWEEN '2012-06-01' AND '2026-09-01'
)
SELECT ROUND(ipca.final, 2)                         AS ipca_final,
       ROUND(cdi.final, 2)                          AS cdi_final,
       ROUND((cdi.final / ipca.final - 1) * 100, 2) AS ganho_real_pct
FROM ipca, cdi;


-- 4) R$ 100 na poupança
-- A tabela tem uma linha para cada dia de aniversário possível (dia 1 a 28).
-- Simulamos um depósito feito no dia 1, então usamos só as linhas do dia 1.
-- Resultado: R$ 239,94 em 172 meses. Ganho real: +8,50%.
-- A poupança ganhou da inflação, mas por pouco em 14 anos.
-- Observação: a poupança é isenta de IR; o CDI, não.
SELECT COUNT(*)                                       AS meses,
       ROUND(100 * EXP(SUM(LN(1 + valor / 100))), 2) AS valor_final
FROM poupanca
WHERE data BETWEEN '2012-06-01' AND '2026-09-01'
  AND strftime('%d', data) = '01';


-- 5) R$ 100 em imóveis (IVG-R)
-- O IVG-R é um índice: comparamos o valor de setembro de 2026 com o de maio de 2012.
-- Resultado: o índice foi de 457,03 para 803,77, então R$ 100 viraram R$ 175,87.
-- Ganho real: -20,47%. O PREÇO dos imóveis subiu menos que a inflação.
-- Limitações:
--   - O índice mede só o preço. NÃO inclui a renda de aluguel, que mudaria o resultado.
--   - É uma média nacional dos imóveis financiados; cidades e bairros variam muito.
SELECT inicio.valor                              AS indice_maio_2012,
       fim.valor                                 AS indice_set_2026,
       ROUND(100 * fim.valor / inicio.valor, 2)  AS valor_final
FROM imoveis_ivgr AS inicio, imoveis_ivgr AS fim
WHERE inicio.data = '2012-05-01'
  AND fim.data    = '2026-09-01';


-- 6) R$ 100 em dólar
-- Resultado: o dólar médio foi de R$ 1,99 para R$ 5,14, então R$ 100 viraram R$ 259,05.
-- Ganho real: +17,14%.
-- Limitação: a série é a MÉDIA do mês, não a cotação de um dia específico,
-- então o resultado é uma aproximação.
SELECT inicio.valor                              AS dolar_maio_2012,
       fim.valor                                 AS dolar_set_2026,
       ROUND(100 * fim.valor / inicio.valor, 2)  AS valor_final
FROM dolar_medio_mensal AS inicio, dolar_medio_mensal AS fim
WHERE inicio.data = '2012-05-01'
  AND fim.data    = '2026-09-01';


-- Ranking final (R$ 100 de junho de 2012 a setembro de 2026):
--   1º CDI ................ R$ 381,71 (+72,60% real)
--   2º Dólar .............. R$ 259,05 (+17,14% real)
--   3º Poupança ........... R$ 239,94 (+8,50% real)
--   -- Inflação (IPCA) .... R$ 221,15 (referência)
--   4º Imóveis ............ R$ 175,87 (-20,47% real)
--   5º Dinheiro parado .... R$ 100,00 (-54,78% real)