CREATE OR REPLACE FUNCTION smp()
RETURNS SETOF edges
AS $$
DECLARE
    n_unpaired_ INTEGER;      -- number of unpaired in A

    person_a_ INTEGER;        -- person 'a'
    person_b_ INTEGER;        -- person 'b'
    edge_ INTEGER;            -- matched pair

    index_old_ INTEGER;       -- preference priority
    index_new_ INTEGER;       -- preference priority

    n_preferences_ INTEGER;   -- number of preferences remaining for person_a_
BEGIN
    -- Initialize A_unpaired with all distinct proposors (A).
    INSERT INTO A_unpaired(a) SELECT DISTINCT(src) FROM A ORDER BY src;
    
    -- Do rounds
    WHILE TRUE LOOP
       -- Check if there are any unpaired proposors. Exit if none.
       SELECT COUNT(*) FROM A_unpaired INTO n_unpaired_;
       IF n_unpaired_ = 0 THEN
             EXIT;
       END IF;

       -- Remove next person 'a' from A_unpaired.
       DELETE FROM A_unpaired WHERE id IN (
              SELECT id FROM A_unpaired ORDER BY id LIMIT 1
       ) RETURNING a INTO person_a_;

       -- Fetch next preference of person_a_.
       SELECT dst FROM A WHERE src = person_a_ AND NOT is_processed
              ORDER BY id
              LIMIT 1 INTO person_b_;
              
       -- Mark this preference of person_a_ as already processed.
       UPDATE A SET is_processed = TRUE WHERE src = person_a_ AND dst = person_b_;

       IF person_b_ IS NOT NULL THEN
           -- Check if person_b_ is already paired.
           SELECT dst FROM edges WHERE src = person_b_ INTO edge_;  
           
           IF NOT FOUND THEN
              -- person_b_ had no pair, make a - b pair.
              INSERT INTO edges(src, dst) VALUES(person_b_, person_a_);
           ELSE
              -- person_b_ already has a pair, check if they
              -- prefer this person_a_ over their current pair.
              SELECT id FROM B WHERE src = person_b_ AND dst = edge_ INTO index_old_;
              SELECT id FROM B WHERE src = person_b_ AND dst = person_a_ INTO index_new_;

              IF index_new_ < index_old_ THEN
                 -- Found a better match, remove old pair and pair person_b_ with person_a_.
                 DELETE FROM edges WHERE src = person_b_;
                 INSERT INTO edges(src, dst) VALUES(person_b_, person_a_);
                 -- If previous paired 'a' has other preferences,
                 -- move it back to the pool of unpaired.
                 SELECT COUNT(*) FROM A WHERE src = edge_
                        AND NOT is_processed INTO n_preferences_;
                    
                 IF n_preferences_ > 0 THEN
                    INSERT INTO A_unpaired (a) VALUES(edge_);
                 END IF;
              ELSE
                 -- No match, but if person_a_ has other preferences, move it back
                 -- to the pool of unpaired.
                 SELECT COUNT(*) FROM A WHERE src = person_a_
                        AND NOT is_processed INTO n_preferences_;
                        
                 IF n_preferences_ > 0 THEN
                    INSERT INTO A_unpaired (a) VALUES(person_a_);
                 END IF;
              END IF;
           END IF;
       END IF;

       END LOOP;

    -- Return all pairs.
    RETURN QUERY SELECT dst, src FROM edges ORDER BY dst;
END
$$
LANGUAGE plpgsql;
