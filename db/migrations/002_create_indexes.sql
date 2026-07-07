-- Create indexes for query optimization

-- Composite index on city and created_at for the optimized query
CREATE INDEX IF NOT EXISTS idx_bookings_city_created_at ON hotel_bookings(city, created_at DESC);

-- Index on org_id for organization queries
CREATE INDEX IF NOT EXISTS idx_bookings_org_id ON hotel_bookings(org_id);

-- Index on status for status-based queries
CREATE INDEX IF NOT EXISTS idx_bookings_status ON hotel_bookings(status);

-- Index on booking_id for event queries
CREATE INDEX IF NOT EXISTS idx_events_booking_id ON booking_events(booking_id);

-- Index on event_type for event-type queries
CREATE INDEX IF NOT EXISTS idx_events_event_type ON booking_events(event_type);

-- Composite index on booking_id and created_at for time-series queries
CREATE INDEX IF NOT EXISTS idx_events_booking_created ON booking_events(booking_id, created_at DESC);
