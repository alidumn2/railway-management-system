-- 1. COUNTRY: Stores core nations involved in the railway corridor
CREATE TABLE Country (
    CountryID INT AUTO_INCREMENT PRIMARY KEY,
    CountryName VARCHAR(100) NOT NULL UNIQUE
);

-- 2. STATION: Defines operational hubs and border checkpoints
CREATE TABLE Station (
    StationID INT AUTO_INCREMENT PRIMARY KEY,
    CountryID INT NOT NULL,
    StationName VARCHAR(150) NOT NULL,
    StationType VARCHAR(50) NOT NULL,
    CONSTRAINT FK_Station_Country FOREIGN KEY (CountryID) 
        REFERENCES Country(CountryID) ON DELETE CASCADE,
    CONSTRAINT CHK_Station_Type CHECK (
        StationType IN ('Passenger', 'Freight', 'Port', 'Customs', 'Historical', 'Border')
    )
);

-- 3. TRAIN: Distinguishes between passenger and freight rolling stock
CREATE TABLE Train (
    TrainID VARCHAR(20) PRIMARY KEY,
    TrainName VARCHAR(100) NOT NULL,
    TrainType VARCHAR(50) NOT NULL,
    MaxPassengerSpeed INT,
    MaxFreightSpeed INT,
    CONSTRAINT CHK_Train_Type CHECK (TrainType IN ('Passenger', 'Freight')),
    CONSTRAINT CHK_Positive_Speed CHECK (
        MaxPassengerSpeed >= 0 AND MaxFreightSpeed >= 0
    )
);

-- 4. LOYALTY CLASS: Defines discount tiers based on accumulated miles (e.g., Green, Silver, Gold)
CREATE TABLE LoyaltyClass (
    ClassID INT AUTO_INCREMENT PRIMARY KEY,
    ClassName VARCHAR(20) NOT NULL UNIQUE,
    MilesRequired INT NOT NULL,
    DiscountPercentage DECIMAL(5,2) NOT NULL,
    -- Prevents negative values for miles and discounts
    CONSTRAINT CHK_Positive_Miles CHECK (MilesRequired >= 0 AND DiscountPercentage >= 0)
);

-- 5. PASSENGER: Stores passenger profiles and loyalty status
CREATE TABLE Passenger (
    PassengerID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    TotalMiles INT DEFAULT 0,
    ClassID INT,
    -- Links passenger to their respective loyalty tier
    CONSTRAINT FK_Passenger_Loyalty FOREIGN KEY (ClassID) 
        REFERENCES LoyaltyClass(ClassID) ON DELETE SET NULL,
    CONSTRAINT CHK_Total_Miles CHECK (TotalMiles >= 0)
);

-- 6. DEPENDENT: Weak entity storing family members linked to a primary passenger
CREATE TABLE Dependent (
    DependentID INT AUTO_INCREMENT PRIMARY KEY,
    MainPassengerID INT NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    
    CONSTRAINT FK_Dependent_Passenger FOREIGN KEY (MainPassengerID) 
        REFERENCES Passenger(PassengerID) ON DELETE CASCADE
);

-- 7. RESERVATION: Transactional entity managing ticket bookings, seat assignments, and payment statuses
CREATE TABLE Reservation (
    ReservationID INT AUTO_INCREMENT PRIMARY KEY,
    PassengerID INT NOT NULL,
    DependentID INT,
    TrainID VARCHAR(20) NOT NULL,
    TravelDate DATE NOT NULL,
    FromStationID INT NOT NULL,
    ToStationID INT NOT NULL,
    CoachType VARCHAR(20) NOT NULL,
    SeatNumber VARCHAR(10) NOT NULL,
    TicketPrice DECIMAL(10,2) NOT NULL,
    PaymentStatus VARCHAR(20) NOT NULL DEFAULT 'Pending',
    TicketStatus VARCHAR(20) NOT NULL DEFAULT 'Active',
    ExpiryDate DATETIME, -- Ödeme süresi için eklendi
    
    CONSTRAINT FK_Reservation_Passenger FOREIGN KEY (PassengerID) REFERENCES Passenger(PassengerID),
    CONSTRAINT FK_Reservation_Dependent FOREIGN KEY (DependentID) REFERENCES Dependent(DependentID) ON DELETE SET NULL,
    CONSTRAINT FK_Reservation_Train FOREIGN KEY (TrainID) REFERENCES Train(TrainID),
    CONSTRAINT FK_Reservation_FromStation FOREIGN KEY (FromStationID) REFERENCES Station(StationID),
    CONSTRAINT FK_Reservation_ToStation FOREIGN KEY (ToStationID) REFERENCES Station(StationID),
    
    CONSTRAINT CHK_Ticket_Price CHECK (TicketPrice > 0),
    CONSTRAINT CHK_Payment_Status CHECK (PaymentStatus IN ('Pending', 'Paid', 'Canceled')),
    
    CONSTRAINT UQ_Seat_Train_Date UNIQUE (TrainID, TravelDate, SeatNumber)
);

