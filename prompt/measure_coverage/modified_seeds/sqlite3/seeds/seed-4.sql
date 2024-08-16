-- Assumption: 'users' is a base table, and 'user_details_view' is a view created from another table or a combination of tables.
SELECT DISTINCT users.id
FROM users
LEFT JOIN user_details_view ON users.id = user_details_view.user_id;
