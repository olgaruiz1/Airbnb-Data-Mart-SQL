-- This script contains test queries to check the database
-- They demostrate that data is correctly inserted and relationships work
-- Includes joins and analytics to see data in action


-- USER ACCOUNT QUERIES --

-- Find a specific user by their ID
-- Useful for looking up user details in the system
SELECT UserID, Name, Email, VerificationStatus
FROM UserAccount
WHERE UserID = 2;

-- Find guests who have booked more than 2 times
-- Shows most active travelers
SELECT GuestID, UserID, LoyaltyPoints, TotalBookings
FROM Guest
WHERE TotalBookings > 2
LIMIT 5;

-- Find all Superhosts 
-- Superhosts get special badges and benefits
SELECT HostID, UserID, SuperhostStatus, ResponseRate
FROM Host
WHERE SuperhostStatus = TRUE
LIMIT 5;

-- See which support agents are busiest
-- Helps with workload management
SELECT SupportID, Department, ActiveCases
FROM CustomerSupport
ORDER BY ActiveCases DESC
LIMIT 5;


-- LOCATION QUERIES --

-- List all countries alphabetically
-- Shows the geographic reach of the platform
SELECT CountryID, Name, Code
FROM Country
ORDER BY Name
LIMIT 5;

-- Find all cities in a specific country 
-- Useful for location-based searches
SELECT CityID, CountryID, Name
FROM City
WHERE CountryID = 1;

-- Find neighborhoods with long names 
SELECT Name, LENGTH(Name) AS NameLength
FROM Neighborhood
WHERE LENGTH(Name) > 10
ORDER BY NameLength DESC
LIMIT 5;

-- Analyze addresses by neighborhood
-- Shows which areas have longer street names on average
SELECT NeighborhoodID, COUNT(*) AS TotalAddresses, AVG(LENGTH(Street)) AS AvgStreetNameLength
FROM Address
GROUP BY NeighborhoodID
ORDER BY AvgStreetNameLength DESC
LIMIT 5;


-- PROPERTY QUERIES --

-- Find properties owned by Superhosts that can fit more than four people
-- Premium listings for group travelers
SELECT p.PropertyID, p.Title, p.PricePerNight
FROM Property p
JOIN Host h ON p.HostID = h.HostID
WHERE h.SuperhostStatus = TRUE AND p.Capacity >= 4
ORDER BY p.PricePerNight DESC;

-- Search for specific amenities (WiFi or Pool)
-- What guests often look for when booking
SELECT Name
FROM Amenity
WHERE Name LIKE '%WiFi%'
OR Name LIKE '%Pool%'
ORDER BY Name;

-- Find all properties that have WiFi
-- Demonstrates the many-to-many relationship between properties and amenities
SELECT p.Title, a.Name AS Amenity
FROM PropertyAmenity pa
JOIN Property p ON pa.PropertyID = p.PropertyID
JOIN Amenity a ON pa.AmenityID = a.AmenityID
WHERE a.Name = 'WiFi'
LIMIT 5;

-- Get recent property photos with captions
-- Shows how properties are presented to guests
SELECT p.Title, ph.URL, ph.Caption
FROM Photo ph
JOIN Property p ON ph.PropertyID = p.PropertyID
WHERE ph.Caption IS NOT NULL
ORDER BY ph.PhotoID DESC
LIMIT 5;

-- Check which dates are available for booking
-- The core of the availability calendar system
SELECT PropertyID, Date, IsAvailable, Price
FROM Availability
WHERE IsAvailable = TRUE
ORDER BY Date
LIMIT 5;


-- BOOKING AND PAYMENT QUERIES --

-- List all cancellation policy options
-- Shows what choices hosts have
SELECT PolicyID, Name
FROM CancellationPolicy
LIMIT 5;

-- Find past confirmed bookings
-- Historical data for analysis
SELECT BookingID, CheckIn, CheckOut, Status, TotalPrice
FROM Booking
WHERE Status = 'confirmed' AND CheckIn < CURDATE()
ORDER BY CheckIn
LIMIT 5;

-- See recent successful payments
-- Nice for financial transactions
SELECT PaymentID, Amount, Method, Status
FROM Payment
WHERE Status = 'paid'
ORDER BY CreatedAt DESC
LIMIT 5;


-- COMMUNICATION QUERIES --

-- Analyze property review ratings distribution
-- How guests rate properties 
SELECT Rating, COUNT(*) AS NumberOfReviews
FROM PropertyReview
GROUP BY Rating
ORDER BY Rating DESC;

-- Group guest reviews by star rating (rounded down)
-- How hosts rate guests
SELECT FLOOR(Rating) AS RatingStars, COUNT(*) AS NumberOfReviews
FROM GuestReview
GROUP BY RatingStars
ORDER BY RatingStars DESC;

