{# 
    This macro returns the description of the property_type
#}

{% macro get_property_type_description(property_type) -%}

    CASE {{dbt.safe_cast("property_type", api.Column.translate_type("string"))}}
        WHEN "D" THEN "Detached"
        WHEN "S" THEN "Semi-Detached"
        WHEN "T" THEN "Terraced"
        WHEN "F" THEN "Flats/Maisonettes"
        WHEN "O" THEN "Other"
        ELSE "Unknown"
    END
{%- endmacro%}