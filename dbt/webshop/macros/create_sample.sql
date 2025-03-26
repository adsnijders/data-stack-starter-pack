{% macro sample_data() %}

    {% do log("target.dbname = " ~ target.dbname ~ "; target.schema = " ~ target.schema, info=True) %}

    {% if execute %}

        -- Create the target schema if it does not exist yet
        {% set sql_create_schema_query %}
            create schema if not exists {{ target.schema }};
        {% endset %}
        {% do run_query(sql_create_schema_query) %}
        {% do log("Created " ~ target.schema ~ " if it did not exist yet", info=True) %}

        -- Loop through every source
        {% for node in graph.sources.values() %}
            {% do log(node.name, info=True) %}

            -- Check the sample method of the source
            {% if node.config.sample_method == "full_sample" %}

                -- Create the target table and insert the sampled data
                {% set sql_create_sample_query %}
                    drop table if exists {{ node.name }};
                    create table if not exists {{ target.dbname }}.{{ target.schema }}.{{ node.name }} as (
                        select 
                            *
                        from {{ target.dbname }}.raw_prod.{{ node.name }}
                    );
                {% endset %}
                {% do run_query(sql_create_sample_query) %}
                {% do log("Created " ~ node.name ~ " in " ~ target.schema ~ " if it did not exist yet", info=True) %}

            {% endif %}

        {% endfor %}

    {% endif %}

{% endmacro %}
