GRAPH ?= graph-rosetta-code.sql

run:
	dropdb --if-exists smptest;
	createdb smptest;
	psql -1q smptest < schema.sql
	psql -1q smptest < $(GRAPH)
	psql -1q smptest < smp.sql 
	psql smptest -c "SELECT * FROM smp()"
