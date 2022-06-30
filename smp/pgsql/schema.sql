CREATE TABLE A (
       id SERIAL PRIMARY KEY,
       src INTEGER NOT NULL, 
       dst INTEGER NOT NULL,
       is_processed BOOLEAN DEFAULT FALSE
);

CREATE UNIQUE INDEX ON A(src, dst);


CREATE TABLE B (
       id SERIAL PRIMARY KEY,
       src INTEGER NOT NULL, 
       dst INTEGER NOT NULL
);

CREATE UNIQUE INDEX ON B(src, dst);


CREATE TABLE edges (
       src INTEGER NOT NULL,
       dst INTEGER NOT NULL
);

CREATE UNIQUE INDEX ON edges(src, dst);


CREATE TABLE A_unpaired (
       id SERIAL PRIMARY KEY,
       a INTEGER NOT NULL
);
