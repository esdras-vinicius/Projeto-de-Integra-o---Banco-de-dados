-- Mesmas checagens dos asserts do ETL: CNPJ com 14 dígitos, CEP com 8,
-- data preenchida e preço de venda maior que zero.
select cnpj, cep, data_coleta, valor_venda
from {{ ref('int_precos_limpos') }}
where coalesce(length(cnpj), 0) <> 14
   or coalesce(length(cep), 0) <> 8
   or data_coleta is null
   or valor_venda is null
   or valor_venda <= 0
