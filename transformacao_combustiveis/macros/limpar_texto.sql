{#
  Equivale a  .str.strip().replace("", pd.NA)  do ETL:
  tira espaços do começo e do fim e transforma texto vazio em NULL.

  O btrim do PostgreSQL, sozinho, só remove o espaço comum. O str.strip()
  do Python remove todo tipo de espaço Unicode (tab, quebra de linha,
  espaço não separável etc.), então a lista abaixo reproduz a mesma regra.
  Sem isso, 378 complementos que têm só um espaço não separável (U+00A0)
  ficariam diferentes nos dois pipelines.
#}
{% macro limpar_texto(coluna) %}
    nullif(
        btrim(
            {{ coluna }},
            chr(32) || chr(9) || chr(10) || chr(11) || chr(12) || chr(13)
            || chr(28) || chr(29) || chr(30) || chr(31) || chr(133) || chr(160)
            || chr(5760) || chr(8192) || chr(8193) || chr(8194) || chr(8195)
            || chr(8196) || chr(8197) || chr(8198) || chr(8199) || chr(8200)
            || chr(8201) || chr(8202) || chr(8232) || chr(8233) || chr(8239)
            || chr(8287) || chr(12288)
        ),
        ''
    )
{% endmacro %}
