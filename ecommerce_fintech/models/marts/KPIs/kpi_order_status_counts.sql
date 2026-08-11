
{# {% set status = ['shipped','confirmed','pending','delivered','processing','cancelled'] %} #}

{% set sql %}
 
 select distinct (order_status) from {{ ref('fct_orders') }}

{% endset %}





{% if execute %}
  {% set results = run_query (sql).columns[0].values() %}
{% else %}
  {% set results = [] %}

{% endif %}





with order_status_count AS (
    select 
     {% for stat in results %}
       sum( case when order_status = '{{stat}}' then 1 else 0 end) as {{stat}}_count
       {%if not loop.last%},
       {% endif %}
       


     {% endfor %}
       
       

     

    from {{ ref('fct_orders') }}
)


select * from order_status_count