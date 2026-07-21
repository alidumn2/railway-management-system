USE railway_db;

-- Report 1: Current active trains for a selected date
SELECT DISTINCT t.TrainID, t.TrainName, t.TrainType
FROM Train t
JOIN TrainSchedule ts ON t.TrainID = ts.TrainID
WHERE DATE(ts.DepartureTime) = '2026-06-15';


-- Report 2: Ordered station list for a selected train route
SELECT ts.StopOrder, s.StationName, ts.ArrivalTime, ts.DepartureTime
FROM TrainSchedule ts
JOIN Station s ON ts.StationID = s.StationID
WHERE ts.TrainID = 'TRN-1001'
ORDER BY ts.StopOrder;


-- Report 3: Comprehensive reservation details for a specific passenger
SELECT r.ReservationID, p.FirstName, p.LastName, r.TrainID, r.TravelDate,
       s_from.StationName AS FromStation, s_to.StationName AS ToStation,
       r.SeatNumber, r.PaymentStatus
FROM Reservation r
JOIN Passenger p ON r.PassengerID = p.PassengerID
JOIN Station s_from ON r.FromStationID = s_from.StationID
JOIN Station s_to ON r.ToStationID = s_to.StationID
WHERE p.PassengerID = 1;


-- Report 4: Prioritized waiting list based on passenger loyalty class
SELECT wl.TravelDate, t.TrainName, p.FirstName, p.LastName, lc.ClassName AS LoyaltyClass
FROM WaitingList wl
JOIN Passenger p ON wl.PassengerID = p.PassengerID
JOIN Train t ON wl.TrainID = t.TrainID
LEFT JOIN LoyaltyClass lc ON p.ClassID = lc.ClassID
WHERE wl.TravelDate = '2026-06-20' AND t.TrainID = 'TRN-1001'
ORDER BY lc.MilesRequired DESC; 


-- Report 5: Total reserved seats (load factor) for trains on a specific date
SELECT t.TrainID, t.TrainName, COUNT(r.ReservationID) AS TotalReservedSeats
FROM Train t
LEFT JOIN Reservation r ON t.TrainID = r.TrainID
GROUP BY t.TrainID, t.TrainName;


-- Report 6: Dependents traveling alongside main passengers on a selected date
SELECT d.FirstName AS DependentName, d.LastName, p.FirstName AS MainPassenger, r.TravelDate, r.TrainID
FROM Dependent d
JOIN Passenger p ON d.MainPassengerID = p.PassengerID
JOIN Reservation r ON p.PassengerID = r.PassengerID
WHERE r.TravelDate = '2026-06-15';


-- Report 7: Freight shipments crossing a specific national border (e.g., Jordan)
SELECT fs.ShipmentID, fs.CargoType, fs.WeightKG, c.CountryName AS BorderCountry, s.StationName
FROM FreightShipment fs
JOIN CustomsClearance cc ON fs.ShipmentID = cc.ShipmentID
JOIN Station s ON cc.CheckpointStationID = s.StationID
JOIN Country c ON s.CountryID = c.CountryID
WHERE s.StationType = 'Border' AND c.CountryName = 'Jordan';


-- Report 8: Customs clearance history and status for a specific freight shipment
SELECT cc.InspectionDate, s.StationName, cc.ClearanceStatus, cc.DocumentRef, cc.Remarks
FROM CustomsClearance cc
JOIN Station s ON cc.CheckpointStationID = s.StationID
WHERE cc.ShipmentID = 1;


-- Report 9: Technical maintenance history for a specific train or track segment
SELECT mr.MaintenanceDate, mr.TargetType, mr.MaintenanceStatus, mr.Remarks
FROM MaintenanceRecord mr
WHERE mr.TrainID = 'TRN-1002' OR mr.TrackID = 5
ORDER BY mr.MaintenanceDate DESC;


-- Report 10: Railway staff assigned to active trains on a specific date
SELECT sa.AssignmentDate, st.FirstName, st.LastName, st.JobRole, sa.RoleOnTrain, t.TrainName
FROM StaffAssignment sa
JOIN Staff st ON sa.StaffID = st.StaffID
JOIN Train t ON sa.TrainID = t.TrainID
WHERE sa.AssignmentDate = '2026-06-15';