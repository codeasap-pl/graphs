CREATE OR REPLACE FUNCTION graph.get_pathlen(_src TEXT)
RETURNS INTEGER
AS $$
DECLARE
    pathlen_ INTEGER = 1;
BEGIN
    WITH RECURSIVE my_traversal(lvl, dst, visited, row_num)
    AS (
       SELECT 0 AS lvl,
              dst,
              hstore(src, '1'),
              0::bigint AS row_num
              FROM store.graph
              WHERE NOT is_removed AND src = _src
       UNION
       SELECT T.lvl + 1 AS lvl,
              G.dst,
              visited || (G.dst || '=>1')::hstore,
              ROW_NUMBER() OVER (PARTITION BY lvl) AS row_num
              FROM store.graph G
              JOIN my_traversal T ON G.src = T.dst
              WHERE NOT G.is_removed AND
                    NOT exist(T.visited, G.dst)
    )
    SELECT array_length(akeys(visited), 1)
           FROM my_traversal
           ORDER BY lvl DESC, row_num DESC LIMIT 1
           INTO pathlen_;

    RETURN pathlen_;
END
$$
LANGUAGE PLPGSQL;