-- Find recent conversations about specific properties
-- Guest-host communication history
SELECT ConversationID, User1ID, User2ID, CreatedAt
FROM Conversation
WHERE PropertyID IS NOT NULL
ORDER BY CreatedAt DESC
LIMIT 5;

-- See who sends the most messages
SELECT SenderID, COUNT(*) AS MessagesSent
FROM Message
GROUP BY SenderID
ORDER BY MessagesSent DESC
LIMIT 5;


-- MANAGEMENT ENTITIES --

-- Count incident reports by status
SELECT Status, COUNT(*) AS TotalReports
FROM IncidentReport
GROUP BY Status;

-- Analyze support cases by priority level
-- How urgent are user problems
SELECT Priority, COUNT(*) AS TotalCases
FROM SupportCase
GROUP BY Priority
ORDER BY TotalCases DESC;

-- Check recent property verifications
SELECT pv.VerifyID, pv.Status, p.Title
FROM PropertyVerification pv
INNER JOIN Property p ON pv.PropertyID = p.PropertyID
ORDER BY pv.VerifiedAt DESC
LIMIT 5;


-- BUSINESS QUERIES --

-- Host Revenue Analysis
-- Shows how much money each property has generated
-- This helps hosts understand their earnings
SELECT
h.HostID,
p.PropertyID,
p.Title AS PropertyTitle,
SUM(pay.Amount) AS TotalRevenue
FROM Host h
INNER JOIN Property p
ON h.HostID = p.HostID
INNER JOIN Booking b
ON p.PropertyID = b.PropertyID
INNER JOIN Payment pay
ON b.BookingID = pay.BookingID
WHERE pay.Status = 'paid'
GROUP BY
h.HostID,
p.PropertyID,
p.Title
ORDER BY TotalRevenue DESC;

-- Guest Spending & Loyalty Analysis
-- Shows how often guests book, how much they spend and how they rate properties
SELECT
g.GuestID,
COUNT(b.BookingID) AS TotalBookings,
SUM(p.Amount) AS TotalSpent,
AVG(pr.Rating) AS AverageRating
FROM Guest g
INNER JOIN Booking b
ON g.GuestID = b.GuestID
INNER JOIN Payment p
ON b.BookingID = p.BookingID
LEFT JOIN PropertyReview pr
ON b.BookingID = pr.BookingID
WHERE p.Status = 'paid'
GROUP BY g.GuestID
ORDER BY TotalSpent DESC;


-- ROW COUNT --

-- Exact row count for all 24 tables
-- Shows exactly how many entries are in each table
-- Uses COUNT(*) for accuracy
-- Helps verify the 20+ records requirement 
-- Exception: CancellationPolicy (5 records - business reality)
SELECT 'UserAccount' AS TableName, COUNT(*) AS RowCount FROM UserAccount
UNION ALL
SELECT 'Guest', COUNT(*) FROM Guest
UNION ALL
SELECT 'Host', COUNT(*) FROM Host
UNION ALL
SELECT 'Administrator', COUNT(*) FROM Administrator
UNION ALL
SELECT 'CustomerSupport', COUNT(*) FROM CustomerSupport
UNION ALL
SELECT 'Country', COUNT(*) FROM Country
UNION ALL
SELECT 'City', COUNT(*) FROM City
UNION ALL
SELECT 'Neighborhood', COUNT(*) FROM Neighborhood
UNION ALL
SELECT 'Address', COUNT(*) FROM Address
UNION ALL
SELECT 'Property', COUNT(*) FROM Property
UNION ALL
SELECT 'Amenity', COUNT(*) FROM Amenity
UNION ALL
SELECT 'PropertyAmenity', COUNT(*) FROM PropertyAmenity
UNION ALL
SELECT 'Photo', COUNT(*) FROM Photo
UNION ALL
SELECT 'Availability', COUNT(*) FROM Availability
UNION ALL
SELECT 'CancellationPolicy', COUNT(*) FROM CancellationPolicy
UNION ALL
SELECT 'Booking', COUNT(*) FROM Booking
UNION ALL
SELECT 'Payment', COUNT(*) FROM Payment
UNION ALL
SELECT 'PropertyReview', COUNT(*) FROM PropertyReview
UNION ALL
SELECT 'GuestReview', COUNT(*) FROM GuestReview
UNION ALL
SELECT 'Conversation', COUNT(*) FROM Conversation
UNION ALL
SELECT 'Message', COUNT(*) FROM Message
UNION ALL
SELECT 'IncidentReport', COUNT(*) FROM IncidentReport
UNION ALL
SELECT 'SupportCase', COUNT(*) FROM SupportCase
UNION ALL
SELECT 'PropertyVerification', COUNT(*) FROM PropertyVerification;

