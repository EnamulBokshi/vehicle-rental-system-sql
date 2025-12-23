/*
Vehicle Rental System
Database Schema and Queries
*/

-- Creating the database
create database vehicle_rental_system;

-- Creating  tables for Vehicle Rental System

-- Necessary enums 
create type user_role as enum ('admin', 'customer', 'Admin', 'Customer');
create type vehicle_type as enum ('car', 'bike', 'truck');
create type vehicle_status as enum ('available', 'rented', 'maintenance') ;
create type booking_status as enum ('pending', 'confirmed', 'completed', 'cancelled');

-- Creating users table
create table users(
  user_id serial primary key,
  name varchar(50) not null,
  email varchar(100) not null unique,
  password varchar(255),
  phone varchar(20) not null,
  role user_role not null
);

-- Creating vehicles table
create table vehicles(
  vehicle_id serial primary key,
  vehicle_name varchar(50) not null,
  type vehicle_type not null,
  registration_number varchar(50) unique not null,
  model varchar(50) not null,
  rental_price int not null,
  status vehicle_status not null default 'available'
);

-- Creating bookings table
create table bookings(
  booking_id serial primary key,
  user_id int references users(user_id) on delete cascade,
  vehicle_id int references vehicles(vehicle_id) on delete restrict,
  start_date date not null,
  end_date date not null check (start_date<end_date),
  status booking_status not null default 'pending',
  total_cost int not null
);

-- altering 
alter table vehicles
  rename column vehicle_name to name;


-- Seeding Data

-- User table
insert into users(name, email, phone, role) values('Alice', 'alice@example.com','1234567890','Customer'),
('Bob', 'bob@example.com','0987654321','Admin'),
('Charlie', 'charlie@example.com','1122334455','Customer');



-- Vehicles Table
INSERT INTO vehicles 
(name, type, model, registration_number, rental_price, status)
VALUES
('Toyota Corolla', 'car', '2022', 'ABC-123', 50, 'available'),
('Honda Civic', 'car', '2021', 'DEF-456', 60, 'rented'),
('Yamaha R15', 'bike', '2023', 'GHI-789', 30, 'available'),
('Ford F-150', 'truck', '2020', 'JKL-012', 100, 'maintenance');


INSERT INTO bookings
(user_id, vehicle_id, start_date, end_date, status, total_cost)
VALUES
( 1, 2, '2023-10-01', '2023-10-05', 'completed', 240),
( 1, 2, '2023-11-01', '2023-11-03', 'completed', 120),
( 3, 2, '2023-12-01', '2023-12-02', 'confirmed', 60),
( 1, 1, '2023-12-10', '2023-12-12', 'pending', 100);



/*
Query 1: JOIN
Retrieve booking information along with:

Customer name
Vehicle name
Concepts used: INNER JOIN
*/

-- solution of query-1
select b.booking_id, u.name as customer_name, v.name as vehicle_name, b.start_date, b.end_date, b.status from bookings b
inner join users u using (user_id)
inner join vehicles v using (vehicle_id);

/*
Query 2: EXISTS
Find all vehicles that have never been booked.

Concepts used: NOT EXISTS
*/

-- Solution of query-2
select * from vehicles v
where  not exists (
  select * from bookings b 
  where b.vehicle_id = v.vehicle_id
)


/*

Query 3: WHERE
Requirement: Retrieve all available vehicles of a specific type (e.g. cars).

*/

-- Solution of query-3
select * from vehicles
where status = 'available' and type = 'car';

/*
Query 4: GROUP BY and HAVING
Requirement: Find the total number of bookings for each vehicle and display only those vehicles that have more than 2 bookings.
*/

-- Solution of query-4
select v.name as vehicle_name, count(*) as total_bookings from bookings b
inner join vehicles v using (vehicle_id)
group by v.name having count(*) > 2;





