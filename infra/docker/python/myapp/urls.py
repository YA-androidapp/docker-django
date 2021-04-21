from django.urls import path
from . import views

app_name = 'myapp'

urlpatterns = [
    path('profile/', views.ProfileView.as_view(), name='profile'),
    path('', views.WelcomeView.as_view(), name='welcome'),
]
