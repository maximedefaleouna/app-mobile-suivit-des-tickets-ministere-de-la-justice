from rest_framework import serializers
from .models import CustomUser


class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True, style={'input_type': 'password'})
    
    class Meta:
        model = CustomUser
        fields = [
            'id',
            'username',
            'email',
            'first_name',
            'last_name',
            'role',
            'telephone',
            'password',
            'is_active',
            'date_joined',
        ]
        read_only_fields = ['id', 'is_active', 'date_joined']
    
    def create(self, validated_data):
        """Crée un utilisateur avec mot de passe haché"""
        password = validated_data.pop('password')
        user = CustomUser(**validated_data)
        user.set_password(password)  # Hache le mot de passe
        user.save()
        return user
    
    def update(self, instance, validated_data):
        """Met à jour un utilisateur avec hachage du mot de passe si fourni"""
        password = validated_data.pop('password', None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        if password:
            instance.set_password(password)
        instance.save()
        return instance
