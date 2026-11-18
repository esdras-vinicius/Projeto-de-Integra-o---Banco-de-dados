-- O grão da fato é um preço por data, posto e produto.
-- O teste falha se alguma combinação aparecer mais de uma vez.
select sk_tempo, sk_posto, sk_produto, count(*) as repeticoes
from {{ ref('fato_preco') }}
group by sk_tempo, sk_posto, sk_produto
having count(*) > 1
