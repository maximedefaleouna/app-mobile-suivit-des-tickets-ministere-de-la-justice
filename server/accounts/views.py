from rest_framework import generics, permissions, status, viewsets
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenObtainPairView
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404
from .models import CustomUser
from .serializers import UserSerializer
from rest_framework.permissions import IsAuthenticated, AllowAny


class CustomTokenObtainPairView(TokenObtainPairView):
    """Vue personnalisée pour obtenir les tokens JWT - accessible à tous les utilisateurs"""
    permission_classes = [permissions.AllowAny]


class RegisterView(generics.CreateAPIView):
    """Inscription d'un nouvel utilisateur (Citoyen)"""
    queryset = CustomUser.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.AllowAny]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        
        # Validation des données
        if not serializer.is_valid():
            return Response(
                {'errors': serializer.errors},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Vérifier la force du mot de passe
        password = request.data.get('password')
        try:
            validate_password(password)
        except ValidationError as e:
            return Response(
                {'password_errors': list(e.messages)},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Vérifier que l'email n'existe pas déjà
        email = request.data.get('email')
        if CustomUser.objects.filter(email=email).exists():
            return Response(
                {'email': 'Cet email est déjà utilisé'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Créer l'utilisateur avec le rôle CITOYEN par défaut
        user = serializer.save()
        user.role = CustomUser.Role.CITOYEN
        user.save()
        
        # Générer les tokens JWT
        refresh = RefreshToken.for_user(user)
        
        return Response({
            'user': UserSerializer(user).data,
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'message': 'Compte créé avec succès'
        }, status=status.HTTP_201_CREATED)


class ProfileView(generics.RetrieveUpdateAPIView):
    """Voir / mettre à jour le profil connecté"""
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_list_view(request):
    """
    GET /api/users/
    Liste tous les utilisateurs (réservé aux ADMIN)
    """
    if request.user.role != 'ADMIN':
        return Response(
            {'error': 'Accès réservé aux administrateurs'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    users = CustomUser.objects.all()
    serializer = UserSerializer(users, many=True)
    return Response(serializer.data)


@api_view(['GET', 'PUT', 'DELETE'])
@permission_classes([IsAuthenticated])
def user_detail_view(request, pk):
    """
    GET /api/users/<id>/ - Détail utilisateur
    PUT /api/users/<id>/ - Modifier utilisateur
    DELETE /api/users/<id>/ - Supprimer utilisateur
    Réservé aux ADMIN
    """
    if request.user.role != 'ADMIN':
        return Response(
            {'error': 'Accès réservé aux administrateurs'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    try:
        user = CustomUser.objects.get(pk=pk)
    except CustomUser.DoesNotExist:
        return Response(
            {'error': 'Utilisateur non trouvé'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    if request.method == 'GET':
        serializer = UserSerializer(user)
        return Response(serializer.data)
    
    elif request.method == 'PUT':
        # Modification complète
        data = request.data.copy()
        # Ne pas permettre la modification du mot de passe directement
        if 'password' in data:
            del data['password']
        
        serializer = UserSerializer(user, data=data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(
            {'errors': serializer.errors},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    elif request.method == 'DELETE':
        user.delete()
        return Response(
            {'message': 'Utilisateur supprimé avec succès'},
            status=status.HTTP_204_NO_CONTENT
        )


@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def user_role_update(request, pk):
    """
    PATCH /api/users/<id>/role/
    Changer le rôle d'un utilisateur (ADMIN only)
    """
    if request.user.role != 'ADMIN':
        return Response(
            {'error': 'Accès réservé aux administrateurs'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    try:
        user = CustomUser.objects.get(pk=pk)
    except CustomUser.DoesNotExist:
        return Response(
            {'error': 'Utilisateur non trouvé'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    new_role = request.data.get('role')
    if not new_role:
        return Response(
            {'error': 'Le champ "role" est requis'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Vérifier que le rôle est valide
    valid_roles = ['CITOYEN', 'TECHNICIEN', 'ADMIN']
    if new_role not in valid_roles:
        return Response(
            {'error': f'Rôle invalide. Choix possibles: {valid_roles}'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    user.role = new_role
    user.save()
    
    serializer = UserSerializer(user)
    return Response({
        'message': f'Rôle mis à jour: {new_role}',
        'user': serializer.data
    })


@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def user_toggle_active(request, pk):
    """
    PATCH /api/users/<id>/toggle-active/
    Activer/Désactiver un utilisateur (ADMIN only)
    """
    if request.user.role != 'ADMIN':
        return Response(
            {'error': 'Accès réservé aux administrateurs'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    try:
        user = CustomUser.objects.get(pk=pk)
    except CustomUser.DoesNotExist:
        return Response(
            {'error': 'Utilisateur non trouvé'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    user.is_active = not user.is_active
    user.save()
    
    status_msg = 'activé' if user.is_active else 'désactivé'
    serializer = UserSerializer(user)
    
    return Response({
        'message': f'Utilisateur {status_msg}',
        'user': serializer.data
    })
