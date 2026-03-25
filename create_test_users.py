"""
Script pour créer des utilisateurs de test
Usage: python create_test_users.py
"""

import os
import sys
import django

# Configuration Django
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'server'))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from accounts.models import CustomUser

def print_separator():
    print("=" * 60)

def print_users():
    """Affiche tous les utilisateurs"""
    users = CustomUser.objects.all()
    print(f"\nTotal utilisateurs: {users.count()}")
    for user in users:
        print(f"  - {user.email} (rôle: {user.role}, actif: {user.is_active})")

def main():
    print_separator()
    print("  Création d'utilisateurs de test")
    print_separator()
    
    # Utilisateurs existants
    print("\n=== Utilisateurs existants ===")
    print_users()
    
    print("\n=== Création d'utilisateurs de test ===")
    
    # Utilisateur 1 - Citoyen
    try:
        if not CustomUser.objects.filter(email='citoyen@test.com').exists():
            user1 = CustomUser.objects.create_user(
                email='citoyen@test.com',
                username='citoyen_test',
                password='1234',
                first_name='Citoyen',
                last_name='Test',
                role=CustomUser.Role.CITOYEN
            )
            print("✓ Citoyen créé : citoyen@test.com / 1234")
        else:
            print("⚠ Citoyen existe déjà")
    except Exception as e:
        print(f"✗ Erreur création citoyen: {e}")
    
    # Utilisateur 2 - Technicien
    try:
        if not CustomUser.objects.filter(email='technicien@test.com').exists():
            user2 = CustomUser.objects.create_user(
                email='technicien@test.com',
                username='technicien_test',
                password='1234',
                first_name='Technicien',
                last_name='Test',
                role=CustomUser.Role.TECHNICIEN
            )
            print("✓ Technicien créé : technicien@test.com / 1234")
        else:
            print("⚠ Technicien existe déjà")
    except Exception as e:
        print(f"✗ Erreur création technicien: {e}")
    
    # Utilisateur 3 - Admin (pas superuser)
    try:
        if not CustomUser.objects.filter(email='admin@test.com').exists():
            user3 = CustomUser.objects.create_user(
                email='admin@test.com',
                username='admin_test',
                password='1234',
                first_name='Admin',
                last_name='Test',
                role=CustomUser.Role.ADMIN
            )
            print("✓ Admin créé : admin@test.com / 1234")
        else:
            print("⚠ Admin existe déjà")
    except Exception as e:
        print(f"✗ Erreur création admin: {e}")
    
    # Vérification finale
    print("\n=== Vérification finale ===")
    print_users()
    
    print("\n" + "=" * 60)
    print("  Terminé ! Vous pouvez tester la connexion")
    print("  avec ces identifiants dans l'app Flutter")
    print("=" * 60)
    print("\nIdentifiants:")
    print("  1. citoyen@test.com / 1234")
    print("  2. technicien@test.com / 1234")
    print("  3. admin@test.com / 1234")
    print("\n" + "=" * 60)

if __name__ == '__main__':
    main()
