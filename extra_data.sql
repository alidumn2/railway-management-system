USE railway_db;

-- ============================================================
-- Create user_profile table (for Django auth bridge)
-- ============================================================
CREATE TABLE IF NOT EXISTS user_profile (
    id BIGINT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    is_admin TINYINT(1) NOT NULL DEFAULT 0,
    PassengerID INT NULL UNIQUE,
    user_id INT NOT NULL UNIQUE,
    FOREIGN KEY (PassengerID) REFERENCES passenger(PassengerID),
    FOREIGN KEY (user_id) REFERENCES auth_user(id)
);

-- ============================================================
-- More Passengers
-- ============================================================
INSERT INTO Passenger (FirstName, LastName, Email, TotalMiles, ClassID) VALUES
('Fatma', 'Ozturk', 'fatma.o@example.com', 32000, 1),
('Mehmet', 'Celik', 'mehmet.c@example.com', 78000, 2),
('Sara', 'Al-Rashid', 'sara.r@example.com', 5200, NULL),
('Yusuf', 'Demir', 'yusuf.d@example.com', 110000, 3),
('Leila', 'Hassan', 'leila.h@example.com', 22000, 1),
('Karim', 'Abdullah', 'karim.a@example.com', 45000, 1),
('Elif', 'Yildiz', 'elif.y@example.com', 8000, NULL),
('Omar', 'Nasser', 'omar.n@example.com', 62000, 2);

-- ============================================================
-- More Trains
-- ============================================================
INSERT INTO Train (TrainID, TrainName, TrainType, MaxPassengerSpeed, MaxFreightSpeed) VALUES
('TRN-1003', 'Desert Wind', 'Passenger', 280, 0),
('TRN-1004', 'Levant Express', 'Passenger', 220, 0),
('TRN-1005', 'Silk Road Rapid', 'Passenger', 320, 0),
('TRN-F003', 'Gulf Cargo Line', 'Freight', 0, 110);

-- ============================================================
-- More Train Schedules
-- ============================================================
INSERT INTO TrainSchedule (TrainID, StationID, StopOrder, ArrivalTime, DepartureTime) VALUES
-- Desert Wind: Riyadh -> Amman -> Damascus -> Istanbul
('TRN-1003', 1, 1, '2026-07-22 06:00:00', '2026-07-22 06:30:00'),
('TRN-1003', 3, 2, '2026-07-22 12:00:00', '2026-07-22 12:30:00'),
('TRN-1003', 5, 3, '2026-07-22 18:00:00', '2026-07-22 18:30:00'),
('TRN-1003', 6, 4, '2026-07-23 02:00:00', NULL),
-- Levant Express: Damascus -> Ankara -> Eskisehir -> Istanbul
('TRN-1004', 5, 1, '2026-07-25 07:00:00', '2026-07-25 07:20:00'),
('TRN-1004', 7, 2, '2026-07-25 14:00:00', '2026-07-25 14:30:00'),
('TRN-1004', 8, 3, '2026-07-25 17:00:00', '2026-07-25 17:15:00'),
('TRN-1004', 6, 4, '2026-07-25 20:00:00', NULL),
-- Silk Road Rapid: Istanbul -> Ankara -> Eskisehir
('TRN-1005', 6, 1, '2026-07-28 09:00:00', '2026-07-28 09:15:00'),
('TRN-1005', 7, 2, '2026-07-28 13:30:00', '2026-07-28 13:45:00'),
('TRN-1005', 8, 3, '2026-07-28 15:45:00', NULL),
-- Hejaz Express: Return trip
('TRN-1001', 6, 4, '2026-07-30 08:00:00', '2026-07-30 08:15:00'),
('TRN-1001', 5, 5, '2026-07-30 11:00:00', '2026-07-30 11:30:00'),
('TRN-1001', 3, 6, '2026-07-30 15:00:00', NULL);

-- ============================================================
-- Many More Reservations (different dates, routes, passengers)
-- ============================================================
INSERT INTO Reservation (PassengerID, TrainID, TravelDate, FromStationID, ToStationID, CoachType, SeatNumber, TicketPrice, PaymentStatus, TicketStatus) VALUES
-- July 2026 trips
(1, 'TRN-1003', '2026-07-22', 1, 6, 'Business', 'B01', 980.00, 'Paid', 'Active'),
(2, 'TRN-1003', '2026-07-22', 3, 6, 'Economy', 'A03', 520.00, 'Paid', 'Active'),
(3, 'TRN-1004', '2026-07-25', 5, 6, 'VIP', 'V02', 1350.00, 'Paid', 'Active'),
(5, 'TRN-1003', '2026-07-22', 1, 5, 'Economy', 'A04', 380.00, 'Paid', 'Active'),
(6, 'TRN-1004', '2026-07-25', 5, 7, 'Business', 'B03', 720.00, 'Pending', 'Active'),
(7, 'TRN-1005', '2026-07-28', 6, 7, 'Economy', 'C01', 280.00, 'Paid', 'Active'),
(8, 'TRN-1005', '2026-07-28', 6, 8, 'Economy', 'C02', 340.00, 'Paid', 'Active'),
(9, 'TRN-1003', '2026-07-22', 1, 3, 'Economy', 'A07', 300.00, 'Paid', 'Active'),
(10, 'TRN-1004', '2026-07-25', 7, 6, 'Business', 'B05', 650.00, 'Paid', 'Active'),
(11, 'TRN-1005', '2026-07-28', 7, 8, 'Economy', 'C05', 180.00, 'Pending', 'Active'),
(12, 'TRN-1001', '2026-07-30', 6, 3, 'VIP', 'V03', 1180.00, 'Paid', 'Active'),

