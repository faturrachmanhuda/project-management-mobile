import jwt
from datetime import datetime, timedelta
from django.conf import settings
from rest_framework import authentication, exceptions
from .models import User


def generate_jwt(user):
    """Generate JWT token for user"""
    payload = {
        'user_id': str(user.id),
        'email': user.email,
        'exp': datetime.utcnow() + timedelta(days=settings.JWT_EXPIRATION_DAYS),
        'iat': datetime.utcnow()
    }
    token = jwt.encode(payload, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)
    return token


def decode_jwt(token):
    """Decode JWT token"""
    try:
        payload = jwt.decode(token, settings.JWT_SECRET_KEY, algorithms=[settings.JWT_ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise exceptions.AuthenticationFailed('Token telah kadaluarsa')
    except jwt.InvalidTokenError:
        raise exceptions.AuthenticationFailed('Token tidak valid')


class JWTAuthentication(authentication.BaseAuthentication):
    """Custom JWT Authentication"""

    def authenticate(self, request):
        auth_header = request.headers.get('Authorization')

        if not auth_header:
            return None

        try:
            prefix, token = auth_header.split(' ')
            if prefix.lower() != 'bearer':
                return None
        except ValueError:
            raise exceptions.AuthenticationFailed('Format header Authorization tidak valid')

        payload = decode_jwt(token)

        try:
            user = User.objects.get(id=payload['user_id'])
        except User.DoesNotExist:
            raise exceptions.AuthenticationFailed('User tidak ditemukan')

        if not user.is_active:
            raise exceptions.AuthenticationFailed('User tidak aktif')

        return (user, token)

    def authenticate_header(self, request):
        return 'Bearer'
