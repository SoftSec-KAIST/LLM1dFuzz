CREATE VIEW example_view AS SELECT * FROM some_other_table;

SELECT DISTINCT main_table.some_column
FROM main_table
LEFT JOIN example_view 
ON main_table.id = example_view.id;
