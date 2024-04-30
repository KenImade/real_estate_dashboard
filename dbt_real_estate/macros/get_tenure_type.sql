{# 
    This macro returns the tenure type of the property
#}

{% macro get_tenure_type(duration) -%}
    CASE {{dbt.safe_cast("duration", api.Column.translate_type("string"))}}
        WHEN "F" THEN "Freehold"
        WHEN "L" THEN "Leasehold"
        ELSE "Unknown"
    END
{%- endmacro %}