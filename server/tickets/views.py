from rest_framework import viewsets, status, filters, permissions
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from django.utils import timezone
from django.db import models
from django.db.models import Count, Q, Avg, F
from datetime import timedelta

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


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def statistics_view(request):
    """
    Statistiques générales pour le tableau de bord
    """
    user = request.user
    
    # Filtrer selon le rôle
    if user.role == 'CITOYEN':
        queryset = Ticket.objects.filter(auteur=user)
    elif user.role == 'TECHNICIEN':
        queryset = Ticket.objects.filter(
            Q(assigned_a=user) | Q(statut='OUVERT')
        )
    else:  # ADMIN
        queryset = Ticket.objects.all()
    
    # Statistiques par statut
    stats_by_status = queryset.values('statut').annotate(
        count=Count('id')
    ).order_by('statut')
    
    # Statistiques par type
    stats_by_type = queryset.values('type_ticket').annotate(
        count=Count('id')
    ).order_by('type_ticket')
    
    # Statistiques par priorité
    stats_by_priority = queryset.values('priorite').annotate(
        count=Count('id')
    ).order_by('priorite')
    
    # Temps moyen de résolution (pour les tickets résolus)
    resolved_tickets = queryset.filter(
        statut='RESOLU',
        date_resolution__isnull=False
    ).annotate(
        resolution_time=F('date_resolution') - F('date_creation')
    )
    
    avg_resolution_time = None
    if resolved_tickets.exists():
        total_seconds = sum(
            t.resolution_time.total_seconds() 
            for t in resolved_tickets
        )
        avg_seconds = total_seconds / resolved_tickets.count()
        avg_resolution_time = {
            'days': int(avg_seconds // 86400),
            'hours': int((avg_seconds % 86400) // 3600),
            'minutes': int((avg_seconds % 3600) // 60)
        }
    
    # Évolution sur les 30 derniers jours
    thirty_days_ago = timezone.now() - timedelta(days=30)
    evolution = queryset.filter(
        date_creation__gte=thirty_days_ago
    ).annotate(
        date=F('date_creation__date')
    ).values('date').annotate(
        count=Count('id')
    ).order_by('date')
    
    return Response({
        'total': queryset.count(),
        'by_status': {item['statut']: item['count'] for item in stats_by_status},
        'by_type': {item['type_ticket']: item['count'] for item in stats_by_type},
        'by_priority': {item['priorite']: item['count'] for item in stats_by_priority},
        'average_resolution_time': avg_resolution_time,
        'evolution_last_30_days': list(evolution),
        'resolved_count': resolved_tickets.count(),
    })


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def dashboard_view(request):
    """
    Données pour le tableau de bord principal
    """
    user = request.user
    
    # Filtrer selon le rôle
    if user.role == 'CITOYEN':
        queryset = Ticket.objects.filter(auteur=user)
        pending_assignments = []
    elif user.role == 'TECHNICIEN':
        queryset = Ticket.objects.filter(
            Q(assigne_a=user) | Q(statut='OUVERT')
        )
        pending_assignments = TicketListSerializer(
            Ticket.objects.filter(assigne_a=user, statut='EN_COURS'),
            many=True,
            context={'request': request}
        ).data
    else:  # ADMIN
        queryset = Ticket.objects.all()
        pending_assignments = []
    
    # Tickets récents
    recent_tickets = TicketListSerializer(
        queryset.order_by('-date_creation')[:10],
        many=True,
        context={'request': request}
    ).data
    
    # Tickets urgents
    urgent_tickets = TicketListSerializer(
        queryset.filter(priorite__in=['HAUTE', 'CRITIQUE'], statut__in=['OUVERT', 'EN_COURS']).order_by('-date_creation')[:5],
        many=True,
        context={'request': request}
    ).data
    
    # Compteurs rapides
    quick_stats = {
        'open': queryset.filter(statut='OUVERT').count(),
        'in_progress': queryset.filter(statut='EN_COURS').count(),
        'resolved': queryset.filter(statut='RESOLU').count(),
        'closed': queryset.filter(statut='CLOS').count(),
        'critical': queryset.filter(priorite='CRITIQUE').count(),
    }
    
    return Response({
        'recent_tickets': recent_tickets,
        'urgent_tickets': urgent_tickets,
        'pending_assignments': pending_assignments,
        'quick_stats': quick_stats,
        'user_role': user.role,
    })