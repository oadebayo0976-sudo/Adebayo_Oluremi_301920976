-- Run after demo.py has committed order 101.
BEGIN;
INSERT INTO deliveries VALUES (501, 101, 'DEMO-501');
INSERT INTO delivery_updates VALUES
    (1, 501, 'Preparing', timestamptz '2026-11-14 08:00+00'),
    (2, 501, 'Dispatched', timestamptz '2026-11-14 09:00+00'),
    (3, 501, 'Out for delivery', timestamptz '2026-11-14 11:00+00'),
    (4, 501, 'Delivered', timestamptz '2026-11-14 14:00+00');
COMMIT;

DO $$
BEGIN
    BEGIN
        INSERT INTO deliveries VALUES (502, 101, 'DEMO-502');
        RAISE EXCEPTION 'Second delivery was accepted';
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'PASS: a second delivery for order 101 was rejected';
    END;
    BEGIN
        INSERT INTO delivery_updates VALUES (5, 999, 'Delivered', now());
        RAISE EXCEPTION 'Update for missing delivery was accepted';
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE 'PASS: an update for an unknown delivery was rejected';
    END;
    BEGIN
        INSERT INTO delivery_updates VALUES (5, 501, 'Unknown', now());
        RAISE EXCEPTION 'Invalid status was accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'PASS: an unsupported delivery status was rejected';
    END;
    IF (SELECT count(*) FROM delivery_updates WHERE delivery_id = 501) <> 4 OR
       (SELECT status FROM delivery_updates WHERE delivery_id = 501
        ORDER BY updated_at DESC LIMIT 1) IS DISTINCT FROM 'Delivered' THEN
        RAISE EXCEPTION 'Expected four updates ending in Delivered';
    END IF;
END $$;
