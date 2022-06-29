all:
	dropdb --if-exists primtest
	createdb primtest
	psql -1 primtest < schema.sql
	psql -1 primtest -c "SELECT * FROM edges"
	psql -1 primtest < prim.sql
