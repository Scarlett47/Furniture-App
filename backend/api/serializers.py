from rest_framework import serializers
from .models import *
from django.contrib.auth.hashers import make_password

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'phone', 'address', 'account_pic', 'is_admin']
        extra_kwargs = {'password': {'write_only': True}}
    
    def create(self, validated_data):
        validated_data['password'] = make_password(validated_data['password'])
        return super().create(validated_data)

class FurnitureCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = FurnitureCategory
        fields = '__all__'

class FurnitureSerializer(serializers.ModelSerializer):
    category = FurnitureCategorySerializer(read_only=True)
    is_liked = serializers.SerializerMethodField()
    
    class Meta:
        model = Furniture
        fields = '__all__'
    
    def get_is_liked(self, obj):
        user = self.context.get('request').user
        return user.is_authenticated and user.liked_furniture.filter(id=obj.id).exists()

class OrderItemSerializer(serializers.ModelSerializer):
    furniture = FurnitureSerializer(read_only=True)
    
    class Meta:
        model = OrderItem
        fields = '__all__'

class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = Order
        fields = '__all__'

class ReviewSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = Review
        fields = '__all__'