-- This script sets up the main tables for the Airbnb system
-- It covers users, properties, bookings, reviews and support entities
-- The tables are connected with foreign keys to mantain data integrity

-- Create the database if it does not exist
CREATE DATABASE IF NOT EXISTS AirbnbDB;
USE AirbnbDB;


-- USER ENTITIES --

-- The main table for all users: guests, hosts, administrators and support agents
-- We keep email, phone and other basic information in one place so we do not repeat it
CREATE TABLE UserAccount (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(250) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    ProfilePhoto TEXT,
    VerificationStatus ENUM('pending', 'verified', 'rejected') DEFAULT 'pending'
);

-- For people who want to book properties
-- A user becomes a guest when they want to travel
CREATE TABLE Guest (
    GuestID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT UNIQUE NOT NULL,
    LoyaltyPoints INT DEFAULT 0,
    TotalBookings INT DEFAULT 0,
    FOREIGN KEY (UserID) REFERENCES UserAccount(UserID) ON DELETE CASCADE
);

-- For people who rent out their properties
-- Tracks if they are a Superhost (which is Airbnb's top rating)
CREATE TABLE Host (
    HostID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT UNIQUE NOT NULL,
    SuperhostStatus BOOLEAN DEFAULT FALSE,
    ResponseRate DECIMAL(5,2) DEFAULT 0.00,
    FOREIGN KEY (UserID) REFERENCES UserAccount(UserID) ON DELETE CASCADE
);

-- Platform administrators who manage the system
-- Each admin has specific permissions in their department
CREATE TABLE Administrator (
    AdminID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT UNIQUE NOT NULL,
    Permissions TEXT,
    Department VARCHAR(100),
    FOREIGN KEY (UserID) REFERENCES UserAccount(UserID) ON DELETE CASCADE
);

-- Support agents who help users with problems
-- Tracks how many cases they are currently handling
CREATE TABLE CustomerSupport (
    SupportID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT UNIQUE NOT NULL,
    Department VARCHAR(100),
    ActiveCases INT DEFAULT 0,
    FOREIGN KEY (UserID) REFERENCES UserAccount(UserID) ON DELETE CASCADE
);


-- GEOGRAPHY ENTITIES --

-- List of countries where properties are located
-- Simple table with country names and codes (like ES for Spain)
CREATE TABLE Country (
    CountryID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Code VARCHAR(15) UNIQUE NOT NULL
);

-- Cities within countries
-- Links each city to its country
CREATE TABLE City (
    CityID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(150) NOT NULL,
    CountryID INT NOT NULL,
    FOREIGN KEY (CountryID) REFERENCES Country(CountryID) ON DELETE CASCADE
);

-- Neighborhoods within cities 
-- Helps users find properties in specific areas
CREATE TABLE Neighborhood (
    NeighborhoodID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(150) NOT NULL,
    CityID INT NOT NULL,
    FOREIGN KEY (CityID) REFERENCES City(CityID) ON DELETE CASCADE
);

-- Specific addresses for properties
-- The exact location where a property is
CREATE TABLE Address (
    AddressID INT PRIMARY KEY AUTO_INCREMENT,
    NeighborhoodID INT NOT NULL,
    Street VARCHAR(200) NOT NULL,
    FOREIGN KEY (NeighborhoodID) REFERENCES Neighborhood(NeighborhoodID) ON DELETE CASCADE
);


-- PROPERTY ENTITIES --

-- The main properties table: apartments, houses, etc.
-- Everything about a place someone can book
CREATE TABLE Property (
    PropertyID INT PRIMARY KEY AUTO_INCREMENT,
    HostID INT NOT NULL,
    AddressID INT NOT NULL,
    Title VARCHAR(200) NOT NULL,
    Description TEXT,
    Type VARCHAR(50),
    Capacity INT NOT NULL,
    PricePerNight DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (HostID) REFERENCES Host(HostID) ON DELETE CASCADE,
    FOREIGN KEY (AddressID) REFERENCES Address(AddressID) ON DELETE CASCADE
);

-- Features a property can have 
-- Master list of all possible amenities
CREATE TABLE Amenity (
    AmenityID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL UNIQUE
);

-- Links properties to their amenities
-- A property can have many amenities, an amenity can be in many properties
CREATE TABLE PropertyAmenity (
    PropertyID INT NOT NULL,
    AmenityID INT NOT NULL,
    PRIMARY KEY (PropertyID, AmenityID),
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID) ON DELETE CASCADE,
    FOREIGN KEY (AmenityID) REFERENCES Amenity(AmenityID) ON DELETE CASCADE
);

-- Photos of properties
-- Each property can have multiple photos
CREATE TABLE Photo (
    PhotoID INT PRIMARY KEY AUTO_INCREMENT,
    PropertyID INT NOT NULL,
    URL TEXT NOT NULL,
    Caption VARCHAR(250),
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID) ON DELETE CASCADE
);

-- Calendar showing when properties are available
-- Also tracks price changes on specific dates
CREATE TABLE Availability (
    AvailabilityID INT PRIMARY KEY AUTO_INCREMENT,
    PropertyID INT NOT NULL,
    Date DATE NOT NULL,
    IsAvailable BOOLEAN DEFAULT TRUE,
    Price DECIMAL(10,2),
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID) ON DELETE CASCADE,
    UNIQUE KEY (PropertyID, Date)
);


-- BOOKING AND PAYMENT ENTITIES --

