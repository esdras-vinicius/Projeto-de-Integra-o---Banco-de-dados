-- Análise 6.2 do relatório: cidades com a gasolina mais cara e mais barata
-- Rodar no schema dw_elt (ou dw_etl, trocando o nome do schema).
-- Os registros marcados como outlier (fl_outlier) ficam de fora.

-- Quais são as 10 cidades com a gasolina mais cara?
SELECT
    l.municipio,
    l.uf,
    ROUND(AVG(f.valor_venda), 3) AS preco_medio
FROM dw_elt.fato_preco f
JOIN dw_elt.dim_localizacao l ON l.sk_localizacao = f.sk_localizacao
JOIN dw_elt.dim_produto p     ON p.sk_produto = f.sk_produto
WHERE p.produto = 'GASOLINA'
  AND NOT f.fl_outlier
GROUP BY l.municipio, l.uf
ORDER BY preco_medio DESC
LIMIT 10;


-- Quais são as 10 cidades com a gasolina mais barata?
SELECT
    l.municipio,
    l.uf,
    ROUND(AVG(f.valor_venda), 3) AS preco_medio
FROM dw_elt.fato_preco f
JOIN dw_elt.dim_localizacao l ON l.sk_localizacao = f.sk_localizacao
JOIN dw_elt.dim_produto p     ON p.sk_produto = f.sk_produto
WHERE p.produto = 'GASOLINA'
  AND NOT f.fl_outlier
GROUP BY l.municipio, l.uf
ORDER BY preco_medio ASC
LIMIT 10;
