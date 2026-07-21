USE railway_db;

-- 1. COUNTRY
INSERT INTO Country (CountryName) VALUES 
('Saudi Arabia'), 
('Jordan'), 
('Syria'), 
('Turkiye');

-- 2. STATION
INSERT INTO Station (CountryID, StationName, StationType) VALUES
(1, 'Riyadh Central', 'Passenger'),
(1, 'Jeddah Port', 'Port'),
(2, 'Amman Railway Station', 'Passenger'),
(2, 'Aqaba Border', 'Border'),
(3, 'Damascus Central', 'Passenger'),
(4, 'Istanbul Sirkeci', 'Historical'),
(4, 'Ankara YHT', 'Passenger'),
(4, 'Eskisehir YHT', 'Passenger');

-- 3. TRAIN
INSERT INTO Train (TrainID, TrainName, TrainType, MaxPassengerSpeed, MaxFreightSpeed) VALUES
('TRN-1001', 'Hejaz Express', 'Passenger', 250, 0),
('TRN-1002', 'Anadolu Star', 'Passenger', 300, 0),
('TRN-F001', 'Red Sea Cargo', 'Freight', 0, 120),
('TRN-F002', 'Bosphorus Logistics', 'Freight', 0, 100);

-- 4. LOYALTY CLASS
INSERT INTO LoyaltyClass (ClassName, MilesRequired, DiscountPercentage) VALUES
('Green', 10000, 5.00),
('Silver', 50000, 10.00),
('Gold', 100000, 25.00);

-- 5. PASSENGER
INSERT INTO Passenger (FirstName, LastName, Email, TotalMiles, ClassID) VALUES
('Ali', 'Duman', 'ali.smoke@example.com', 15000, 1), 
('Ahmet', 'Yilmaz', 'ahmet.y@example.com', 55000, 2), 
('Ayse', 'Kaya', 'ayse.k@example.com', 120000, 3), 
('John', 'Smith', 'john.s@example.com', 5000, NULL);

-- 6. RESERVATION
INSERT INTO Reservation (PassengerID, TrainID, TravelDate, FromStationID, ToStationID, CoachType, SeatNumber, TicketPrice, PaymentStatus) VALUES
(1, 'TRN-1001', '2026-06-15', 8, 6, 'Economy', 'A12', 450.00, 'Paid'),
(2, 'TRN-1002', '2026-06-16', 7, 8, 'Business', 'B05', 850.00, 'Paid'),
(3, 'TRN-1001', '2026-06-20', 3, 5, 'VIP', 'V01', 1200.00, 'Pending'),
(4, 'TRN-1002', '2026-06-25', 6, 7, 'Economy', 'C22', 400.00, 'Canceled');

-- 7. DEPENDENT
INSERT INTO Dependent (MainPassengerID, FirstName, LastName) VALUES
(1, 'Zeynep', 'Duman'),
(2, 'Fatma', 'Yilmaz');

-- 8. TRACK SEGMENT
INSERT INTO TrackSegment (StationA_ID, StationB_ID, DistanceKM, IsElectrified, TrackStatus) VALUES
(1, 2, 850.50, TRUE, 'Active'),      
(3, 4, 320.00, FALSE, 'Active'),     
(6, 7, 450.00, TRUE, 'Active'),        
(7, 8, 235.00, TRUE, 'Active'),        
(4, 5, 410.00, FALSE, 'Maintenance'); 

-- 9. TRAIN SCHEDULE
INSERT INTO TrainSchedule (TrainID, StationID, StopOrder, ArrivalTime, DepartureTime) VALUES
('TRN-1001', 8, 1, '2026-06-15 08:00:00', '2026-06-15 08:15:00'),
('TRN-1001', 7, 2, '2026-06-15 10:00:00', '2026-06-15 10:30:00'),
('TRN-1001', 6, 3, '2026-06-15 14:00:00', '2026-06-15 14:30:00'),
('TRN-F001', 2, 1, '2026-06-10 05:00:00', '2026-06-10 08:00:00'),
('TRN-F001', 4, 2, '2026-06-11 12:00:00', '2026-06-11 16:00:00'),
('TRN-1002', 7, 1, '2026-06-16 09:00:00', '2026-06-16 09:15:00');

-- 10. FREIGHT SHIPMENT
INSERT INTO FreightShipment (ShipperName, OriginStationID, DestStationID, CargoType, WeightKG, ContainerCount, CurrentStatus, AssignedTrainID) VALUES
('Global Logistics', 2, 4, 'Electronics', 5000.00, 10, 'In Transit', 'TRN-F001'),
('AgriExport', 3, 6, 'Wheat', 12000.00, 25, 'Pending', 'TRN-F002'),
('Saudi Oil Co.', 1, 2, 'Petrochemicals', 25000.00, 40, 'In Transit', 'TRN-F001');

-- 11. CUSTOMS CLEARANCE
INSERT INTO CustomsClearance (ShipmentID, CheckpointStationID, InspectionDate, ClearanceStatus, DocumentRef, Remarks) VALUES
(1, 4, '2026-06-11 13:00:00', 'Approved', 'DOC-991', 'All clear'),
(2, 6, '2026-06-14 09:00:00', 'Pending', 'DOC-404', 'Awaiting paperwork'),
(1, 2, '2026-06-10 06:30:00', 'Approved', 'DOC-990', 'Port clearance ok');

-- 12. STAFF
INSERT INTO Staff (FirstName, LastName, JobRole) VALUES
('Hasan', 'Demir', 'Driver'),
('Elena', 'Kozlov', 'Engineer'),
('Mustafa', 'Kaya', 'Station Manager'),
('Omar', 'Farooq', 'Customs Coordinator'),
('Kemal', 'Sunal', 'Maintenance Technician');

-- 13. STAFF ASSIGNMENT
INSERT INTO StaffAssignment (StaffID, TrainID, AssignmentDate, RoleOnTrain) VALUES
(1, 'TRN-1001', '2026-06-15', 'Lead Driver'),
(2, 'TRN-1001', '2026-06-15', 'Chief Engineer'),
(4, 'TRN-F001', '2026-06-11', 'Border Inspector');

-- 14. MAINTENANCE RECORD
INSERT INTO MaintenanceRecord (TargetType, TrainID, TrackID, StationID, MaintenanceDate, MaintenanceStatus) VALUES
('Train', 'TRN-1002', NULL, NULL, '2026-05-20', 'Scheduled'),
('Track', NULL, 5, NULL, '2026-05-22', 'In Progress'),
('Station', NULL, NULL, 6, '2026-05-25', 'Completed');

-- 15. SENSOR READING
INSERT INTO SensorReading (ReadingType, ReadingValue, TrainID, TrackID, IsNormal) VALUES
('Heat', 75.5, 'TRN-1001', NULL, TRUE),
('Vibration', 2.3, NULL, 1, TRUE),
('Brake Inspection', 98.0, 'TRN-1002', NULL, TRUE),
('Track Condition', 45.0, NULL, 5, FALSE);

-- 16. WAITING LIST
INSERT INTO WaitingList (PassengerID, TrainID, TravelDate) 
VALUES (4, 'TRN-1001', '2026-06-20');

-- 17. LUGGAGE
INSERT INTO Luggage (ReservationID, WeightKG, BagCount) VALUES
(19, 15.50, 1),
(20, 42.00, 2),
(21, 8.00, 1); 