-- Different cancellation options hosts can choose
-- From flexible (easy to cancel) to strict (hard to cancel)
CREATE TABLE CancellationPolicy (
    PolicyID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Description TEXT,
    RefundRules TEXT
);

-- When someone books a property
-- The heart of the Airbnb business
CREATE TABLE Booking (
    BookingID INT PRIMARY KEY AUTO_INCREMENT,
    PropertyID INT NOT NULL,
    GuestID INT NOT NULL,
    PolicyID INT NOT NULL,
    CheckIn DATE NOT NULL,
    CheckOut DATE NOT NULL,
    NumGuests INT NOT NULL,
    Status ENUM('pending', 'confirmed', 'cancelled', 'completed') DEFAULT 'pending',
    TotalPrice DECIMAL(10,2) NOT NULL,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID) ON DELETE CASCADE,
    FOREIGN KEY (GuestID) REFERENCES Guest(GuestID) ON DELETE CASCADE,
    FOREIGN KEY (PolicyID) REFERENCES CancellationPolicy(PolicyID) ON DELETE CASCADE
);

-- Payments for bookings
-- Tracks how much was paid, when, and the platform's commission
CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY AUTO_INCREMENT,
    BookingID INT UNIQUE NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    Method VARCHAR(50) NOT NULL,
    Status ENUM('pending', 'paid', 'failed', 'refunded') DEFAULT 'pending',
    Commission DECIMAL(10,2),
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE
);


-- COMMUNICATION ENTITIES --

-- Reviews guests write about properties
-- After a stay, guests can rate and comment
CREATE TABLE PropertyReview (
    PropertyReviewID INT PRIMARY KEY AUTO_INCREMENT,
    BookingID INT UNIQUE NOT NULL,
    GuestID INT NOT NULL,
    Rating DECIMAL(3,2) NOT NULL,
    Comment TEXT,
    ReviewDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_property_rating CHECK (Rating BETWEEN 1 AND 5),
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE,
    FOREIGN KEY (GuestID) REFERENCES Guest(GuestID) ON DELETE CASCADE
);

-- Reviews hosts write about guests
-- After a stay, hosts can rate guests too
CREATE TABLE GuestReview (
    GuestReviewID INT PRIMARY KEY AUTO_INCREMENT,
    BookingID INT UNIQUE NOT NULL,
    HostID INT NOT NULL,
    Rating DECIMAL(3,2) NOT NULL,
    Comment TEXT,
    ReviewDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_guest_rating CHECK (Rating BETWEEN 1 AND 5),
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE,
    FOREIGN KEY (HostID) REFERENCES Host(HostID) ON DELETE CASCADE
);

-- Conversations between users
-- Can be about a specific property or just general chat
CREATE TABLE Conversation (
    ConversationID INT PRIMARY KEY AUTO_INCREMENT,
    User1ID INT NOT NULL,
    User2ID INT NOT NULL,
    PropertyID INT,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (User1ID) REFERENCES UserAccount(UserID) ON DELETE CASCADE,
    FOREIGN KEY (User2ID) REFERENCES UserAccount(UserID) ON DELETE CASCADE,
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID) ON DELETE SET NULL
);

-- Individual messages within conversations
-- Who sent it, what they said and when
CREATE TABLE Message (
    MessageID INT PRIMARY KEY AUTO_INCREMENT,
    ConversationID INT NOT NULL,
    SenderID INT NOT NULL,
    Content TEXT NOT NULL,
    Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    ReplyToMessageID INT,
    FOREIGN KEY (ConversationID) REFERENCES Conversation(ConversationID) ON DELETE CASCADE,
    FOREIGN KEY (SenderID) REFERENCES UserAccount(UserID) ON DELETE CASCADE,
    FOREIGN KEY (ReplyToMessageID) REFERENCES Message(MessageID) ON DELETE SET NULL
);


-- MANAGEMENT ENTITIES --

-- When something goes wrong during a stay
-- Guests or hosts can report problems
CREATE TABLE IncidentReport (
    ReportID INT PRIMARY KEY AUTO_INCREMENT,
    BookingID INT NOT NULL,
    ReporterID INT NOT NULL,
    Description TEXT NOT NULL,
    Status ENUM('open', 'investigating', 'resolved', 'closed') DEFAULT 'open',
    ReportDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE,
    FOREIGN KEY (ReporterID) REFERENCES UserAccount(UserID) ON DELETE CASCADE
);

-- When users need help from support agents
-- Tracks the problem, who is handling it and its status
CREATE TABLE SupportCase (
    CaseID INT PRIMARY KEY AUTO_INCREMENT,
    BookingID INT,
    ReporterID INT NOT NULL,
    SupportAgentID INT,
    Description TEXT NOT NULL,
    Status ENUM('open', 'in progress', 'resolved', 'closed') DEFAULT 'open',
    Priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE SET NULL,
    FOREIGN KEY (ReporterID) REFERENCES UserAccount(UserID) ON DELETE CASCADE,
    FOREIGN KEY (SupportAgentID) REFERENCES CustomerSupport(SupportID) ON DELETE SET NULL
);

-- When admins check if properties meet standards
-- Properties need approval before they can be listed
CREATE TABLE PropertyVerification (
    VerifyID INT PRIMARY KEY AUTO_INCREMENT,
    PropertyID INT NOT NULL,
    AdminID INT NOT NULL,
    Status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    Notes TEXT,
    VerifiedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID) ON DELETE CASCADE,
    FOREIGN KEY (AdminID) REFERENCES Administrator(AdminID) ON DELETE CASCADE
);



