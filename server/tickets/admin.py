from django.contrib import admin
from .models import Ticket, Commentaire, HistoriqueStatut

@admin.register(Ticket)
class TicketAdmin(admin.ModelAdmin):
    list_display = ('titre', 'statut', 'priorite', 'auteur', 'assigne_a', 'date_creation')
    list_filter = ('statut', 'priorite', 'type_ticket')
    search_fields = ('titre', 'description')

@admin.register(Commentaire)
class CommentaireAdmin(admin.ModelAdmin):
    list_display = ('ticket', 'auteur', 'date')
    search_fields = ('contenu',)

@admin.register(HistoriqueStatut)
class HistoriqueStatutAdmin(admin.ModelAdmin):
    list_display = ('ticket', 'ancien_statut', 'nouveau_statut', 'modifie_par', 'date_changement')