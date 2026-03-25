"""
Script pour corriger les mots de passe des utilisateurs existants
Usage: python fix_existing_passwords.py
"""

import os
import sys
import django

# Configuration Django
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'server'))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from accounts.models import CustomUser

def main():
    print("=" * 60)
    print("  Correction des mots de passe existants")
    print("=" * 60)
    
    # Récupérer tous les utilisateurs
    users = CustomUser.objects.all()
    print(f"\nTotal utilisateurs à vérifier: {users.count()}")
    
    # Mot de passe par défaut à utiliser
    default_password = "1234"
    
    print(f"\n⚠️  ATTENTION: Tous les utilisateurs auront le mot de passe '{default_password}'")
    print("Cette opération est irréversible!\n")
    
    response = input("Voulez-vous continuer? (o/n): ")
    if response.lower() != 'o':
        print("Annulé.")
        return
    
    count = 0
    for user in users:
        try:
            # Définir le mot de passe (sera automatiquement haché par set_password)
            user.set_password(default_password)
            user.save()
            print(f"✓ {user.email} - mot de passe corrigé")
            count += 1
        except Exception as e:
            print(f"✗ Erreur pour {user.email}: {e}")
    
    print("\n" + "=" * 60)
    print(f"  Terminé! {count}/{users.count()} utilisateurs corrigés")
    print("=" * 60)
    print("\nMaintenant TOUS les utilisateurs peuvent se connecter avec:")
    print(f"  Mot de passe: {default_password}")
    print("\nExemple:")
    print(f"  Email: tchas@gmail.com")
    print(f"  Mot de passe: {default_password}")
    print("=" * 60)

if __name__ == '__main__':
    main()
