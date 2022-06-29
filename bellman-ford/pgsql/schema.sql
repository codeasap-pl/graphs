CREATE TABLE graph (
       edge_id SERIAL PRIMARY KEY,
       src INTEGER NOT NULL,
       dst INTEGER NOT NULL,
       weight NUMERIC(12,3) NOT NULL
);


CREATE TABLE _bf_distances (
       v INTEGER,
       distance NUMERIC NOT NULL
);


CREATE TABLE _bf_predecessors (
       v INTEGER,
       prev NUMERIC
);
