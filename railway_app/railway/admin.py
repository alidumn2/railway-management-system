from django.contrib import admin
from .models import Train, Station, Passenger, Reservation, Staff, Staffassignment, Trainschedule, Luggage

admin.site.register(Train)
admin.site.register(Station)
admin.site.register(Passenger)
admin.site.register(Reservation)
admin.site.register(Staff)
admin.site.register(Staffassignment)
admin.site.register(Trainschedule)
admin.site.register(Luggage)