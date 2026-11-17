-- =====================================================================
-- Ranking: onde R$ 100 renderam mais, de junho de 2012 a setembro de 2026
-- =====================================================================
-- Junta numa tabela só os resultados da simulação do arquivo 05 e calcula,
-- para cada investimento, o ganho real (acima da inflação) e a posição no ranking.
--
-- Período: de junho de 2012 a setembro de 2026 (172 meses), o único em que
-- todas as séries têm dados completos (ver explicação no arquivo 05).
--
-- Como funciona:
--   1) resultados: empilha com UNION ALL o valor final de cada investimento.
--      - IPCA, CDI e poupança: acumulam as taxas mensais com EXP(SUM(LN(...))).
--      - Imóveis e dólar: comparam o valor de setembro de 2026 com o de maio de 2012.
--      - Dinheiro parado: continua valendo R$ 100.
--   2) ipca: separa o valor corrigido pela inflação, que é a referência.
--   3) Consulta final: calcula o ganho real e numera as posições com RANK().
--
-- A inflação aparece no ranking com ganho real de 0%: é a linha divisória.
-- Acima dela, o investimento ganhou da inflação; abaixo, perdeu.
--
-- Limitações:
--   - Valores brutos, sem Imposto de Renda nem taxas (a poupança é isenta de IR).
--   - Imóveis: o índice mede só o preço, sem a renda de aluguel.
--   - Dólar: usa a média do mês, não a cotação de um dia específico.
--   - As datas do período estão repetidas na consulta; para mudar o período,
--     é preciso alterar todas elas.
--
-- Resultado:
--   1º CDI ................ R$ 381,71 (+72,60% real)
--   2º Dólar .............. R$ 259,05 (+17,14% real)
--   3º Poupança ........... R$ 239,94 (+8,50% real)
--   4º Inflação (IPCA) .... R$ 221,15 (referência, 0%)
--   5º Imóveis ............ R$ 175,87 (-20,47% real)
--   6º Dinheiro parado .... R$ 100,00 (-54,78% real)

WITH resultados AS (
    SELECT 'Inflação (IPCA)' AS investimento,
           100 * EXP(SUM(LN(1 + valor / 100))) AS valor_final
    FROM ipca_mensal
    WHERE data BETWEEN '2012-06-01' AND '2026-09-01'
    UNION ALL
    SELECT 'CDI', 100 * EXP(SUM(LN(1 + valor / 100)))
    FROM cdi_mensal
    WHERE data BETWEEN '2012-06-01' AND '2026-09-01'
    UNION ALL
    SELECT 'Poupança', 100 * EXP(SUM(LN(1 + valor / 100)))
    FROM poupanca
    WHERE data BETWEEN '2012-06-01' AND '2026-09-01'
      AND strftime('%d', data) = '01'
    UNION ALL
    SELECT 'Imóveis', 100 * fim.valor / inicio.valor
    FROM imoveis_ivgr AS inicio, imoveis_ivgr AS fim
    WHERE inicio.data = '2012-05-01' AND fim.data = '2026-09-01'
    UNION ALL
    SELECT 'Dólar', 100 * fim.valor / inicio.valor
    FROM dolar_medio_mensal AS inicio, dolar_medio_mensal AS fim
    WHERE inicio.data = '2012-05-01' AND fim.data = '2026-09-01'
    UNION ALL
    SELECT 'Dinheiro parado', 100
),
ipca AS (
    SELECT valor_final
    FROM resultados
    WHERE investimento = 'Inflação (IPCA)'
)
SELECT RANK() OVER (ORDER BY r.valor_final DESC)              AS posicao,
       r.investimento,
       ROUND(r.valor_final, 2)                                AS valor_final,
       ROUND((r.valor_final / ipca.valor_final - 1) * 100, 2) AS ganho_real_pct
FROM resultados AS r, ipca
ORDER BY posicao;
