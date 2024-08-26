-- Assuming 'my_table' is an existing table and 'my_view' is a view created based on some conditions.
-- This example is for educational purposes to illustrate the kind of query that could have triggered CVE-2019-19923.

CREATE TABLE my_table(id INTEGER PRIMARY KEY, value TEXT);
CREATE VIEW my_view AS SELECT id, value FROM my_table WHERE value IS NOT NULL;

SELECT DISTINCT my_table.id
FROM my_table
LEFT JOIN my_view ON my_table.id = my_view.id;
