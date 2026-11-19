-- Análise 6.1 do relatório: preço por período histórico
-- Rodar no schema dw_elt (ou dw_etl, trocando o nome do schema).
-- Os registros marcados como outlier (fl_outlier) ficam de fora.

-- Como o preço mudou em cada período histórico (pré-greve, greve, normalidade, pandemia)?
SELECT
    t.periodo_historico,
    p.produto,
    ROUND(AVG(f.valor_venda), 3) AS preco_medio
FROM dw_elt.fato_preco f
JOIN dw_elt.dim_tempo t   ON t.sk_tempo = f.sk_tempo
JOIN dw_elt.dim_produto p ON p.sk_produto = f.sk_produto
WHERE p.produto IN ('GASOLINA', 'DIESEL S10', 'ETANOL')
  AND NOT f.fl_outlier
GROUP BY t.periodo_historico, p.produto
ORDER BY p.produto, MIN(t.data);
