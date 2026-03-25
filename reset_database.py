"""
Script de nettoyage et réinitialisation complète de la base de données
"""
import os
import sys
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
sys.path.insert(0, 'server')
django.setup()

from accounts.models import CustomUser
from tickets.models import Ticket, Commentaire, HistoriqueStatut

print("=" * 70)
print("🧹 NETTOYAGE ET RÉINITIALISATION DE LA BASE DE DONNÉES")
print("=" * 70)

# 1. Supprimer tous les tickets
print("\n1️⃣  Suppression des tickets...")
ticket_count = Ticket.objects.count()
Ticket.objects.all().delete()
print(f"   ✓ {ticket_count} ticket(s) supprimé(s)")

# 2. Supprimer tous les commentaires
print("\n2️⃣  Suppression des commentaires...")
comment_count = Commentaire.objects.count()
Commentaire.objects.all().delete()
print(f"   ✓ {comment_count} commentaire(s) supprimé(s)")

# 3. Supprimer tous les historiques
print("\n3️⃣  Suppression des historiques de statut...")
historique_count = HistoriqueStatut.objects.count()
HistoriqueStatut.objects.all().delete()
print(f"   ✓ {historique_count} historique(s) supprimé(s)")

# 4. Supprimer tous les utilisateurs (sauf superuser actuel)
print("\n4️⃣  Suppression des utilisateurs...")
all_users = CustomUser.objects.all()
superuser_email = None

# Garder une trace du superuser
try:
    superuser = CustomUser.objects.filter(is_superuser=True).first()
    if superuser:
        superuser_email = superuser.email
        print(f"   ℹ️  Superuser détecté: {superuser_email}")
except:
    pass

user_count = all_users.count()
all_users.delete()
print(f"   ✓ {user_count} utilisateur(s) supprimé(s)")

# 5. Recréer les utilisateurs de test
print("\n5️⃣  Création des utilisateurs de test...")

# Citoyen
citoyen = CustomUser.objects.create_user(
    email='citoyen@test.com',
    password='1234',
    first_name='Jean',
    last_name='Citoyen',
    role=CustomUser.Role.CITOYEN,
    telephone='+33612345678'
)
print(f"   ✓ Citoyen créé: citoyen@test.com / 1234")

# Technicien
technicien = CustomUser.objects.create_user(
    email='technicien@test.com',
    password='1234',
    first_name='Marie',
    last_name='Technicien',
    role=CustomUser.Role.TECHNICIEN,
    telephone='+33612345679'
)
print(f"   ✓ Technicien créé: technicien@test.com / 1234")

# Admin
admin = CustomUser.objects.create_user(
    email='admin@test.com',
    password='1234',
    first_name='Pierre',
    last_name='Admin',
    role=CustomUser.Role.ADMIN,
    telephone='+33612345680'
)
print(f"   ✓ Admin créé: admin@test.com / 1234")

# Si le superuser existait avant, le recréer avec rôle ADMIN
if superuser_email and superuser_email != 'admin@test.com':
    try:
        superuser = CustomUser.objects.get(email=superuser_email)
        superuser.role = CustomUser.Role.ADMIN
        superuser.save()
        print(f"   ✓ Superuser restauré: {superuser_email} (rôle: ADMIN)")
    except:
        pass

# 6. Créer quelques tickets de test
print("\n6️⃣  Création de tickets de test...")

# Ticket pour le citoyen
ticket1 = Ticket.objects.create(
    titre="Problème de connexion",
    description="Je n'arrive pas à me connecter à mon espace",
    auteur=citoyen,
    type_ticket=Ticket.TypeTicket.INCIDENT,
    priorite=Ticket.Priorite.MOYENNE,
    statut=Ticket.Statut.OUVERT
)
print(f"   ✓ Ticket #1 créé (Citoyen - Ouvert)")

ticket2 = Ticket.objects.create(
    titre="Demande d'information",
    description="Je souhaite avoir des informations sur les démarches",
    auteur=citoyen,
    type_ticket=Ticket.TypeTicket.DEMANDE,
    priorite=Ticket.Priorite.FAIBLE,
    statut=Ticket.Statut.EN_COURS,
    assigne_a=technicien
)
print(f"   ✓ Ticket #2 créé (Citoyen - En cours)")

# Ticket assigné au technicien
ticket3 = Ticket.objects.create(
    titre="Réclamation service informatique",
    description="Le temps de réponse est très lent",
    auteur=admin,
    type_ticket=Ticket.TypeTicket.RECLAMATION,
    priorite=Ticket.Priorite.ELEVEE,
    statut=Ticket.Statut.OUVERT,
    assigne_a=technicien
)
print(f"   ✓ Ticket #3 créé (Admin - Ouvert)")

print("\n" + "=" * 70)
print("✅ BASE DE DONNÉES RÉINITIALISÉE AVEC SUCCÈS !")
print("=" * 70)

print("\n📊 RÉCAPITULATIF:")
print(f"   - {CustomUser.objects.count()} utilisateur(s)")
print(f"   - {Ticket.objects.count()} ticket(s)")
print(f"   - {Commentaire.objects.count()} commentaire(s)")

print("\n🔑 IDENTIFIANTS DE TEST:")
print("   👤 Citoyen:")
print("      Email: citoyen@test.com")
print("      Password: 1234")
print("      Rôle: CITOYEN")
print()
print("   👨‍💻 Technicien:")
print("      Email: technicien@test.com")
print("      Password: 1234")
print("      Rôle: TECHNICIEN")
print()
print("   👑 Admin:")
print("      Email: admin@test.com")
print("      Password: 1234")
print("      Rôle: ADMIN")
print()
print("=" * 70)
print("🚀 Vous pouvez maintenant tester l'application avec ces comptes")
print("=" * 70)
