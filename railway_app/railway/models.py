# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models
from django.contrib.auth.models import User


class AuthGroup(models.Model):
    name = models.CharField(unique=True, max_length=150)

    class Meta:
        managed = False
        db_table = 'auth_group'


class AuthGroupPermissions(models.Model):
    id = models.BigAutoField(primary_key=True)
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)
    permission = models.ForeignKey('AuthPermission', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_group_permissions'
        unique_together = (('group', 'permission'),)


class AuthPermission(models.Model):
    name = models.CharField(max_length=255)
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING)
    codename = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'auth_permission'
        unique_together = (('content_type', 'codename'),)


class AuthUser(models.Model):
    password = models.CharField(max_length=128)
    last_login = models.DateTimeField(blank=True, null=True)
    is_superuser = models.IntegerField()
    username = models.CharField(unique=True, max_length=150)
    first_name = models.CharField(max_length=150)
    last_name = models.CharField(max_length=150)
    email = models.CharField(max_length=254)
    is_staff = models.IntegerField()
    is_active = models.IntegerField()
    date_joined = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'auth_user'


class AuthUserGroups(models.Model):
    id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_groups'
        unique_together = (('user', 'group'),)


class AuthUserUserPermissions(models.Model):
    id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    permission = models.ForeignKey(AuthPermission, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_user_permissions'
        unique_together = (('user', 'permission'),)


class Country(models.Model):
    countryid = models.AutoField(db_column='CountryID', primary_key=True)  
    countryname = models.CharField(db_column='CountryName', unique=True, max_length=100)  

    class Meta:
        managed = False
        db_table = 'country'


class Customsclearance(models.Model):
    clearanceid = models.AutoField(db_column='ClearanceID', primary_key=True)  
    shipmentid = models.ForeignKey('Freightshipment', models.DO_NOTHING, db_column='ShipmentID')  
    checkpointstationid = models.ForeignKey('Station', models.DO_NOTHING, db_column='CheckpointStationID')  
    inspectiondate = models.DateTimeField(db_column='InspectionDate')  
    clearancestatus = models.CharField(db_column='ClearanceStatus', max_length=20)  
    documentref = models.CharField(db_column='DocumentRef', max_length=50, blank=True, null=True)  
    remarks = models.TextField(db_column='Remarks', blank=True, null=True)  

    class Meta:
        managed = False
        db_table = 'customsclearance'


class Dependent(models.Model):
    dependentid = models.AutoField(db_column='DependentID', primary_key=True)  
    mainpassengerid = models.ForeignKey('Passenger', models.DO_NOTHING, db_column='MainPassengerID')  
    firstname = models.CharField(db_column='FirstName', max_length=50)  
    lastname = models.CharField(db_column='LastName', max_length=50)  

    class Meta:
        managed = False
        db_table = 'dependent'


class DjangoAdminLog(models.Model):
    action_time = models.DateTimeField()
    object_id = models.TextField(blank=True, null=True)
    object_repr = models.CharField(max_length=200)
    action_flag = models.PositiveSmallIntegerField()
    change_message = models.TextField()
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING, blank=True, null=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'django_admin_log'


class DjangoContentType(models.Model):
    app_label = models.CharField(max_length=100)
    model = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'django_content_type'
        unique_together = (('app_label', 'model'),)


class DjangoMigrations(models.Model):
    id = models.BigAutoField(primary_key=True)
    app = models.CharField(max_length=255)
    name = models.CharField(max_length=255)
    applied = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_migrations'


class DjangoSession(models.Model):
    session_key = models.CharField(primary_key=True, max_length=40)
    session_data = models.TextField()
    expire_date = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_session'


class Freightshipment(models.Model):
    shipmentid = models.AutoField(db_column='ShipmentID', primary_key=True)  
    shippername = models.CharField(db_column='ShipperName', max_length=100)  
    originstationid = models.ForeignKey('Station', models.DO_NOTHING, db_column='OriginStationID')  
    deststationid = models.ForeignKey('Station', models.DO_NOTHING, db_column='DestStationID', related_name='freightshipment_deststationid_set')  
    cargotype = models.CharField(db_column='CargoType', max_length=50)  
    weightkg = models.DecimalField(db_column='WeightKG', max_digits=10, decimal_places=2)  
    containercount = models.IntegerField(db_column='ContainerCount')  
    currentstatus = models.CharField(db_column='CurrentStatus', max_length=30)  
    assignedtrainid = models.ForeignKey('Train', models.DO_NOTHING, db_column='AssignedTrainID', blank=True, null=True)  

    class Meta:
        managed = False
        db_table = 'freightshipment'


class Loyaltyclass(models.Model):
    classid = models.AutoField(db_column='ClassID', primary_key=True)  
    classname = models.CharField(db_column='ClassName', unique=True, max_length=20)  
    milesrequired = models.IntegerField(db_column='MilesRequired')  
    discountpercentage = models.DecimalField(db_column='DiscountPercentage', max_digits=5, decimal_places=2)  

    class Meta:
        managed = False
        db_table = 'loyaltyclass'


class Maintenancerecord(models.Model):
    recordid = models.AutoField(db_column='RecordID', primary_key=True)  
    targettype = models.CharField(db_column='TargetType', max_length=20)  
    trainid = models.ForeignKey('Train', models.DO_NOTHING, db_column='TrainID', blank=True, null=True)  
    trackid = models.ForeignKey('Tracksegment', models.DO_NOTHING, db_column='TrackID', blank=True, null=True)  
    stationid = models.ForeignKey('Station', models.DO_NOTHING, db_column='StationID', blank=True, null=True)  
    maintenancedate = models.DateField(db_column='MaintenanceDate')  
    maintenancestatus = models.CharField(db_column='MaintenanceStatus', max_length=20)  
    remarks = models.TextField(db_column='Remarks', blank=True, null=True)  

    class Meta:
        managed = False
        db_table = 'maintenancerecord'


class Passenger(models.Model):
    passengerid = models.AutoField(db_column='PassengerID', primary_key=True)  
    firstname = models.CharField(db_column='FirstName', max_length=50)  
    lastname = models.CharField(db_column='LastName', max_length=50)  
    email = models.CharField(db_column='Email', unique=True, max_length=100)  
    totalmiles = models.IntegerField(db_column='TotalMiles', blank=True, null=True)  
    classid = models.ForeignKey(Loyaltyclass, models.DO_NOTHING, db_column='ClassID', blank=True, null=True)  

    class Meta:
        managed = False
        db_table = 'passenger'
    
    def __str__(self):
        return f"{self.firstname} {self.lastname} (ID: {self.passengerid})"


class Reservation(models.Model):
    reservationid = models.AutoField(db_column='ReservationID', primary_key=True)  
    passengerid = models.ForeignKey(Passenger, models.DO_NOTHING, db_column='PassengerID')  
    trainid = models.ForeignKey('Train', models.DO_NOTHING, db_column='TrainID')  
    traveldate = models.DateField(db_column='TravelDate')  
    fromstationid = models.ForeignKey('Station', models.DO_NOTHING, db_column='FromStationID')  
    tostationid = models.ForeignKey('Station', models.DO_NOTHING, db_column='ToStationID', related_name='reservation_tostationid_set')  
    coachtype = models.CharField(db_column='CoachType', max_length=20)  
    seatnumber = models.CharField(db_column='SeatNumber', max_length=10)  
    ticketprice = models.DecimalField(db_column='TicketPrice', max_digits=10, decimal_places=2)  
    paymentstatus = models.CharField(db_column='PaymentStatus', max_length=20)  
    ticketstatus = models.CharField(db_column='TicketStatus', max_length=20)  
    dependent = models.ForeignKey('Dependent', models.SET_NULL, db_column='DependentID', blank=True, null=True)
    expiry_date = models.DateTimeField(db_column='ExpiryDate', blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'reservation'
        unique_together = (('trainid', 'traveldate', 'seatnumber'),)

    def __str__(self):
        return f"Res #{self.reservationid} - PassID: {self.passengerid} -> {self.trainid} ({self.traveldate})"


class Sensorreading(models.Model):
    readingid = models.AutoField(db_column='ReadingID', primary_key=True)  
    readingtype = models.CharField(db_column='ReadingType', max_length=50)  
    readingvalue = models.DecimalField(db_column='ReadingValue', max_digits=10, decimal_places=2)  
    trainid = models.ForeignKey('Train', models.DO_NOTHING, db_column='TrainID', blank=True, null=True)  
    trackid = models.ForeignKey('Tracksegment', models.DO_NOTHING, db_column='TrackID', blank=True, null=True)  
    readingtime = models.DateTimeField(db_column='ReadingTime')  
    isnormal = models.IntegerField(db_column='IsNormal', blank=True, null=True)  

    class Meta:
        managed = False
        db_table = 'sensorreading'


class Staff(models.Model):
    staffid = models.AutoField(db_column='StaffID', primary_key=True)  
    firstname = models.CharField(db_column='FirstName', max_length=50)  
    lastname = models.CharField(db_column='LastName', max_length=50)  
    jobrole = models.CharField(db_column='JobRole', max_length=50)  

    class Meta:
        managed = False
        db_table = 'staff'

    def __str__(self):
        return f"{self.firstname} {self.lastname} ({self.jobrole})"


class Staffassignment(models.Model):
    assignmentid = models.AutoField(db_column='AssignmentID', primary_key=True)  
    staffid = models.ForeignKey(Staff, models.DO_NOTHING, db_column='StaffID')  
    trainid = models.ForeignKey('Train', models.DO_NOTHING, db_column='TrainID')  
    assignmentdate = models.DateField(db_column='AssignmentDate')  
    roleontrain = models.CharField(db_column='RoleOnTrain', max_length=50, blank=True, null=True)  

    class Meta:
        managed = False
        db_table = 'staffassignment'
        unique_together = (('staffid', 'assignmentdate'),)

    def __str__(self):
        return f"Assignment #{self.assignmentid}: Staff #{self.staffid} on {self.trainid}"


class Station(models.Model):
    stationid = models.AutoField(db_column='StationID', primary_key=True)  
    countryid = models.ForeignKey(Country, models.DO_NOTHING, db_column='CountryID')  
    stationname = models.CharField(db_column='StationName', max_length=150)  
    stationtype = models.CharField(db_column='StationType', max_length=50)  

    class Meta:
        managed = False
        db_table = 'station'

    def __str__(self):
        return f"{self.stationname} [{self.stationtype}]"


class Tracksegment(models.Model):
    trackid = models.AutoField(db_column='TrackID', primary_key=True)  
    stationa = models.ForeignKey(Station, models.DO_NOTHING, db_column='StationA_ID')  
    stationb = models.ForeignKey(Station, models.DO_NOTHING, db_column='StationB_ID', related_name='tracksegment_stationb_set')  
    distancekm = models.DecimalField(db_column='DistanceKM', max_digits=6, decimal_places=2)  
    iselectrified = models.IntegerField(db_column='IsElectrified', blank=True, null=True)  
    trackstatus = models.CharField(db_column='TrackStatus', max_length=20)  

    class Meta:
        managed = False
        db_table = 'tracksegment'


class Train(models.Model):
    trainid = models.CharField(db_column='TrainID', primary_key=True, max_length=20)  
    trainname = models.CharField(db_column='TrainName', max_length=100)  
    traintype = models.CharField(db_column='TrainType', max_length=50)  
    maxpassengerspeed = models.IntegerField(db_column='MaxPassengerSpeed', blank=True, null=True)  
    maxfreightspeed = models.IntegerField(db_column='MaxFreightSpeed', blank=True, null=True)  

    class Meta:
        managed = False
        db_table = 'train'

    def __str__(self):
        return f"{self.trainname} ({self.trainid})"


class Trainschedule(models.Model):
    scheduleid = models.AutoField(db_column='ScheduleID', primary_key=True)  
    trainid = models.ForeignKey(Train, models.DO_NOTHING, db_column='TrainID')  
    stationid = models.ForeignKey(Station, models.DO_NOTHING, db_column='StationID')  
    stoporder = models.IntegerField(db_column='StopOrder')  
    arrivaltime = models.DateTimeField(db_column='ArrivalTime', blank=True, null=True)  
    departuretime = models.DateTimeField(db_column='DepartureTime', blank=True, null=True)  

    class Meta:
        managed = False
        db_table = 'trainschedule'
        unique_together = (('trainid', 'stoporder'),)

    def __str__(self):
        return f"{self.trainid} - Stop {self.stoporder}: Station #{self.stationid}"


class Waitinglist(models.Model):
    waitlistid = models.AutoField(db_column='WaitlistID', primary_key=True)  
    passengerid = models.ForeignKey(Passenger, models.DO_NOTHING, db_column='PassengerID')  
    trainid = models.ForeignKey(Train, models.DO_NOTHING, db_column='TrainID')  
    traveldate = models.DateField(db_column='TravelDate')  

    class Meta:
        managed = False
        db_table = 'waitinglist'


class Luggage(models.Model):
    luggage_id = models.AutoField(db_column='LuggageID', primary_key=True)
    reservation = models.ForeignKey('Reservation', models.CASCADE, db_column='ReservationID')
    weight_kg = models.DecimalField(db_column='WeightKG', max_digits=5, decimal_places=2)
    bag_count = models.IntegerField(db_column='BagCount', default=1)

    class Meta:
        managed = False
        db_table = 'Luggage'

    def __str__(self):
        return f"Luggage #{self.luggage_id} - Res: {self.reservation} ({self.weight_kg} kg)"


class UserProfile(models.Model):
    """Bridge model connecting Django auth User to the Passenger table."""
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    passenger = models.OneToOneField(
        Passenger, on_delete=models.SET_NULL,
        null=True, blank=True,
        db_column='PassengerID',
        related_name='user_profile'
    )
    is_admin = models.BooleanField(default=False)

    class Meta:
        db_table = 'user_profile'

    def __str__(self):
        return f"Profile: {self.user.username} (Admin: {self.is_admin})"