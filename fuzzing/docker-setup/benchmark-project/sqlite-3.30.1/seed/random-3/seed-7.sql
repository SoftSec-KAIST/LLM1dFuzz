CREATE TABLE test_table (id INTEGER PRIMARY KEY, value TEXT);

CREATE VIEW test_view AS SELECT value FROM test_table WHERE id > 1;

SELECT DISTINCT a.value
FROM test_table AS a
LEFT JOIN test_view AS b ON a.id = b.id;
