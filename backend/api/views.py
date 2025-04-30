from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import action, permission_classes
from rest_framework.views import APIView
from django.contrib.auth import authenticate, logout
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import ensure_csrf_cookie, csrf_exempt
from rest_framework.authtoken.models import Token
from django.contrib.auth import get_user_model
from .models import *
from .serializers import *
from rest_framework.permissions import IsAuthenticated
from rest_framework.authtoken.models import Token
from rest_framework.decorators import api_view

User = get_user_model()


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def validate_token(request):
    return Response({
        'valid': True,
        'user': {
            'id': request.user.id,
            'email': request.user.email,
            'username': request.user.username
        }
    })

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout_view(request):
    request.user.auth_token.delete()
    return Response({'success': True})

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def current_user(request):
    return Response({
        'id': request.user.id,
        'username': request.user.username,
        'email': request.user.email
    })

@method_decorator(csrf_exempt, name='dispatch')
class ValidateTokenView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        return Response({
            'success': True,
            'user': {
                'id': request.user.id,
                'email': request.user.email,
                'username': request.user.username,
            }
        })

@method_decorator(csrf_exempt, name='dispatch')
class LoginView(APIView):
    authentication_classes = []  # Disable authentication
    permission_classes = []  # Disable permission checks

    def post(self, request):
        email = request.data.get('email', '').strip()
        password = request.data.get('password', '')
        
        # Check if both email and password are provided
        if not email or not password:
            return Response(
                {'success': False, 'error': 'Please provide both email and password'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Try with email parameter (Django's default)
        user = authenticate(request, username=email, password=password)

        # If the first authentication fails, try with email instead of username
        if not user:
            try:
                user = User.objects.get(email=email)
                user = authenticate(request, username=user.username, password=password)
            except User.DoesNotExist:
                return Response(
                    {'success': False, 'error': 'Invalid credentials'},
                    status=status.HTTP_401_UNAUTHORIZED
                )

        # If authentication still fails, return error
        if not user:
            return Response(
                {'success': False, 'error': 'Invalid credentials'},
                status=status.HTTP_401_UNAUTHORIZED
            )
        
        # Generate and return a token for the authenticated user
        token, _ = Token.objects.get_or_create(user=user)

        return Response({
            'success': True,
            'token': token.key,  # Return token in response
            'user': {
                'id': user.id,
                'email': user.email,
                'username': user.username,
            }
        })

class LogoutView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def post(self, request):
        try:
            request.user.auth_token.delete()
            logout(request)
            return Response({'success': 'Successfully logged out'})
        except Exception as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

class RegisterView(APIView):
    authentication_classes = []  # Disable authentication
    permission_classes = []  
    
    def post(self, request):
        email = request.data.get('email')
        password = request.data.get('password')
        username = request.data.get('username')
        
        if not all([email, password, username]):
            return Response(
                {'error': 'Please provide email, username and password'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        if User.objects.filter(email=email).exists():
            return Response(
                {'error': 'Email already exists'},
                status=status.HTTP_400_BAD_REQUEST
            )
            
        if User.objects.filter(username=username).exists():
            return Response(
                {'error': 'Username already exists'},
                status=status.HTTP_400_BAD_REQUEST
            )
            
        user = User.objects.create_user(
            username=username,
            email=email,
            password=password
        )
        
        token = Token.objects.create(user=user)
        return Response({
            'token': token.key,
            'user': UserSerializer(user).data
        }, status=status.HTTP_201_CREATED)

class UserProfileView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data)

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def get_permissions(self):
        if self.action in ['create', 'retrieve']:
            return [permissions.AllowAny()]
        return [permissions.IsAuthenticated()]

    @action(detail=False, methods=['get', 'put'])
    def me(self, request):
        user = request.user
        if request.method == 'GET':
            serializer = self.get_serializer(user)
            return Response(serializer.data)
        elif request.method == 'PUT':
            serializer = self.get_serializer(user, data=request.data, partial=True)
            serializer.is_valid(raise_exception=True)
            serializer.save()
            return Response(serializer.data)

class FurnitureCategoryViewSet(viewsets.ModelViewSet):
    queryset = FurnitureCategory.objects.all()
    serializer_class = FurnitureCategorySerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

class FurnitureViewSet(viewsets.ModelViewSet):
    queryset = Furniture.objects.all()
    serializer_class = FurnitureSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    
    def get_serializer_context(self):
        return {'request': self.request}
    
    @action(detail=True, methods=['post'])
    def toggle_like(self, request, pk=None):
        furniture = self.get_object()
        user = request.user
        
        if user in furniture.liked_by.all():
            furniture.liked_by.remove(user)
            liked = False
        else:
            furniture.liked_by.add(user)
            liked = True
        
        return Response({'liked': liked})

class OrderViewSet(viewsets.ModelViewSet):
    queryset = Order.objects.all()
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return self.queryset.filter(user=self.request.user)

class ReviewViewSet(viewsets.ModelViewSet):
    serializer_class = ReviewSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Review.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)