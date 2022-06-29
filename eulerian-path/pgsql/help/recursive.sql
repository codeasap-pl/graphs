EXPLAIN ANALYZE
WITH RECURSIVE my_traversal(lvl, dst, visited, row_num)
AS (
   SELECT 0 AS lvl,
          dst,
          hstore(src, '1'),
          0::bigint AS row_num
          FROM store.graph
          WHERE NOT is_removed AND src = 'E'
   UNION
   SELECT T.lvl + 1 AS lvl,
          G.dst,
          visited || (G.src || '=>1')::hstore,
          ROW_NUMBER() OVER (PARTITION BY lvl) AS row_num
          FROM store.graph G
          JOIN my_traversal T ON G.src = T.dst
          WHERE NOT G.is_removed AND
                NOT exist(T.visited, G.src)
)
SELECT * FROM my_traversal;
