"""
URL configuration for config project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/6.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from .views import home
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView
from tickets.views import TicketViewSet, statistics_view, dashboard_view
from accounts.views import (
    CustomTokenObtainPairView,
    RegisterView,
    ProfileView,
    user_list_view,
    user_detail_view,
    user_role_update,
    user_toggle_active,
)

# Routeur DRF pour les ViewSets
router = DefaultRouter()
router.register(r'tickets', TicketViewSet, basename='ticket')

urlpatterns = [
    path('', home, name='home'),
    # Admin
    path('admin/', admin.site.urls),

    # Authentification JWT
    path('api/auth/login/', CustomTokenObtainPairView.as_view(), name='token_obtain'),
    path('api/auth/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/auth/register/', RegisterView.as_view(), name='register'),
    path('api/auth/profil/', ProfileView.as_view(), name='profil'),

    # API users (pour ADMIN)
    path('api/users/', user_list_view, name='user-list'),
    path('api/users/<int:pk>/', user_detail_view, name='user-detail'),
    path('api/users/<int:pk>/role/', user_role_update, name='user-role'),
    path('api/users/<int:pk>/toggle-active/', user_toggle_active, name='user-toggle-active'),

    # API tickets (ViewSet)
    path('api/', include(router.urls)),
    
    # Dashboard et statistiques
    path('api/dashboard/', dashboard_view, name='dashboard'),
    path('api/statistics/', statistics_view, name='statistics'),
]