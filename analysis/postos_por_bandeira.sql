-- Análise 6.3 do relatório: postos por bandeira
-- Rodar no schema dw_elt (ou dw_etl, trocando o nome do schema).

-- Quantos postos cada bandeira tem? (as 10 maiores)
SELECT
    b.bandeira_padronizada,
    COUNT(DISTINCT f.sk_posto) AS postos
FROM dw_elt.fato_preco f
JOIN dw_elt.dim_bandeira b ON b.sk_bandeira = f.sk_bandeira
GROUP BY b.bandeira_padronizada
ORDER BY postos DESC
LIMIT 10;
