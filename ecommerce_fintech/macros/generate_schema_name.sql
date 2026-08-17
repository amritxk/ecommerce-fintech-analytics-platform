{% macro generate_schema_name(custom_schema_name, node) -%}

  {%- if target.name == 'ci' -%}
    SCHEMA_CI_TEMP
  {%- elif custom_schema_name is none -%}
    {{ target.schema }}
  {%- else -%}
    {{ custom_schema_name | trim }}
  {%- endif -%}

{%- endmacro %}
  

  