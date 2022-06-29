\i schema.sql
\i variants/get_pathlen_recursive.sql

-- envelope
SELECT * FROM graph.add_edge('A', 'B');
SELECT * FROM graph.add_edge('A', 'C');
SELECT * FROM graph.add_edge('B', 'A');
SELECT * FROM graph.add_edge('B', 'C');
SELECT * FROM graph.add_edge('B', 'D');
SELECT * FROM graph.add_edge('B', 'E');
SELECT * FROM graph.add_edge('C', 'A');
SELECT * FROM graph.add_edge('C', 'B');
SELECT * FROM graph.add_edge('C', 'D');
SELECT * FROM graph.add_edge('C', 'E');
SELECT * FROM graph.add_edge('D', 'B');
SELECT * FROM graph.add_edge('D', 'C');
SELECT * FROM graph.add_edge('D', 'E');
SELECT * FROM graph.add_edge('E', 'B');
SELECT * FROM graph.add_edge('E', 'C');
SELECT * FROM graph.add_edge('E', 'D');

-- ribbon
SELECT * FROM graph.add_edge('E', 'F');

-- Testing: not Eulerian.
-- SELECT * FROM graph.add_edge('A', 'F');
-- SELECT * FROM graph.add_edge('B', 'F');

------------------------------------------------------------------------

SELECT G.src, array_agg(G.dst ORDER BY G.dst) AS dst FROM store.graph G
       WHERE NOT G.is_removed
       GROUP BY G.src ORDER BY G.src;


SELECT graph.assert_eulerian();

-- SELECT graph.get_pathlen('A') = 6;
-- SELECT graph.get_pathlen('B') = 6;
-- SELECT graph.get_pathlen('C') = 6;
-- SELECT graph.get_pathlen('D') = 6;
-- SELECT graph.get_pathlen('E') = 6;
-- SELECT graph.get_pathlen('F') = 6;

-- SELECT graph.get_pathlen_hstore('A');
-- SELECT graph.get_pathlen_hstore('B');
-- SELECT graph.get_pathlen_hstore('C');
-- SELECT graph.get_pathlen_hstore('D');
-- SELECT graph.get_pathlen_hstore('E');
-- SELECT graph.get_pathlen_hstore('F');


------------------------------------------------------------------------
-- # FIXME
-- SELECT graph.get_pathlen_hstore_fixme_1('E');
-- SELECT graph.get_pathlen_hstore_fixme_1('F');

-- SELECT graph.get_pathlen_hstore_fixme_2('E');
-- SELECT graph.get_pathlen_hstore_fixme_2('F');
------------------------------------------------------------------------


-- SELECT graph.get_pathlen_recursive('A') = 6;
-- SELECT graph.get_pathlen_recursive('B') = 6;
-- SELECT graph.get_pathlen_recursive('C') = 6;
-- SELECT graph.get_pathlen_recursive('D') = 6;
-- SELECT graph.get_pathlen_recursive('E');
-- SELECT graph.get_pathlen_recursive('F');

SELECT * FROM find_eulerian_path();
