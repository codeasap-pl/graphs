CREATE EXTENSION IF NOT EXISTS hstore;

CREATE SCHEMA IF NOT EXISTS store;  -- data
CREATE SCHEMA IF NOT EXISTS graph;  -- api


CREATE TABLE IF NOT EXISTS store.graph (
       edge_id SERIAL PRIMARY KEY,
       src TEXT NOT NULL,
       dst TEXT NOT NULL,
       is_removed BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE UNIQUE INDEX graph_uidx ON store.graph(src, dst);


CREATE OR REPLACE FUNCTION graph.add_edge(_src TEXT, _dst TEXT)
RETURNS SETOF store.graph
AS $$
DECLARE
   R store.graph;
BEGIN
    -- RAISE NOTICE 'Adding edge: (% <-> %)', _src, _dst;

    INSERT INTO store.graph(src, dst) VALUES(_src, _dst)
           ON CONFLICT(src, dst) DO UPDATE SET is_removed = FALSE
           RETURNING * INTO R;

    RETURN NEXT R;

    INSERT INTO store.graph(src, dst) VALUES(_dst, _src)
           ON CONFLICT(src, dst) DO UPDATE SET is_removed = FALSE
           RETURNING * INTO R;

    RETURN NEXT R;
END
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION graph.remove_edge(_src TEXT, _dst TEXT)
RETURNS VOID
AS $$
BEGIN
    -- RAISE NOTICE 'Marking edge removed: (% <-> %)', _src, _dst;

    UPDATE store.graph SET is_removed = TRUE
           WHERE (
                 src = _src AND dst = _dst
                 OR
                 src = _dst AND dst = _src
           );
END
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION graph.assert_eulerian()
RETURNS VOID
AS $$
DECLARE
    is_eulerian_ BOOLEAN;
BEGIN
    WITH stmt_get_odd AS (
         SELECT COUNT(*)
            FROM store.graph
            WHERE NOT is_removed
            GROUP BY src
            HAVING ARRAY_LENGTH(ARRAY_AGG(dst), 1) % 2 != 0
    )
    SELECT COUNT(*) = ANY(ARRAY[0, 2]) INTO is_eulerian_ FROM stmt_get_odd;

    IF NOT is_eulerian_ THEN
       RAISE EXCEPTION 'Not Eulerian';
    END IF;
END
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION graph.get_pathlen(_src TEXT)
RETURNS INTEGER
AS $$
DECLARE
    pathlen_ INTEGER = 1;
BEGIN
    WITH RECURSIVE my_traversal(dst, visited)
    AS (
       SELECT dst,
              ARRAY[src]::TEXT[]
              FROM store.graph
              WHERE NOT is_removed AND src = _src
       UNION
       SELECT G.dst,
              array_append(T.visited, G.src)
              FROM store.graph G
              JOIN my_traversal T ON G.src = T.dst
              WHERE NOT G.is_removed AND NOT G.src=ANY(T.visited)
    )
    SELECT COUNT(DISTINCT(dst))
           FROM my_traversal
           INTO pathlen_;

    RETURN pathlen_;
END
$$
LANGUAGE PLPGSQL;



CREATE OR REPLACE FUNCTION graph.is_edge_valid(_src TEXT, _dst TEXT)
RETURNS BOOLEAN
AS $$
DECLARE
    vn_ INTEGER = 0;
    un_ INTEGER = 0;
BEGIN
   SELECT count(*) FROM store.graph
          WHERE NOT is_removed AND src = _src
          GROUP BY src
          INTO vn_;

   IF vn_ = 1 THEN
      RETURN TRUE;
   END IF;

   SELECT graph.get_pathlen(_src) INTO vn_;
   PERFORM graph.remove_edge(_src, _dst);

   SELECT graph.get_pathlen(_dst) INTO un_;
   PERFORM graph.add_edge(_src, _dst);

   RETURN vn_ <= un_;
END
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION graph.traverse(
       _v TEXT,
       _paths TEXT[])
RETURNS TEXT[]
AS $$
DECLARE
    u_ TEXT;
    is_valid_ BOOLEAN = FALSE;
    edge_src_dst_ TEXT;
    edge_dst_src_ TEXT;
BEGIN
    FOR u_ IN SELECT dst FROM store.graph
                     WHERE NOT is_removed AND src = _v
    LOOP
        SELECT * FROM graph.is_edge_valid(_v, u_) INTO is_valid_;
        IF is_valid_ THEN
           edge_src_dst_ = (_v || '-' || u_);
           edge_dst_src_ = (u_ || '-' || _v);
           
           IF (edge_src_dst_ = ANY(_paths) OR edge_dst_src_ = ANY(_paths))
           THEN
               RETURN _paths;
           END IF;

           SELECT * FROM array_append(_paths, _v || '-' || u_) INTO _paths;

           PERFORM graph.remove_edge(_v, u_);
           
           SELECT * FROM graph.traverse(u_, _paths) INTO _paths;
        END IF;
    END LOOP;

    RETURN _paths;
END
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION find_eulerian_path()
RETURNS SETOF TEXT
AS $$
DECLARE
    v_ TEXT;
    path_ TEXT[] = ARRAY[]::TEXT[];
BEGIN
    SELECT src,
           array_length(array_agg(dst), 1) AS degree
        FROM store.graph
        WHERE NOT is_removed
        GROUP BY src HAVING array_length(array_agg(dst), 1) % 2 != 0
        ORDER BY degree DESC
        LIMIT 1
        INTO v_;

    IF FOUND THEN
        RAISE NOTICE 'Start vertex: %', v_;
        SELECT * FROM graph.traverse(v_, path_) INTO path_;
    END IF;

    RETURN QUERY SELECT UNNEST(path_);
END
$$
LANGUAGE PLPGSQL;