-- 8. TRACK SEGMENT: Infrastructure links connecting exactly two stations
CREATE TABLE TrackSegment (
    TrackID INT AUTO_INCREMENT PRIMARY KEY,
    StationA_ID INT NOT NULL,
    StationB_ID INT NOT NULL,
    DistanceKM DECIMAL(6,2) NOT NULL,
    IsElectrified BOOLEAN DEFAULT TRUE,
    TrackStatus VARCHAR(20) NOT NULL DEFAULT 'Active',
    
    CONSTRAINT FK_Track_StationA FOREIGN KEY (StationA_ID) REFERENCES Station(StationID),
    CONSTRAINT FK_Track_StationB FOREIGN KEY (StationB_ID) REFERENCES Station(StationID),
    
    CONSTRAINT CHK_Different_Stations CHECK (StationA_ID <> StationB_ID),
    CONSTRAINT CHK_Track_Status CHECK (TrackStatus IN ('Active', 'Maintenance', 'Closed'))
);

-- 9. TRAIN SCHEDULE: Chronological ordering of station stops for active routes
CREATE TABLE TrainSchedule (
    ScheduleID INT AUTO_INCREMENT PRIMARY KEY,
    TrainID VARCHAR(20) NOT NULL,
    StationID INT NOT NULL,
    StopOrder INT NOT NULL,
    ArrivalTime DATETIME,
    DepartureTime DATETIME,
    
    CONSTRAINT FK_Schedule_Train FOREIGN KEY (TrainID) REFERENCES Train(TrainID) ON DELETE CASCADE,
    CONSTRAINT FK_Schedule_Station FOREIGN KEY (StationID) REFERENCES Station(StationID),
    
    CONSTRAINT CHK_Stop_Order CHECK (StopOrder > 0),
    CONSTRAINT UQ_Train_StopOrder UNIQUE (TrainID, StopOrder)
);

-- 10. FREIGHT SHIPMENT: Logs international cargo logistics and train assignments
CREATE TABLE FreightShipment (
    ShipmentID INT AUTO_INCREMENT PRIMARY KEY,
    ShipperName VARCHAR(100) NOT NULL,
    OriginStationID INT NOT NULL,
    DestStationID INT NOT NULL,
    CargoType VARCHAR(50) NOT NULL,
    WeightKG DECIMAL(10,2) NOT NULL,
    ContainerCount INT NOT NULL,
    CurrentStatus VARCHAR(30) NOT NULL DEFAULT 'In Transit',
    AssignedTrainID VARCHAR(20),
    
    CONSTRAINT FK_Freight_Origin FOREIGN KEY (OriginStationID) REFERENCES Station(StationID),
    CONSTRAINT FK_Freight_Dest FOREIGN KEY (DestStationID) REFERENCES Station(StationID),
    CONSTRAINT FK_Freight_Train FOREIGN KEY (AssignedTrainID) REFERENCES Train(TrainID) ON DELETE SET NULL,
    
    CONSTRAINT CHK_Freight_Metrics CHECK (WeightKG > 0 AND ContainerCount > 0)
);

-- 11. CUSTOMS CLEARANCE: Tracks mandatory border inspections for freight
CREATE TABLE CustomsClearance (
    ClearanceID INT AUTO_INCREMENT PRIMARY KEY,
    ShipmentID INT NOT NULL,
    CheckpointStationID INT NOT NULL,
    InspectionDate DATETIME NOT NULL,
    ClearanceStatus VARCHAR(20) NOT NULL,
    DocumentRef VARCHAR(50),
    Remarks TEXT,
    
    CONSTRAINT FK_Customs_Shipment FOREIGN KEY (ShipmentID) REFERENCES FreightShipment(ShipmentID) ON DELETE CASCADE,
    CONSTRAINT FK_Customs_Station FOREIGN KEY (CheckpointStationID) REFERENCES Station(StationID),
    
    -- Enforces valid status during border crossings
    CONSTRAINT CHK_Clearance_Status CHECK (ClearanceStatus IN ('Pending', 'Approved', 'Rejected', 'Inspecting'))
);

