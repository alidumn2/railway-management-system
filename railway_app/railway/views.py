from django.shortcuts import render, redirect, get_object_or_404
from django.contrib import messages
from django.contrib.auth import login, authenticate, logout
from django.contrib.auth.decorators import login_required
from django.db.models import Sum, Count
from collections import OrderedDict
from .models import Train, Station, Reservation, Passenger, Staff, UserProfile, Trainschedule
from .forms import UserRegistrationForm, AdminRegistrationForm
from datetime import datetime


# ── Helper: Admin required decorator ─────────────────────────────

def admin_required(view_func):
    """Decorator: requires login + is_staff."""
    def wrapper(request, *args, **kwargs):
        if not request.user.is_authenticated:
            return redirect('login')
        if not request.user.is_staff:
            messages.error(request, "Access denied. Admin privileges required.")
            return redirect('dashboard')
        return view_func(request, *args, **kwargs)
    return wrapper


# ── Authentication Views ──────────────────────────────────────────

def user_login(request):
    if request.user.is_authenticated:
        return redirect('dashboard')
    
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        user = authenticate(request, username=username, password=password)
        
        if user is not None:
            login(request, user)
            messages.success(request, f"Welcome back, {user.first_name or user.username}!")
            if user.is_staff:
                return redirect('admin_dashboard')
            return redirect('dashboard')
        else:
            messages.error(request, "Invalid username or password.")
    
    return render(request, 'railway/login.html')


def user_logout(request):
    logout(request)
    messages.success(request, "You have been logged out successfully.")
    return redirect('search_trains')


def user_register(request):
    if request.user.is_authenticated:
        return redirect('dashboard')
    
    if request.method == 'POST':
        form = UserRegistrationForm(request.POST)
        if form.is_valid():
            user = form.save(commit=False)
            user.first_name = form.cleaned_data['first_name']
            user.last_name = form.cleaned_data['last_name']
            user.save()
            
            passenger = Passenger.objects.create(
                firstname=user.first_name,
                lastname=user.last_name,
                email=user.email,
                totalmiles=0
            )
            
            UserProfile.objects.create(
                user=user, passenger=passenger, is_admin=False
            )
            
            messages.success(request, "Account created successfully! Please log in.")
            return redirect('login')
    else:
        form = UserRegistrationForm()
    
    return render(request, 'railway/register.html', {'form': form})


def admin_register(request):
    if request.user.is_authenticated:
        return redirect('admin_dashboard')
    
    if request.method == 'POST':
        form = AdminRegistrationForm(request.POST)
        if form.is_valid():
            user = form.save(commit=False)
            user.first_name = form.cleaned_data['first_name']
            user.last_name = form.cleaned_data['last_name']
            user.is_staff = True
            user.save()
            
            UserProfile.objects.create(
                user=user, passenger=None, is_admin=True
            )
            
            messages.success(request, "Admin account created! Please log in.")
            return redirect('login')
    else:
        form = AdminRegistrationForm()
    
    return render(request, 'railway/register_admin.html', {'form': form})


# ── User Dashboard ───────────────────────────────────────────────

@login_required
def user_dashboard(request):
    profile = getattr(request.user, 'profile', None)
    passenger = profile.passenger if profile else None
    
    reservations = []
    total_reservations = 0
    active_reservations = 0
    loyalty_class = None
    total_miles = 0
    
    if passenger:
        reservations = Reservation.objects.filter(
            passengerid=passenger
        ).select_related('trainid', 'fromstationid', 'tostationid').order_by('-traveldate')
        
        total_reservations = reservations.count()
        active_reservations = reservations.exclude(paymentstatus='Canceled').count()
        total_miles = passenger.totalmiles or 0
        
        if passenger.classid:
            loyalty_class = passenger.classid.classname
    
    return render(request, 'railway/dashboard.html', {
        'reservations': reservations,
        'total_reservations': total_reservations,
        'active_reservations': active_reservations,
        'loyalty_class': loyalty_class,
        'total_miles': total_miles,
    })


# ── Admin Dashboard ──────────────────────────────────────────────

@admin_required
def admin_dashboard(request):
    total_trains = Train.objects.count()
    total_reservations = Reservation.objects.count()
    total_passengers = Passenger.objects.count()
    
    revenue_data = Reservation.objects.filter(
        paymentstatus='Paid'
    ).aggregate(total=Sum('ticketprice'))
    total_revenue = revenue_data['total'] or 0
    
    recent_reservations = Reservation.objects.select_related(
        'passengerid', 'trainid'
    ).order_by('-reservationid')[:10]
    
    trains = Train.objects.all()
    staff_members = Staff.objects.all()
    
    return render(request, 'railway/admin_dashboard.html', {
        'total_trains': total_trains,
        'total_reservations': total_reservations,
        'total_passengers': total_passengers,
        'total_revenue': total_revenue,
        'recent_reservations': recent_reservations,
        'trains': trains,
        'staff_members': staff_members,
    })


# ── Admin: Passenger Management ─────────────────────────────────

