# Vehicle Rental System — Database Schema

A concise overview of the PostgreSQL schema, structure, and core rules for a simple Vehicle Rental System. The schema is defined in [queries.sql](queries.sql).

## Overview
- Purpose: Track users, vehicles, and bookings with clear statuses and costs.
- Scope: Basic CRUD with referential integrity and enums for consistent states.
- Database: PostgreSQL (uses `ENUM` types and constraints).

## Technology & Requirements
- PostgreSQL 12+
- `psql` CLI or any PostgreSQL client

## Entity–Relationship Diagram (ERD)
```
 users                      vehicles
+-----------+             +----------------+
| user_id PK|---+      +--| vehicle_id PK  |
| name      |   |      |  | name           |
| email UQ  |   |      |  | type (ENUM)    |
| password  |   |      |  | registration UQ|
| phone     |   |      |  | model          |
| role ENUM |   |      |  | rental_price   |
+-----------+   |      |  | status (ENUM)  |
                 \     |  +----------------+
                  \    |
                   v   v
                   bookings
                 +-------------------------------+
                 | booking_id PK                 |
                 | user_id FK -> users.user_id   |
                 | vehicle_id FK -> vehicles.id  |
                 | start_date DATE               |
                 | end_date   DATE               |
                 | status ENUM                   |
                 | total_cost INT                |
                 +-------------------------------+
```

## Schema Components

### Enums
- `user_role`: `Admin`, `Customer`
- `vehicle_type`: `car`, `bike`, `truck`
- `vehicle_status`: `available`, `rented`, `maintenance`
- `booking_status`: `pending`, `confirmed`, `completed`, `cancelled`


### Tables

#### `users`
- `user_id SERIAL PK`
- `name VARCHAR(50) NOT NULL`
- `email VARCHAR(100) NOT NULL UNIQUE`
- `password VARCHAR(255)`
- `phone VARCHAR(20) NOT NULL`
- `role user_role NOT NULL`

#### `vehicles`
- `vehicle_id SERIAL PK`
- `name VARCHAR(50) NOT NULL`
- `type vehicle_type NOT NULL`
- `registration_number VARCHAR(50) NOT NULL UNIQUE`
- `model VARCHAR(50) NOT NULL`
- `rental_price INT NOT NULL`
- `status vehicle_status NOT NULL DEFAULT 'available'`

> The column was renamed from `vehicle_name` to `name` via `ALTER TABLE`.

#### `bookings`
- `booking_id SERIAL PK`
- `user_id INT REFERENCES users(user_id) ON DELETE CASCADE`
- `vehicle_id INT REFERENCES vehicles(vehicle_id) ON DELETE RESTRICT`
- `start_date DATE NOT NULL`
- `end_date DATE NOT NULL` with `CHECK (start_date < end_date)`
- `status booking_status NOT NULL DEFAULT 'pending'`
- `total_cost INT NOT NULL`

### Relationships & Rules
- A `user` can have many `bookings` (1:N). Deleting a user cascades delete of their bookings.
- A `vehicle` can have many `bookings` (1:N). Deleting a vehicle is restricted if bookings exist.
- Dates must be valid (`start_date < end_date`).
- Vehicle, booking, and user states are constrained by ENUMs for consistency.

## Seed Data
Starter rows are included in [queries.sql](queries.sql) for:
- `users`: Alice, Bob, Charlie
- `vehicles`: Toyota Corolla, Honda Civic, Yamaha R15, Ford F-150
- `bookings`: several sample bookings across users/vehicles

## Included Queries
- 1. Join bookings to users and vehicles (INNER JOIN): list booking info with customer and vehicle names.
- 2. Find vehicles never booked (NOT EXISTS).
- 3. List available cars (WHERE on `status` and `type`).
- 4. Count bookings per vehicle and filter by count > 2 (GROUP BY / HAVING).

## Setup & Usage
1. Create a database and connect:
   ```bash
   createdb vehicle_rental
   psql vehicle_rental
   ```
2. Run the schema and seed data:
   ```bash
   psql -d vehicle_rental -f queries.sql
   ```
3. Explore:
   ```sql
   -- Preview data
   SELECT * FROM users;
   SELECT * FROM vehicles;
   SELECT * FROM bookings;

   -- JOIN: Retrieve booking information using inner join
   -- Procedure: Joined users and vehicles table with bookings table based on foreign keys of vehicles and users table

   select b.booking_id, u.name as customer_name, v.name as vehicle_name, b.start_date, b.end_date, b.status from bookings b
    inner join users u using (user_id)
    inner join vehicles v using (vehicle_id);

   -- EXISTS: Find all vehicles that never booked
   -- Procedure: Used sub query and checked if the vehicle found on the bookings table or not using not exists clause

   select * from vehicles v
    where  not exists (
    select * from bookings b 
    where b.vehicle_id = v.vehicle_id
    )

   -- WHERE: Retrieve all available vehicles of a specific type (e.g. cars).
   SELECT * FROM vehicles WHERE status = 'available' AND type = 'car';

   -- GROUP BY and HAVING:  Find the total number of bookings for each vehicle and display only those who have more than 2 bookings record

   -- Procedure: At first I have join the booking and vehicles tables and then grouped the resulting table based on the vehicle name. Finally, retrieved only those vehicle whos count is more than 2 using HAVING clasue and count function
   select v.name as vehicle_name, count(*) as total_bookings from bookings b
    inner join vehicles v using (vehicle_id)
    group by v.name having count(*) > 2;

   ```


## File Reference
- Full schema and queries: [queries.sql](queries.sql)
- Entity Relationships Diagram (ERD): [ERD](https://lucid.app/lucidchart/732fd5ab-dff4-48ce-931b-8d912e7d9951/edit?beaconFlowId=6E0155FE924C7FF5&invitationId=inv_992bc49f-5354-416a-bdfd-d64b497184f2&page=0_0#)
