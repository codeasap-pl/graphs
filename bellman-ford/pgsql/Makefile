GRAPH ?= graph-simple.sql


all:
	dropdb --if-exists bftest;
	createdb bftest;
	psql -1q bftest < schema.sql
	psql -1q bftest < $(GRAPH)
	psql -1q bftest < bellman-ford.sql 
	psql bftest -c "SELECT * FROM bellman_ford(0)"

