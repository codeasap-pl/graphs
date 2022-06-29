CREATE OR REPLACE FUNCTION graph._get_pathlen(
       IN _src TEXT,
       INOUT _visited hstore)
RETURNS hstore
AS $$
DECLARE
    u_ TEXT;
BEGIN
    SELECT COALESCE(_visited, '') || hstore(_src, '1') INTO _visited;

    FOR u_ IN SELECT dst FROM store.graph
                         WHERE NOT is_removed AND src = _src
    LOOP                         
           IF NOT exist(_visited, u_) THEN
              SELECT graph._get_pathlen(u_, _visited) || _visited
                     INTO _visited;
           END IF;
    END LOOP;
END
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION graph.get_pathlen(_src TEXT)
RETURNS INTEGER
AS $$
DECLARE
    visited_ hstore = hstore(_src, '1');
BEGIN
    SELECT * FROM graph._get_pathlen(_src, visited_) INTO visited_;
    RETURN array_length(akeys(visited_), 1);
END
$$
LANGUAGE PLPGSQL;