-- August 2026 trips
(1, 'TRN-1002', '2026-08-05', 7, 8, 'Economy', 'A01', 220.00, 'Paid', 'Active'),
(2, 'TRN-1005', '2026-08-10', 6, 7, 'VIP', 'V01', 950.00, 'Pending', 'Active'),
(3, 'TRN-1003', '2026-08-12', 1, 6, 'Business', 'B02', 980.00, 'Paid', 'Active'),
(4, 'TRN-1004', '2026-08-15', 5, 6, 'Economy', 'A02', 450.00, 'Canceled', 'Canceled'),
(5, 'TRN-1001', '2026-08-18', 8, 6, 'Economy', 'A08', 470.00, 'Paid', 'Active'),
(6, 'TRN-1002', '2026-08-20', 7, 8, 'Business', 'B04', 550.00, 'Paid', 'Active'),
(7, 'TRN-1003', '2026-08-22', 3, 6, 'Economy', 'A05', 520.00, 'Paid', 'Active'),
(8, 'TRN-1005', '2026-08-25', 6, 8, 'Economy', 'C03', 340.00, 'Pending', 'Active'),
(9, 'TRN-1004', '2026-08-28', 5, 7, 'VIP', 'V04', 890.00, 'Paid', 'Active'),
(10, 'TRN-1001', '2026-08-30', 6, 5, 'Economy', 'A09', 420.00, 'Paid', 'Active'),
(11, 'TRN-1002', '2026-08-10', 8, 7, 'Economy', 'A03', 220.00, 'Paid', 'Active'),
(12, 'TRN-1003', '2026-08-15', 1, 5, 'Business', 'B06', 580.00, 'Paid', 'Active'),

-- September 2026 trips
(1, 'TRN-1005', '2026-09-01', 6, 8, 'Business', 'B01', 490.00, 'Pending', 'Active'),
(3, 'TRN-1003', '2026-09-05', 1, 6, 'VIP', 'V01', 1450.00, 'Paid', 'Active'),
(5, 'TRN-1004', '2026-09-08', 5, 6, 'Economy', 'A06', 450.00, 'Paid', 'Active'),
(7, 'TRN-1002', '2026-09-12', 7, 8, 'Economy', 'A10', 220.00, 'Paid', 'Active'),
(9, 'TRN-1001', '2026-09-15', 8, 6, 'Business', 'B07', 750.00, 'Paid', 'Active'),
(2, 'TRN-1005', '2026-09-18', 6, 7, 'Economy', 'C04', 280.00, 'Canceled', 'Canceled'),
(4, 'TRN-1003', '2026-09-20', 1, 3, 'Economy', 'A11', 300.00, 'Paid', 'Active'),
(6, 'TRN-1004', '2026-09-22', 7, 6, 'Business', 'B08', 650.00, 'Pending', 'Active');

-- ============================================================
-- More Luggage records for new reservations
-- ============================================================
INSERT INTO Luggage (ReservationID, WeightKG, BagCount) VALUES
((SELECT MAX(ReservationID) - 10 FROM Reservation), 23.50, 2),
((SELECT MAX(ReservationID) - 8 FROM Reservation), 18.00, 1),
((SELECT MAX(ReservationID) - 5 FROM Reservation), 35.00, 3),
((SELECT MAX(ReservationID) - 2 FROM Reservation), 12.00, 1),
((SELECT MAX(ReservationID) FROM Reservation), 28.50, 2);

-- ============================================================
-- More Staff
-- ============================================================
INSERT INTO Staff (FirstName, LastName, JobRole) VALUES
('Aylin', 'Arslan', 'Driver'),
('Hassan', 'Mahmoud', 'Engineer'),
('Derya', 'Sen', 'Admin');

-- ============================================================
-- More Staff Assignments
-- ============================================================
INSERT INTO StaffAssignment (StaffID, TrainID, AssignmentDate, RoleOnTrain) VALUES
(1, 'TRN-1003', '2026-07-22', 'Lead Driver'),
(2, 'TRN-1004', '2026-07-25', 'Chief Engineer'),
(3, 'TRN-1005', '2026-07-28', 'Station Coordinator'),
(6, 'TRN-1003', '2026-07-22', 'Co-Driver'),
(7, 'TRN-1005', '2026-07-28', 'Technical Support');
