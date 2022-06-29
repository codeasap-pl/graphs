CREATE TYPE bf_result_t AS(
       v INTEGER,
       distance NUMERIC
);


CREATE OR REPLACE FUNCTION bellman_ford(src_ INTEGER)
RETURNS SETOF bf_result_t
AS $$
DECLARE
    tmp_ INTEGER;  -- used only for iterating vertices
    u_ INTEGER;    -- src node during iteration
    v_ INTEGER;    -- dst node during iteration
    w_ NUMERIC;    -- weight/cost of a given node

    dv_ NUMERIC;   -- distance stored for v
    du_ NUMERIC;   -- distance stored for u
BEGIN
    -- Initialization:
    --   select all vertices (array of arrays[src, node]),
	--   create a single column and select distinct elements
    FOR tmp_ IN SELECT DISTINCT(UNNEST(array_agg(ARRAY[src, dst]))) FROM graph
    LOOP
       INSERT INTO _bf_distances VALUES(tmp_, 2147483647);       -- set max int
       INSERT INTO _bf_predecessors VALUES(tmp_, NULL);                  -- set NULL for current vertex
    END LOOP;

    UPDATE _bf_distances SET distance = 0 WHERE v = src_;     -- start distance

    -- ALGORITHM:
    -- for all vertices
    FOR tmp_ IN SELECT DISTINCT(UNNEST(array_agg(ARRAY[src, dst])))
           FROM graph
    LOOP
        -- for all edges
        FOR u_, v_, w_ IN SELECT src, dst, weight  FROM graph
        LOOP
                -- RELAXATION
                SELECT distance FROM _bf_distances WHERE v = v_ INTO dv_;
                SELECT distance FROM _bf_distances WHERE v = u_ INTO du_;
                IF dv_ > du_ + w_ THEN
                   -- update distance for current v
                   UPDATE _bf_distances SET distance = du_ + w_ WHERE v = v_;
                   -- set predecessor of v to u
                   UPDATE _bf_predecessors SET prev = u_ WHERE v = v_;
                END IF;
        END LOOP;
    END LOOP;

    -- Check cycles
    FOR u_, v_, w_ IN SELECT src, dst, weight  FROM graph
    LOOP
        SELECT distance FROM _bf_distances WHERE v = v_ INTO dv_;
        SELECT distance FROM _bf_distances WHERE v = u_ INTO du_;
        IF dv_ > du_ + w_ THEN
           RETURN;  -- if cycle was found, don't return any result
        END IF;
    END LOOP;

    RETURN QUERY SELECT * FROM _bf_distances ORDER BY v;
END
$$
LANGUAGE plpgsql;
