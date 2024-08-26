CREATE TABLE IF NOT EXISTS table_a (id INTEGER);
INSERT INTO table_a (id) VALUES (1), (2), (3);

CREATE VIEW view_b AS SELECT id FROM table_a WHERE id > 1;

SELECT DISTINCT a.id
FROM table_a AS a
LEFT JOIN view_b AS b ON a.id = b.id;
