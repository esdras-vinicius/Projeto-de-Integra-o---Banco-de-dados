-- Análises do relatório (seção 6), no estilo do repositório do monitor
-- Rodar no schema dw_elt (ou dw_etl, trocando o nome do schema).
-- Nas análises de preço, os registros marcados como outlier (fl_outlier) ficam de fora.


-- 6.1 Como o preço mudou em cada período histórico (pré-greve, greve, normalidade, pandemia)?
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


-- 6.2 Quantos postos cada bandeira tem? (as 10 maiores)
SELECT
    b.bandeira_padronizada,
    COUNT(DISTINCT f.sk_posto) AS postos
FROM dw_elt.fato_preco f
JOIN dw_elt.dim_bandeira b ON b.sk_bandeira = f.sk_bandeira
GROUP BY b.bandeira_padronizada
ORDER BY postos DESC
LIMIT 10;


-- 6.3 Quantos preços foram coletados em cada ano?
--    (2020 tem menos por causa do intervalo sem coleta de 18/08 a 18/10)
SELECT
    t.ano,
    COUNT(*) AS precos_coletados
FROM dw_elt.fato_preco f
JOIN dw_elt.dim_tempo t ON t.sk_tempo = f.sk_tempo
GROUP BY t.ano
ORDER BY t.ano;
