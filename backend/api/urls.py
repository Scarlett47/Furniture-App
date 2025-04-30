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
    path('login/', LoginView.as_view(), name='api-login'),
    path('logout/', logout_view, name='api-logout'),
    path('register/', RegisterView.as_view(), name='api-register'),
    path('user/', UserProfileView.as_view(), name='api-user'),
    path('validate-token/', validate_token, name='validate-token'),
    path('users/me/', current_user, name='current-user'),

]