-- 12. STAFF: Railway personnel registry and job roles
CREATE TABLE Staff (
    StaffID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    JobRole VARCHAR(50) NOT NULL,
    CONSTRAINT CHK_Staff_Role CHECK (
        JobRole IN ('Driver', 'Engineer', 'Station Manager', 'Customs Coordinator', 'Maintenance Technician', 'Admin')
    )
);

-- 13. STAFF ASSIGNMENT: Resolves M:N relationship linking staff to specific train duties
CREATE TABLE StaffAssignment (
    AssignmentID INT AUTO_INCREMENT PRIMARY KEY,
    StaffID INT NOT NULL,
    TrainID VARCHAR(20) NOT NULL,
    AssignmentDate DATE NOT NULL,
    RoleOnTrain VARCHAR(50),
    
    CONSTRAINT FK_StaffAssign_Staff FOREIGN KEY (StaffID) REFERENCES Staff(StaffID) ON DELETE CASCADE,
    CONSTRAINT FK_StaffAssign_Train FOREIGN KEY (TrainID) REFERENCES Train(TrainID) ON DELETE CASCADE,
    
    -- Business logic: Prevents double-booking staff on the exact same date
    CONSTRAINT UQ_Staff_Date UNIQUE (StaffID, AssignmentDate)
);

-- 14. MAINTENANCE RECORD: Tracks repairs for trains, tracks, or stations
CREATE TABLE MaintenanceRecord (
    RecordID INT AUTO_INCREMENT PRIMARY KEY,
    TargetType VARCHAR(20) NOT NULL, 
    TrainID VARCHAR(20),
    TrackID INT,
    StationID INT,
    MaintenanceDate DATE NOT NULL,
    MaintenanceStatus VARCHAR(20) NOT NULL DEFAULT 'Scheduled',
    Remarks TEXT,
    
    CONSTRAINT FK_Maint_Train FOREIGN KEY (TrainID) REFERENCES Train(TrainID) ON DELETE CASCADE,
    CONSTRAINT FK_Maint_Track FOREIGN KEY (TrackID) REFERENCES TrackSegment(TrackID) ON DELETE CASCADE,
    CONSTRAINT FK_Maint_Station FOREIGN KEY (StationID) REFERENCES Station(StationID) ON DELETE CASCADE,

    CONSTRAINT CHK_Target_Type CHECK (TargetType IN ('Train', 'Track', 'Station')),
    CONSTRAINT CHK_Maint_Status CHECK (MaintenanceStatus IN ('Scheduled', 'In Progress', 'Completed'))
);

-- 15. SENSOR READING: Captures high-frequency telemetric safety data
CREATE TABLE SensorReading (
    ReadingID INT AUTO_INCREMENT PRIMARY KEY,
    ReadingType VARCHAR(50) NOT NULL,
    ReadingValue DECIMAL(10,2) NOT NULL,
    TrainID VARCHAR(20), 
    TrackID INT,         
    ReadingTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    IsNormal BOOLEAN DEFAULT TRUE,
    
    CONSTRAINT FK_Sensor_Train FOREIGN KEY (TrainID) REFERENCES Train(TrainID) ON DELETE CASCADE,
    CONSTRAINT FK_Sensor_Track FOREIGN KEY (TrackID) REFERENCES TrackSegment(TrackID) ON DELETE CASCADE,
    
    CONSTRAINT CHK_Sensor_Type CHECK (
        ReadingType IN ('Vibration', 'Heat', 'Brake Inspection', 'Track Condition', 'Signal Status')
    )
);

-- 16. WAITING LIST: Queues passengers for fully booked trains
CREATE TABLE WaitingList (
    WaitlistID INT AUTO_INCREMENT PRIMARY KEY,
    PassengerID INT NOT NULL,
    TrainID VARCHAR(20) NOT NULL,
    TravelDate DATE NOT NULL,
    CONSTRAINT FK_Waitlist_Pass FOREIGN KEY (PassengerID) REFERENCES Passenger(PassengerID) ON DELETE CASCADE,
    CONSTRAINT FK_Waitlist_Train FOREIGN KEY (TrainID) REFERENCES Train(TrainID) ON DELETE CASCADE
);

-- 17. LUGGAGE: Stores luggage details for each passenger reservation
CREATE TABLE Luggage (
    LuggageID INT AUTO_INCREMENT PRIMARY KEY,
    ReservationID INT NOT NULL,
    WeightKG DECIMAL(5,2) NOT NULL,
    BagCount INT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Luggage_Reservation FOREIGN KEY (ReservationID) 
        REFERENCES Reservation(ReservationID) ON DELETE CASCADE,
    CONSTRAINT CHK_Luggage_Weight CHECK (WeightKG > 0)
);