@admin_required
def admin_passengers(request):
    passengers = Passenger.objects.select_related('classid').annotate(
        reservation_count=Count('reservation')
    ).order_by('passengerid')
    return render(request, 'railway/admin_passengers.html', {'passengers': passengers})


@admin_required
def admin_delete_passenger(request, passenger_id):
    if request.method == 'POST':
        passenger = get_object_or_404(Passenger, passengerid=passenger_id)
        name = f"{passenger.firstname} {passenger.lastname}"
        passenger.delete()
        messages.success(request, f"Passenger '{name}' deleted successfully.")
    return redirect('admin_passengers')


# ── Admin: Train Management ──────────────────────────────────────

@admin_required
def admin_trains(request):
    trains = Train.objects.all().order_by('trainid')
    return render(request, 'railway/admin_trains.html', {'trains': trains})


@admin_required
def admin_add_train(request):
    if request.method == 'POST':
        train_id = request.POST.get('train_id', '').strip()
        train_name = request.POST.get('train_name', '').strip()
        train_type = request.POST.get('train_type', 'Passenger')
        max_pax = int(request.POST.get('max_pax_speed', 0))
        max_freight = int(request.POST.get('max_freight_speed', 0))
        seat_count = int(request.POST.get('seat_count', 60))
        
        if Train.objects.filter(trainid=train_id).exists():
            messages.error(request, f"Train ID '{train_id}' already exists!")
        else:
            Train.objects.create(
                trainid=train_id,
                trainname=train_name,
                traintype=train_type,
                maxpassengerspeed=max_pax,
                maxfreightspeed=max_freight,
                seatcount=seat_count
            )
            messages.success(request, f"Train '{train_name}' added successfully!")
    return redirect('admin_trains')


@admin_required
def admin_edit_train(request, train_id):
    if request.method == 'POST':
        train = get_object_or_404(Train, trainid=train_id)
        train.trainname = request.POST.get('train_name', train.trainname)
        train.maxpassengerspeed = int(request.POST.get('max_pax_speed', 0))
        train.maxfreightspeed = int(request.POST.get('max_freight_speed', 0))
        train.seatcount = int(request.POST.get('seat_count', 60))
        train.save()
        messages.success(request, f"Train '{train.trainname}' updated!")
    return redirect('admin_trains')


@admin_required
def admin_delete_train(request, train_id):
    if request.method == 'POST':
        train = get_object_or_404(Train, trainid=train_id)
        name = train.trainname
        train.delete()
        messages.success(request, f"Train '{name}' deleted.")
    return redirect('admin_trains')


# ── Admin: Reservation Management ────────────────────────────────

@admin_required
def admin_reservations(request):
    reservations = Reservation.objects.select_related(
        'passengerid', 'trainid', 'fromstationid', 'tostationid'
    ).order_by('-reservationid')
    
    paid_count = reservations.filter(paymentstatus='Paid').count()
    pending_count = reservations.filter(paymentstatus='Pending').count()
    canceled_count = reservations.filter(paymentstatus='Canceled').count()
    
    return render(request, 'railway/admin_reservations.html', {
        'reservations': reservations,
        'paid_count': paid_count,
        'pending_count': pending_count,
        'canceled_count': canceled_count,
    })


@admin_required
def admin_cancel_reservation(request, reservation_id):
    if request.method == 'POST':
        res = get_object_or_404(Reservation, reservationid=reservation_id)
        res.paymentstatus = 'Canceled'
        res.ticketstatus = 'Canceled'
        res.save()
        messages.success(request, f"Reservation #{reservation_id} canceled.")
    return redirect('admin_reservations')


@admin_required
def admin_delete_reservation(request, reservation_id):
    if request.method == 'POST':
        res = get_object_or_404(Reservation, reservationid=reservation_id)
        res.delete()
        messages.success(request, f"Reservation #{reservation_id} permanently deleted.")
    return redirect('admin_reservations')


# ── Admin: Schedule Management ───────────────────────────────────

@admin_required
def admin_schedules(request):
    schedules = Trainschedule.objects.select_related(
        'trainid', 'stationid'
    ).order_by('trainid', 'stoporder')
    
    grouped = OrderedDict()
    for s in schedules:
        key = s.trainid_id
        if key not in grouped:
            grouped[key] = []
        grouped[key].append(s)
    
    trains = Train.objects.all().order_by('trainid')
    stations = Station.objects.all().order_by('stationname')
    
    return render(request, 'railway/admin_schedules.html', {
        'grouped_schedules': grouped,
        'trains': trains,
        'stations': stations,
    })


@admin_required
def admin_add_schedule(request):
    if request.method == 'POST':
        train_id = request.POST.get('train_id')
        station_id = request.POST.get('station_id')
        stop_order = int(request.POST.get('stop_order', 1))
        arrival = request.POST.get('arrival_time') or None
        departure = request.POST.get('departure_time') or None
        
        if Trainschedule.objects.filter(trainid=train_id, stoporder=stop_order).exists():
            messages.error(request, f"Stop order {stop_order} already exists for this train!")
        else:
            Trainschedule.objects.create(
                trainid_id=train_id,
                stationid_id=station_id,
                stoporder=stop_order,
                arrivaltime=arrival,
                departuretime=departure
            )
            messages.success(request, "Schedule entry added!")
    return redirect('admin_schedules')


