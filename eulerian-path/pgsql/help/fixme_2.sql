CREATE TYPE pathinfo_t AS (
       lvl integer,
       src TEXT,
       dst TEXT,
       visited hstore,
       row_num bigint,
       pathlen_ integer
);

-- F is wrong?
CREATE OR REPLACE FUNCTION graph.get_pathlen_hstore_fixme_2(_src TEXT)
RETURNS pathinfo_t
AS $$
DECLARE
    pathinfo_ pathinfo_t;
BEGIN
    WITH RECURSIVE my_traversal(lvl, src, dst, visited, row_num)
    AS (
       SELECT 0 AS lvl,
              src,
              dst,
              hstore(dst, '1'),
              0::bigint AS row_num
              FROM store.graph
              WHERE NOT is_removed AND src = _src
       UNION ALL
       SELECT T.lvl + 1 AS lvl,
              G.src,
              G.dst,
              T.visited || (G.dst || '=>1')::hstore,
              ROW_NUMBER() OVER (PARTITION BY lvl) AS row_num
              FROM store.graph G
              JOIN my_traversal T ON G.src = T.dst
              WHERE NOT G.is_removed AND
                    NOT exist(T.visited, G.dst)
    )
    SELECT lvl, _src, dst, visited, row_num, array_length(akeys(visited), 1)
           FROM my_traversal
           ORDER BY lvl DESC, row_num DESC LIMIT 1
           INTO pathinfo_;

    RETURN pathinfo_;
END
$$
LANGUAGE PLPGSQL;
