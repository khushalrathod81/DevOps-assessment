# Database Setup

This directory contains Docker Compose setup and database migrations for local development.

## Quick Start

### Start PostgreSQL

```bash
cd db
docker compose up -d
```

### Initialize Database

```bash
# Wait for database to be ready (10-15 seconds)
sleep 15

# Run migrations
docker compose exec postgres psql -U postgres -d devops_assessment < migrations/001_create_tables.sql

# Create indexes
docker compose exec postgres psql -U postgres -d devops_assessment < migrations/002_create_indexes.sql

# Seed data
docker compose exec postgres psql -U postgres -d devops_assessment < seeds/seed_data.sql
```

### Verify Setup

```bash
# Connect to database
docker compose exec postgres psql -U postgres -d devops_assessment

# Check tables
\dt

# Count records
SELECT 'hotel_bookings' as table, COUNT(*) FROM hotel_bookings
UNION ALL
SELECT 'booking_events', COUNT(*) FROM booking_events;

# Exit
\q
```

## Schema

### hotel_bookings
- `id` (UUID): Primary key
- `org_id` (UUID): Organization ID
- `hotel_id` (VARCHAR): Hotel identifier
- `city` (VARCHAR): City name
- `checkin_date` (DATE): Check-in date
- `checkout_date` (DATE): Check-out date
- `amount` (NUMERIC): Booking amount
- `status` (VARCHAR): Booking status (confirmed, cancelled, pending)
- `created_at` (TIMESTAMP): Creation timestamp

### booking_events
- `id` (BIGSERIAL): Primary key
- `booking_id` (UUID): Foreign key to hotel_bookings
- `event_type` (VARCHAR): Event type (created, confirmed, cancelled, checked_in, checked_out)
- `payload` (JSONB): Event payload
- `created_at` (TIMESTAMP): Creation timestamp

## Indexes

- `idx_bookings_city_created_at`: Composite index on (city, created_at) for query optimization
- `idx_bookings_org_id`: Index on org_id for organization queries
- `idx_bookings_status`: Index on status for status queries
- `idx_events_booking_id`: Index on booking_id for event queries

## Seed Data

The seed script creates:
- 100 hotel bookings across multiple cities
- Multiple organizations
- Multiple booking statuses
- Multiple booking events

## Connection

- **Host**: localhost
- **Port**: 5432
- **User**: postgres
- **Password**: postgres
- **Database**: devops_assessment

## Cleanup

```bash
# Stop containers
docker compose down

# Remove volumes
docker compose down -v
```
