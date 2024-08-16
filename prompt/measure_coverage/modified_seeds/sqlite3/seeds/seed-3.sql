SELECT DISTINCT *
FROM a_table
LEFT JOIN (SELECT * FROM a_view) AS subview ON a_table.id = subview.id;
