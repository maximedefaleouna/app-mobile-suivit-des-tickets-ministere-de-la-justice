from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from django.utils import timezone
from django.db import models

from .models import Ticket, Commentaire, HistoriqueStatut
from .serializers import (
    TicketSerializer,
    TicketListSerializer,
    CommentaireSerializer
)
from .permissions import IsAuteurOrReadOnly, IsTechnicienOrAdmin


class TicketViewSet(viewsets.ModelViewSet):
    """
    ViewSet complet pour la gestion des tickets.

    - list : GET /api/tickets/
    - create : POST /api/tickets/
    - retrieve : GET /api/tickets/{id}/
    - update : PUT/PATCH /api/tickets/{id}/
    - destroy : DELETE /api/tickets/{id}/
    """

    queryset = Ticket.objects.select_related(
        'auteur', 'assigne_a'
    ).prefetch_related('commentaires', 'historique')

    permission_classes = [IsAuthenticated]

    filter_backends = [
        DjangoFilterBackend,
        filters.SearchFilter,
        filters.OrderingFilter,
    ]

    filterset_fields = ['statut', 'priorite', 'type_ticket', 'assigne_a']
    search_fields = ['titre', 'description']
    ordering_fields = ['date_creation', 'priorite', 'statut']

    def get_serializer_class(self):
        if self.action == 'list':
            return TicketListSerializer
        return TicketSerializer

    def get_queryset(self):
        user = self.request.user

        # Citoyen : voit ses tickets
        if user.role == 'CITOYEN':
            return Ticket.objects.filter(auteur=user)

        # Technicien : tickets assignés + ouverts
        if user.role == 'TECHNICIEN':
            return Ticket.objects.filter(
                models.Q(assigne_a=user) |
                models.Q(statut='OUVERT')
            )

        # Admin : tout voir
        return Ticket.objects.all()

    @action(detail=True, methods=['patch'], permission_classes=[IsTechnicienOrAdmin])
    def changer_statut(self, request, pk=None):
        """PATCH /api/tickets/{id}/changer_statut/"""
        ticket = self.get_object()
        nouveau_statut = request.data.get('statut')

        if nouveau_statut not in dict(Ticket.Statut.choices):
            return Response(
                {'erreur': 'Statut invalide.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        ancien_statut = ticket.statut
        ticket.statut = nouveau_statut

        if nouveau_statut == Ticket.Statut.RESOLU:
            ticket.date_resolution = timezone.now()

        ticket.save()

        # Historique
        HistoriqueStatut.objects.create(
            ticket=ticket,
            ancien_statut=ancien_statut,
            nouveau_statut=nouveau_statut,
            modifie_par=request.user,
        )

        return Response(
            TicketSerializer(ticket, context={'request': request}).data
        )

    @action(detail=True, methods=['post'])
    def commenter(self, request, pk=None):
        """POST /api/tickets/{id}/commenter/"""
        ticket = self.get_object()
        serializer = CommentaireSerializer(data=request.data)

        if serializer.is_valid():
            serializer.save(ticket=ticket, auteur=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['patch'], permission_classes=[IsTechnicienOrAdmin])
    def assigner(self, request, pk=None):
        """PATCH /api/tickets/{id}/assigner/"""
        ticket = self.get_object()
        technicien_id = request.data.get('technicien_id')

        try:
            from accounts.models import CustomUser

            tech = CustomUser.objects.get(
                id=technicien_id,
                role='TECHNICIEN'
            )

            ticket.assigne_a = tech
            ticket.statut = Ticket.Statut.EN_COURS
            ticket.save()

            return Response(
                TicketSerializer(ticket, context={'request': request}).data
            )

        except CustomUser.DoesNotExist:
            return Response(
                {'erreur': 'Technicien introuvable.'},
                status=status.HTTP_404_NOT_FOUND
            )