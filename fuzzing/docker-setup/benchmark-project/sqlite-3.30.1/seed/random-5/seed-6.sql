-- Assuming 'myTable' and 'myView' exist within your SQLite database

CREATE VIEW myView AS SELECT column1 FROM myTable;

SELECT DISTINCT a.*
FROM myTable AS a
LEFT JOIN myView AS b ON a.id = b.column1;
