# Airbnb Data Mart – SQL Project

## Project Overview
This project is a relational database system inspired by the Airbnb platform.  
It was developed as part of the course *Build a Data Mart in SQL* and focuses on designing, implementing and testing a normalized database using SQL.

The goal is to simulate a real-world booking platform by modeling users, properties, bookings, payments, reviews, messaging, support incidents and all interactions between different roles.

## Key Features
- **Multi‑role system** – Users can act as Guests, Hosts, Administrators or Customer Support agents.  
- **Property listings with full geolocation** – Country, city, neighbourhood and exact address.  
- **Availability calendar** – Each property has a date‑by‑date availability and price.  
- **Booking management** – Reservations with cancellation policies, guest count, total price and status.  
- **Payment recording with commission tracking** – Every payment stores amount, method, status and platform commission.  
- **Two‑way review system** – Guests review properties (and therefore hosts), hosts review guests.  
- **Messaging system** – Conversations between users, with threaded replies.  
- **Incident and support case tracking** – Incidents during a stay and general support cases, each with priority and status.  
- **Property verification** – Administrators must approve properties before they become visible.  
- **Fully normalized relational database (3NF)** – No redundancy, all dependencies are well structured.  
- **Implemented in MySQL** – Uses MySQL 8.0 syntax (AUTO_INCREMENT, ENUM, CHECK, etc.).


## Project Structure
sql/

├── create_tables.sql

├── insert_data.sql

└── test_queries.sql

docs/

├── requirements_erm_data_dictionary.pdf

├── installation_manual.pdf

└── abstract.pdf

images/

└── er_model.png

## Database Overview
- Total number of tables: 24
- Total number of records: 500+
- Total size: 0.94 MB
   - Data: 0.38 MB  
   - Indexes and metadata: 0.56 MB
- Normalized database design: 3NF

Includes:
- Users and roles (Guest, Host, Administrator, Customer Support)
- Property listings with geolocation (Country, City, Neighborhood, Address)
- Availability calendar and amenities
- Bookings and payments (with commissions)
- Two‑way reviews (property and guest)
- Messaging (conversations and threaded messages)
- Incident reports and support cases
- Property verification by administrators

## Technologies Used
- MySQL 8.0
- SQL (DDL & DML)
- Relational Database Design
- Entity Relationship Modeling (ERD)
- Database Normalization

## How to run the Project
1. Open your MySQL client (like MySQL Workbench or DBeaver)
2. Connect to your MySQL server
3. Run the file create_tables.sql to create the database and tables
4. Run insert_data.sql to populate the database with sample data
5. (Optional) Run test_queries.sql to test and explore the database
6. Verify the installation: 
USE AirbnbDB;
SHOW TABLES

## Database Design
The database was designed using an Entity Relationship Model (ERD), which defines:

- Entities and attributes
- Relationships between entities
- Primary and foreign keys
- Constraints to ensure data integrity (ex: CHECK for ratings between 1 and 5)

The system was normalized to avoid redundancy and ensure consistency.

* The full ER diagram can be found in the docs/ folder.

## Example Queries
The project includes test queries for:

- Booking analysis (occupancy, cancellations, revenue per property)
- Revenue calculations (including platform commissions)
- User and property insights (Superhost status, response rate, loyalty points)
- Data validation (orphan records, date consistency, referential integrity, row counts per table)

## Documentation
All detailed documentation is available in the docs/ folder:

- Requirements
- Entity Relationship Model
- Data Dictionary
- Installation Manual
- Project Abstract

## Author
Olga Ruiz. Data science student 

## Notes
The project includes 24 tables with realistic relationships.

Data has been  generated to simulate real-world scenarios.

The CancellationPolicy table has only 5 records which reflects real Airbnb cancellation options.

Total database size is under 1 MB, making it portable and quick to restore.

The design supports property verification by administrators, availability calendars per date and threaded messaging.
