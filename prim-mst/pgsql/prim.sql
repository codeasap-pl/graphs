CREATE FUNCTION prim(src_ INTEGER DEFAULT 0)
RETURNS INTEGER
AS $$
DECLARE
    min_span_tree_cost INTEGER = 0;

    dst_ INTEGER;
    cost_ INTEGER;

    next_ INTEGER; -- next node (from priority queue)

    pq_cost_ INTEGER;
    pq_id_ INTEGER;
    pq_len_ INTEGER;

    is_added_ BOOLEAN;
    added_ INTEGER[] = ARRAY[]::INTEGER[];
BEGIN
    TRUNCATE prim_priority_queue;
    TRUNCATE prim_spanning_tree;

    -- Start vertex.
    INSERT INTO prim_priority_queue(src, cost) VALUES(src_, 0);

    WHILE TRUE
    LOOP
        -- Check priority_queue length. Exit if empty.
        SELECT count(*) FROM prim_priority_queue INTO pq_len_;
        IF pq_len_ = 0 THEN
           EXIT;
        END IF;

        -- Fetch next element from priority queue.
        SELECT pq_id, src, cost FROM prim_priority_queue ORDER BY cost ASC LIMIT 1
               INTO pq_id_, next_, pq_cost_;

        -- Remove element from priority queue.
        DELETE FROM prim_priority_queue WHERE pq_id = pq_id_; 

        -- Was node already added?
        is_added_ := (next_ = ANY(added_)); 

        IF NOT is_added_ THEN
            -- Node was not added. Update the cost and mark node added.
            min_span_tree_cost := min_span_tree_cost + pq_cost_;
            added_ := array_append(added_, next_);

            IF src_ != next_ THEN
                INSERT INTO prim_spanning_tree(u, v, cost) VALUES(src_, next_, pq_cost_);
            END IF;

            FOR dst_, cost_ IN
                SELECT dst, cost FROM edges WHERE src = next_
            LOOP
                is_added_ := (dst_ = ANY(added_));
                IF NOT is_added_ THEN
                   INSERT INTO prim_priority_queue(src, cost) VALUES(dst_, cost_);
                END IF;
            END LOOP;

            src_ := next_;
        END IF;
    END LOOP;

    RETURN min_span_tree_cost;
END
$$
LANGUAGE plpgsql;
-- ########################################################################
SELECT * FROM prim(2);
SELECT * FROM prim_spanning_tree; -- cost
SELECT SUM(cost) FROM prim_spanning_tree; -- MST
