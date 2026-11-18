-- Mesmas checagens dos asserts do ETL: CNPJ com 14 dígitos, CEP com 8,
-- data preenchida e preço de venda maior que zero.
select cnpj, cep, data_coleta, valor_venda
from {{ ref('int_precos_preparados') }}
where length(cnpj) <> 14
   or length(cep) <> 8
   or data_coleta is null
   or valor_venda is null
   or valor_venda <= 0
