from django.urls import path
from . import views

urlpatterns = [
    # Search & Booking
    path('search/', views.search_trains, name='search_trains'),
    path('book/', views.book_seat, name='book_seat'),
    
    # Authentication
    path('login/', views.user_login, name='login'),
    path('logout/', views.user_logout, name='logout'),
    path('register/', views.user_register, name='register'),
    path('register/admin/', views.admin_register, name='register_admin'),
    
    # User Dashboard
    path('dashboard/', views.user_dashboard, name='dashboard'),
    
    # Admin Dashboard
    path('admin-dashboard/', views.admin_dashboard, name='admin_dashboard'),
    
    # Admin: Passengers
    path('admin-dashboard/passengers/', views.admin_passengers, name='admin_passengers'),
    path('admin-dashboard/passengers/<int:passenger_id>/delete/', views.admin_delete_passenger, name='admin_delete_passenger'),
    
    # Admin: Trains
    path('admin-dashboard/trains/', views.admin_trains, name='admin_trains'),
    path('admin-dashboard/trains/add/', views.admin_add_train, name='admin_add_train'),
    path('admin-dashboard/trains/<str:train_id>/edit/', views.admin_edit_train, name='admin_edit_train'),
    path('admin-dashboard/trains/<str:train_id>/delete/', views.admin_delete_train, name='admin_delete_train'),
    
    # Admin: Reservations
    path('admin-dashboard/reservations/', views.admin_reservations, name='admin_reservations'),
    path('admin-dashboard/reservations/<int:reservation_id>/cancel/', views.admin_cancel_reservation, name='admin_cancel_reservation'),
    path('admin-dashboard/reservations/<int:reservation_id>/delete/', views.admin_delete_reservation, name='admin_delete_reservation'),
    
    # Admin: Schedules
    path('admin-dashboard/schedules/', views.admin_schedules, name='admin_schedules'),
    path('admin-dashboard/schedules/add/', views.admin_add_schedule, name='admin_add_schedule'),
    path('admin-dashboard/schedules/<int:schedule_id>/delete/', views.admin_delete_schedule, name='admin_delete_schedule'),
]