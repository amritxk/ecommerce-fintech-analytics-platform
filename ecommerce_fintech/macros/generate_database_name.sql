{% macro generate_database_name(custom_database_name, node) -%}

  {%- if target.name == 'ci' -%}
    STAGING_DB
  {%- elif custom_database_name is none -%}
    {{ target.database }}
  {%- else -%}
    {{ custom_database_name | trim }}
  {%- endif -%}

{%- endmacro %}
