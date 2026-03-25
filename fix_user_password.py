"""
Script pour corriger le mot de passe d'un utilisateur spécifique
Usage: python fix_user_password.py tchas@gmail.com
"""

import os
import sys
import django

if len(sys.argv) < 2:
    print("Usage: python fix_user_password.py <email>")
    print("Exemple: python fix_user_password.py tchas@gmail.com")
    sys.exit(1)

email = sys.argv[1]
password = "1234"  # Mot de passe par défaut

# Configuration Django
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'server'))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from accounts.models import CustomUser

try:
    user = CustomUser.objects.get(email=email)
    user.set_password(password)
    user.save()
    print(f"✓ Mot de passe corrigé pour {user.email}")
    print(f"  Nouveau mot de passe: {password}")
    print(f"\nVous pouvez maintenant vous connecter avec:")
    print(f"  Email: {email}")
    print(f"  Mot de passe: {password}")
except CustomUser.DoesNotExist:
    print(f"✗ Utilisateur introuvable: {email}")
except Exception as e:
    print(f"✗ Erreur: {e}")
