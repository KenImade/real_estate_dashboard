{# 
    This macro returns the description of the property's age
#}

{% macro get_property_age_description(old_new) -%}
    CASE {{dbt.safe_cast("old_new", api.Column.translate_type("string"))}}
        WHEN "Y" THEN "Newly Built"
        WHEN "N" THEN "Established Residential Building"
        ELSE "Unknown"
    END
{%- endmacro %}