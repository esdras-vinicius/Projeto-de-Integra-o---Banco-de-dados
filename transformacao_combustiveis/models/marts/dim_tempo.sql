WITH datas AS (
    SELECT GENERATE_SERIES(DATE '2018-01-01', DATE '2020-12-31', INTERVAL '1 day')::DATE AS data
)
SELECT
    TO_CHAR(data, 'YYYYMMDD')::INTEGER AS sk_tempo,
    data,
    EXTRACT(DAY FROM data)::SMALLINT AS dia,
    EXTRACT(MONTH FROM data)::SMALLINT AS mes,
    CASE EXTRACT(MONTH FROM data)::INTEGER
        WHEN 1 THEN 'Janeiro'
        WHEN 2 THEN 'Fevereiro'
        WHEN 3 THEN 'Março'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Maio'
        WHEN 6 THEN 'Junho'
        WHEN 7 THEN 'Julho'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Setembro'
        WHEN 10 THEN 'Outubro'
        WHEN 11 THEN 'Novembro'
        WHEN 12 THEN 'Dezembro'
    END AS nome_mes,
    EXTRACT(QUARTER FROM data)::SMALLINT AS trimestre,
    CASE WHEN EXTRACT(MONTH FROM data) <= 6 THEN 1 ELSE 2 END::SMALLINT AS semestre,
    EXTRACT(YEAR FROM data)::SMALLINT AS ano,
    CASE EXTRACT(ISODOW FROM data)::INTEGER
        WHEN 1 THEN 'Segunda-feira'
        WHEN 2 THEN 'Terça-feira'
        WHEN 3 THEN 'Quarta-feira'
        WHEN 4 THEN 'Quinta-feira'
        WHEN 5 THEN 'Sexta-feira'
        WHEN 6 THEN 'Sábado'
        WHEN 7 THEN 'Domingo'
    END AS dia_semana,
    CASE
        WHEN data < DATE '2018-05-21' THEN 'Pré-Greve 2018'
        WHEN data BETWEEN DATE '2018-05-21' AND DATE '2018-06-05' THEN 'Greve Caminhoneiros 2018'
        WHEN data > DATE '2018-06-05' AND data < DATE '2020-03-11' THEN 'Normalidade 2018-2019'
        ELSE 'Pandemia 2020'
    END AS periodo_historico
FROM datas
ORDER BY sk_tempo
