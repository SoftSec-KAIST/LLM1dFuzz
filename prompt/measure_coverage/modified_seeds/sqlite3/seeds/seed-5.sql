CREATE TABLE main_table (id INTEGER PRIMARY KEY, value TEXT);
CREATE TABLE secondary_table (id INTEGER, linked_value TEXT);
CREATE VIEW sample_view AS SELECT * FROM secondary_table;
INSERT INTO main_table (id, value) VALUES (1, 'test1'), (2, 'test2');
INSERT INTO secondary_table (id, linked_value) VALUES (1, 'linked1'), (2, 'linked2');

SELECT DISTINCT main_table.value
FROM main_table LEFT JOIN sample_view ON main_table.id = sample_view.id;
