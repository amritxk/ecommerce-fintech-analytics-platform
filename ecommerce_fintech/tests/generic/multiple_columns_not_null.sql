{% test multiple_columns_not_null(model, column_name, column_names) %}
select * from {{model}}
where
{% for col in column_names %}
  {{col}} is null
  {% if not loop.last %} or
  {% endif %}
{% endfor %}
{% endtest %}