CREATE TABLE issue622 (id serial8 not null primary key, oid bigint, by_trigger bool);
CREATE OR REPLACE FUNCTION update_trigger () RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    IF (round(random())::int)::boolean THEN
        -- recurse.  There's a chance we could end up doing this forever, but seems unlikely
        -- don't feel like making this smarter
        UPDATE issue622 SET by_trigger = true WHERE id = OLD.id;
    END IF;
    RETURN NEW;
END
$$;

CREATE TRIGGER update_trigger AFTER UPDATE ON issue622 FOR EACH ROW EXECUTE FUNCTION update_trigger();

INSERT INTO issue622 (oid) SELECT gs FROM generate_series(1, 30000) gs;
CREATE INDEX idxissue622 ON issue622 USING zombodb ((issue622.*));

UPDATE issue622 SET id = id;

DROP TABLE issue622;
DROP FUNCTION update_trigger();