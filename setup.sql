{% macro sp_contents() %}

{% set tbl_a = warehouse.NamedWhObject(name="Temp_tbl_a", type="TABLE") %}
{% set tbl_b = warehouse.NamedWhObject(name="Temp_tbl_b", type="TABLE") %}
{% set view_b = warehouse.NamedWhObject(name="Temp_view_b", type="VIEW") %}
{% set tbl_c = warehouse.NamedWhObject(name="Temp_tbl_c", type="TABLE") %}
{% set tbl_d = warehouse.NamedWhObject(name="Temp_tbl_d", type="TABLE") %}

{% exec %}{{ warehouse.CreateReplaceTableDefinition(tbl_a, "(id1 " + warehouse.DataType("varchar") +", id2 " + warehouse.DataType("varchar") +", id3 " + warehouse.DataType("varchar") +", insert_ts timestamp, num_a int)") }}{% endexec %}

INSERT INTO {{tbl_a}} VALUES
 ('1', 'b', 'ex', {% exec %}CAST('1999-12-31T00:00:01Z' AS {{warehouse.DataType("timestamp")}}){% endexec %}, 1),
 ('b', 'c', 'ex', {% exec %}CAST('2000-01-01T00:00:01Z' AS {{warehouse.DataType("timestamp")}}){% endexec %}, 2),
 (NULL, 'd', 'ex', {% exec %}CAST('2000-01-01T00:00:01Z' AS {{warehouse.DataType("timestamp")}}){% endexec %}, 3),
 ('D', '', 'ex', {% exec %}CAST('2000-01-01T00:00:01Z' AS {{warehouse.DataType("timestamp")}}){% endexec %}, 3)
;
{% exec %}{{ warehouse.CreateReplaceTableDefinition(tbl_b, "(id1 " + warehouse.DataType("varchar") +", id2 " + warehouse.DataType("varchar") +", id3 " + warehouse.DataType("varchar") +", timestamp timestamp)") }}{% endexec %}

INSERT INTO {{tbl_b}} VALUES
 ('2', 'd', 'e', {% exec %}CAST('2000-01-01T00:00:01Z' AS {{warehouse.DataType("timestamp")}}){% endexec %}),
 (NULL, 'd', 'f', {% exec %}CAST('2000-01-01T00:00:01Z' AS {{warehouse.DataType("timestamp")}}){% endexec %}),
 ('g',  'e', NULL, {% exec %}CAST('2000-01-01T00:00:01Z' AS {{warehouse.DataType("timestamp")}}){% endexec %}),
 (NULL, '3', 'h', {% exec %}CAST('2000-01-01T00:00:01Z' AS {{warehouse.DataType("timestamp")}}){% endexec %}),
 (NULL, 'i', 'h', {% exec %}CAST('2000-01-01T00:00:01Z' AS {{warehouse.DataType("timestamp")}}){% endexec %})
;

CREATE OR REPLACE VIEW {{view_b}} AS SELECT * FROM {{tbl_b}};

{% exec %}{{ warehouse.CreateReplaceTableDefinition(tbl_c, "(id1 " + warehouse.DataType("varchar") +", id2 " + warehouse.DataType("varchar") +", num_c int, num_b int, num_d int)") }}{% endexec %}

INSERT INTO {{tbl_c}} VALUES
 (NULL, 'b', 3, 12, 13),
 ('', '1', 4, 11, 5),
 ('2', NULL, 5, 11, 7),
 ('j', 'i', 6, 1, 12),
 (NULL, NULL, 7, 11, 15)
;
{% exec %}{{ warehouse.CreateReplaceTableDefinition(tbl_d, "(id1 " + warehouse.DataType("varchar") +", id2 " + warehouse.DataType("varchar") +", num_c int, num_d int, timestamp timestamp)") }}{% endexec %}

INSERT INTO {{tbl_d}} VALUES
 (NULL, '1', 4, 4, {% exec %}CAST('2010-01-01T00:00:01Z' AS {{warehouse.DataType("timestamp")}}){% endexec %}),
 ('2', NULL, 5, 5, {% exec %}CAST('2010-01-01T00:00:01Z' AS {{warehouse.DataType("timestamp")}}){% endexec %}),
 ('j', 'i', 6, 6, {% exec %}CAST('2010-01-01T00:00:01Z' AS {{warehouse.DataType("timestamp")}}){% endexec %}),
 ('j', '', 6, 6, {% exec %}CAST('2010-01-01T00:00:01Z' AS {{warehouse.DataType("timestamp")}}){% endexec %}),
 ('', 'b', 6, 6, {% exec %}CAST('2010-01-01T00:00:01Z' AS {{warehouse.DataType("timestamp")}}){% endexec %}),
 (NULL, NULL, 7, 7, {% exec %}CAST('2010-01-01T00:00:01Z' AS {{warehouse.DataType("timestamp")}}){% endexec %})
;
{% endmacro %}

{% macro block_contents() %}
    {% set setup_test_sp_proc = warehouse.NamedWhObject(name="setup_test_sp", type="STORED_PROC") %}
    {% with setup_test_sp = warehouse.NewStoredProc("setup_test_sp") %}
        {{ setup_test_sp.SetSqlBody(sp_contents()) }}

        {% if warehouse.DatabaseType() == "databricks" %}
            {{sp_contents()}}
        {% elif warehouse.DatabaseType() == "snowflake" %}
            {{warehouse.GetDeclarations(setup_test_sp)}}
            BEGIN {{setup_test_sp.SqlBody}} END;
        {% else %}
            {% exec %}{{warehouse.DeclareStoredProc(setup_test_sp) }}{% endexec %}
            CALL {{setup_test_sp_proc}}();
            {% exec %}{{warehouse.DropProcedure(setup_test_sp_proc)}}{% endexec %}
        {% endif %}
    {% endwith %}
{% endmacro %}

{% exec %}{{warehouse.BeginEndBlock(block_contents())}}{% endexec %}