@admin_required
def admin_delete_schedule(request, schedule_id):
    if request.method == 'POST':
        entry = get_object_or_404(Trainschedule, scheduleid=schedule_id)
        entry.delete()
        messages.success(request, "Schedule entry deleted.")
    return redirect('admin_schedules')


# ── Public Views ──────────────────────────────────────────────────

def search_trains(request):
    stations = Station.objects.all().select_related('countryid')
    train_results = []
    
    from_station = request.GET.get('from_station')
    to_station = request.GET.get('to_station')
    travel_date = request.GET.get('travel_date')
    all_trains = request.GET.get('all_trains')
    from_station_name = ''
    to_station_name = ''
    
    if all_trains == '1':
        # Show all passenger trains with route info from schedule
        trains = Train.objects.filter(traintype='Passenger')
        for t in trains:
            stops = Trainschedule.objects.filter(trainid=t).select_related('stationid').order_by('stoporder')
            first_stop = stops.first()
            last_stop = stops.last()
            train_results.append({
                'train': t,
                'from_station_name': first_stop.stationid.stationname if first_stop else 'N/A',
                'to_station_name': last_stop.stationid.stationname if last_stop and last_stop != first_stop else 'N/A',
                'departure_time': first_stop.departuretime if first_stop else None,
                'arrival_time': last_stop.arrivaltime if last_stop else None,
            })
    elif from_station and to_station:
        try:
            from_st_id = int(from_station)
            to_st_id = int(to_station)
            
            # Get station names for display
            from_st_obj = Station.objects.filter(stationid=from_st_id).first()
            to_st_obj = Station.objects.filter(stationid=to_st_id).first()
            from_station_name = from_st_obj.stationname if from_st_obj else ''
            to_station_name = to_st_obj.stationname if to_st_obj else ''
            
            from_schedules = Trainschedule.objects.filter(stationid=from_st_id)
            to_schedules = Trainschedule.objects.filter(stationid=to_st_id)
            
            valid_train_dicts = []
            
            for f_sch in from_schedules:
                matching_to = to_schedules.filter(trainid=f_sch.trainid_id, stoporder__gt=f_sch.stoporder).first()
                if matching_to:
                    valid_train_dicts.append({
                        'train_id': f_sch.trainid_id,
                        'departure_time': f_sch.departuretime or f_sch.arrivaltime,
                        'arrival_time': matching_to.arrivaltime or matching_to.departuretime
                    })
            
            train_objs = Train.objects.filter(trainid__in=[d['train_id'] for d in valid_train_dicts], traintype='Passenger')
            
            for d in valid_train_dicts:
                t_obj = next((t for t in train_objs if t.trainid == d['train_id']), None)
                if t_obj:
                    train_results.append({
                        'train': t_obj,
                        'from_station_name': from_station_name,
                        'to_station_name': to_station_name,
                        'departure_time': d['departure_time'],
                        'arrival_time': d['arrival_time']
                    })
            
        except ValueError:
            pass
            
    return render(request, 'railway/search.html', {
        'stations': stations,
        'train_results': train_results,
        'from_station': from_station,
        'to_station': to_station,
        'travel_date': travel_date,
        'all_trains': all_trains,
        'from_station_name': from_station_name,
        'to_station_name': to_station_name,
    })


@login_required
def book_seat(request):
    if request.method == 'POST':
        # Check if user is a passenger
        profile = getattr(request.user, 'profile', None)
        if not profile or getattr(profile, 'is_admin', False) or not profile.passenger:
            messages.error(request, "Only registered passengers can book tickets. Staff cannot book seats.")
            return redirect('search_trains')
            
        passenger = profile.passenger
        passenger_id = passenger.passengerid
        
        train_id = request.POST.get('train_id')
        travel_date = request.POST.get('travel_date')
        seat_number = request.POST.get('seat_number')
        from_station_id = request.POST.get('from_station')
        to_station_id = request.POST.get('to_station')
        
        seat_taken = Reservation.objects.filter(
            trainid=train_id,
            traveldate=travel_date,
            seatnumber=seat_number
        ).exclude(paymentstatus='Canceled').exists()
        
        if seat_taken:
            messages.error(request, "This seat is already reserved for the selected train and date!")
            return redirect('search_trains')
            
        new_reservation = Reservation.objects.create(
            passengerid_id=passenger_id,
            trainid_id=train_id,
            traveldate=travel_date,
            fromstationid_id=from_station_id,
            tostationid_id=to_station_id,
            coachtype='Economy',
            seatnumber=seat_number,
            ticketprice=450.00,
            paymentstatus='Pending'
        )
        
        messages.success(request, f"Reservation successfully created! Booking ID: {new_reservation.reservationid}")
        return redirect('dashboard')
        
    return redirect('search_trains')