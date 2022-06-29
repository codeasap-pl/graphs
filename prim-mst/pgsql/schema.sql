CREATE TABLE edges (
       edge_id SERIAL PRIMARY KEY,
       src INTEGER NOT NULL,
       dst INTEGER NOT NULL,
       cost INTEGER NOT NULL
);

CREATE TABLE prim_priority_queue(
       pq_id SERIAL PRIMARY KEY,
       src INTEGER NOT NULL,
       cost INTEGER NOT NULL
);

CREATE TABLE prim_spanning_tree(
       id SERIAL PRIMARY KEY,
       u INTEGER NOT NULL,
       v INTEGER NOT NULL CHECK(v != u),
       cost INTEGER NOT NULL
);

CREATE UNIQUE INDEX prim_spanning_tree_uidx ON prim_spanning_tree(u, v); 


-- INSERT INTO edges(src, dst, cost) VALUES
--        (0, 1, 1), (0, 2, 2), (0, 3, 1), (0, 4, 1), (0, 5, 2), (0, 6, 1),
--        (1, 0, 1), (1, 2, 2), (1, 6, 2),
--        (2, 0, 2), (2, 1, 2), (2, 3, 1),
--        (3, 0, 1), (3, 2, 1), (3, 4, 2),
--        (4, 0, 1), (4, 3, 2), (4, 5, 2),
--        (5, 0, 2), (5, 4, 2), (5, 6, 1),
--        (6, 0, 1), (6, 2, 2), (6, 5, 1);

INSERT INTO edges(src, dst, cost) VALUES
    (0, 1,4), (0, 2,1), (0, 3,5),
    (1, 0,4), (1, 3,2), (1, 4,3), (1, 5,3),
    (2, 0,1), (2, 3,2), (2, 4,8),
    (3, 0,5), (3, 1,2), (3, 2,2), (3, 4,1),
    (4, 1, 3), (4, 2,8), (4, 3,1), (4, 5,3),
    (5, 1,3), (5, 4,3);
