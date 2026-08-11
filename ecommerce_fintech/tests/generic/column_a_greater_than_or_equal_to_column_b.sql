{% test column_a_greater_than_or_equal_to_column_b(model , column_name , column_b)%}
select * from {{model}}
where {{column_name}} < {{column_b}}
{% endtest %}
