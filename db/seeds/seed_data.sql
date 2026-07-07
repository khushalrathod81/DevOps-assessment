-- Seed data for hotel_bookings and booking_events
-- Generates 100 bookings with various organizations, cities, and statuses

INSERT INTO hotel_bookings (org_id, hotel_id, city, checkin_date, checkout_date, amount, status, created_at)
SELECT
    -- Generate organization IDs (4 different orgs)
    CASE (row_number() OVER ()) % 4
        WHEN 0 THEN '550e8400-e29b-41d4-a716-446655440000'::UUID
        WHEN 1 THEN '550e8400-e29b-41d4-a716-446655440001'::UUID
        WHEN 2 THEN '550e8400-e29b-41d4-a716-446655440002'::UUID
        ELSE '550e8400-e29b-41d4-a716-446655440003'::UUID
    END AS org_id,
    -- Generate hotel IDs
    'HOTEL_' || LPAD(((row_number() OVER ()) % 20 + 1)::text, 3, '0') AS hotel_id,
    -- Generate cities (Delhi gets more records for test query)
    CASE (row_number() OVER ()) % 10
        WHEN 0 THEN 'delhi'
        WHEN 1 THEN 'delhi'
        WHEN 2 THEN 'delhi'
        WHEN 3 THEN 'delhi'
        WHEN 4 THEN 'mumbai'
        WHEN 5 THEN 'bangalore'
        WHEN 6 THEN 'hyderabad'
        WHEN 7 THEN 'pune'
        WHEN 8 THEN 'jaipur'
        ELSE 'delhi'
    END AS city,
    -- Generate check-in date (last 30 days)
    CURRENT_DATE - (random() * 30)::int AS checkin_date,
    -- Generate check-out date (2-5 days after check-in)
    CURRENT_DATE - (random() * 30)::int + (2 + random() * 3)::int AS checkout_date,
    -- Generate random amounts (1000-50000)
    ROUND((1000 + random() * 49000)::numeric, 2) AS amount,
    -- Generate status
    CASE (row_number() OVER ()) % 3
        WHEN 0 THEN 'confirmed'
        WHEN 1 THEN 'cancelled'
        ELSE 'pending'
    END AS status,
    -- Generate created_at (last 60 days)
    CURRENT_TIMESTAMP - (INTERVAL '1 second' * (random() * 86400 * 60)::int) AS created_at
FROM generate_series(1, 100) AS t(n);

-- Seed booking_events for the first 80 bookings
INSERT INTO booking_events (booking_id, event_type, payload, created_at)
SELECT
    b.id AS booking_id,
    CASE s
        WHEN 1 THEN 'created'
        WHEN 2 THEN 'confirmed'
        WHEN 3 THEN 'checked_in'
        WHEN 4 THEN 'checked_out'
        ELSE 'cancelled'
    END AS event_type,
    jsonb_build_object(
        'booking_id', b.id::text,
        'previous_status', b.status,
        'notes', 'Event sequence ' || s::text
    ) AS payload,
    b.created_at + (INTERVAL '1 hour' * s) AS created_at
FROM hotel_bookings b
CROSS JOIN generate_series(1, 4) AS s(s)
WHERE (row_number() OVER (ORDER BY b.id))::int <= 80
ORDER BY b.id, s;
