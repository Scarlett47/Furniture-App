# api/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import *

router = DefaultRouter()
router.register(r'users', UserViewSet, basename='user')
router.register(r'categories', FurnitureCategoryViewSet, basename='category')
router.register(r'furniture', FurnitureViewSet, basename='furniture')
router.register(r'orders', OrderViewSet, basename='order')
router.register(r'reviews', ReviewViewSet, basename='review')

urlpatterns = [
    path('', include(router.urls)),
    path('auth/', include('rest_framework.urls')),
    path('api/auth/login/', LoginView.as_view(), name='api-login'),
    path('api/auth/logout/', LogoutView.as_view(), name='api-logout'),
    path('api/auth/register/', RegisterView.as_view(), name='api-register'),
    path('api/auth/user/', UserProfileView.as_view(), name='api-user'),
]