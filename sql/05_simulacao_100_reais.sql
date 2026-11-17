-- =====================================================================
-- Simulação: quanto R$ 100 aplicados em junho de 2012 valeriam em setembro de 2026
-- =====================================================================
-- Período: de junho de 2012 a setembro de 2026 (172 meses).
-- Por que esse período: é o único em que TODAS as séries têm dados completos.
--   - Início: a poupança (regra nova) só começa em 04/05/2012, então o primeiro
--     mês completo é junho de 2012.
--   - Fim: o índice de imóveis (IVG-R) é publicado com atraso e vai só até
--     setembro de 2026.
-- Os rendimentos se acumulam multiplicando os fatores mensais (juros compostos).
-- Como o SQL não tem função de produto, usamos EXP(SUM(LN(1 + taxa))):
-- o logaritmo transforma a multiplicação em soma, e o EXP desfaz o logaritmo.
-- Limitação: os valores são brutos, sem Imposto de Renda nem taxas.


-- 1) R$ 100 corrigidos pela inflação (IPCA)
-- Resultado: R$ 221,15 em 172 meses.
-- O que custava R$ 100 em junho de 2012 custava R$ 221,15 em setembro de 2026.
SELECT COUNT(*)                                       AS meses,
       ROUND(100 * EXP(SUM(LN(1 + valor / 100))), 2) AS valor_final
FROM ipca_mensal
WHERE data BETWEEN '2012-06-01' AND '2026-09-01';


-- 2) R$ 100 aplicados no CDI
-- Resultado: R$ 381,71 em 172 meses.
SELECT COUNT(*)                                       AS meses,
       ROUND(100 * EXP(SUM(LN(1 + valor / 100))), 2) AS valor_final
FROM cdi_mensal
WHERE data BETWEEN '2012-06-01' AND '2026-09-01';


-- 3) Ganho real do CDI (acima da inflação)
-- Resultado: 72,60% de ganho real.
-- Os R$ 100 no CDI compram 1,73 vez o que compravam em 2012.
-- Atenção: o ganho real é calculado DIVIDINDO, não subtraindo.
-- A subtração (281,71% - 121,15% = 160,56%) daria um resultado muito errado.
-- Comparação: se os R$ 100 tivessem ficado parados na carteira, comprariam
-- só 0,45 do que compravam em 2012, uma perda de 54,78% do poder de compra.
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