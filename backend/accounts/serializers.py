from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from rest_framework import serializers

from .models import UserProfile


class UserSerializer(serializers.ModelSerializer):
    first_name = serializers.SerializerMethodField()
    last_name = serializers.SerializerMethodField()
    is_admin = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            'id',
            'username',
            'email',
            'first_name',
            'last_name',
            'is_admin',
        ]
        read_only_fields = ['id', 'username', 'is_admin']

    def _profile(self, user: User) -> UserProfile | None:
        return getattr(user, 'profile', None)

    def get_first_name(self, user: User) -> str:
        profile = self._profile(user)
        if profile and profile.first_name:
            return profile.first_name
        return user.first_name

    def get_last_name(self, user: User) -> str:
        profile = self._profile(user)
        if profile and profile.last_name:
            return profile.last_name
        return user.last_name

    def get_is_admin(self, user: User) -> bool:
        return user.is_staff or user.is_superuser or user.username == 'admin'


class RegisterSerializer(serializers.Serializer):
    username = serializers.CharField(max_length=150)
    email = serializers.EmailField()
    password = serializers.CharField(min_length=6, write_only=True)
    first_name = serializers.CharField(required=False, allow_blank=True, default='')
    last_name = serializers.CharField(required=False, allow_blank=True, default='')

    def validate_username(self, value: str) -> str:
        if User.objects.filter(username__iexact=value).exists():
            raise serializers.ValidationError('Username sudah dipakai.')
        return value

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password'],
        )
        UserProfile.objects.create(
            user=user,
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', ''),
        )
        return user


class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)

    def validate(self, attrs):
        user = authenticate(
            username=attrs['username'],
            password=attrs['password'],
        )
        if not user:
            raise serializers.ValidationError('Username atau password salah.')
        attrs['user'] = user
        return attrs


class ProfileUpdateSerializer(serializers.Serializer):
    first_name = serializers.CharField(required=False, allow_blank=True)
    last_name = serializers.CharField(required=False, allow_blank=True)
    email = serializers.EmailField(required=False)

    def update(self, instance: User, validated_data):
        profile, _ = UserProfile.objects.get_or_create(user=instance)
        if 'first_name' in validated_data:
            profile.first_name = validated_data['first_name']
            instance.first_name = validated_data['first_name']
        if 'last_name' in validated_data:
            profile.last_name = validated_data['last_name']
            instance.last_name = validated_data['last_name']
        if 'email' in validated_data:
            instance.email = validated_data['email']
        profile.save()
        instance.save()
        return instance
