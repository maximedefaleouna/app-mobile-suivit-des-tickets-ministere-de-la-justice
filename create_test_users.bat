@echo off
echo ========================================
echo   Creation d'utilisateurs de test
echo ========================================
echo.

cd /d "%~dp0server"

echo [INFO] Lancement du shell Django pour creer des utilisateurs...
echo.

python manage.py shell << EOF
from accounts.models import CustomUser

# Verifier les utilisateurs existants
print("=== Utilisateurs existants ===")
users = CustomUser.objects.all()
if users.count() == 0:
    print("Aucun utilisateur trouve.")
else:
    for user in users:
        print(f"  - {user.email} (role: {user.role})")

print("\n=== Creation d'utilisateurs de test ===")

# Utilisateur 1 - Citoyen
try:
    user1 = CustomUser.objects.create_user(
        email='citoyen@test.com',
        username='citoyen_test',
        password='1234',
        first_name='Citoyen',
        last_name='Test',
        role=CustomUser.Role.CITOYEN
    )
    print("✓ Citoyen cree : citoyen@test.com / 1234")
except Exception as e:
    print(f"✗ Erreur creation citoyen: {e}")

# Utilisateur 2 - Technicien
try:
    user2 = CustomUser.objects.create_user(
        email='technicien@test.com',
        username='technicien_test',
        password='1234',
        first_name='Technicien',
        last_name='Test',
        role=CustomUser.Role.TECHNICIEN
    )
    print("✓ Technicien cree : technicien@test.com / 1234")
except Exception as e:
    print(f"✗ Erreur creation technicien: {e}")

# Utilisateur 3 - Admin (pas superuser)
try:
    user3 = CustomUser.objects.create_user(
        email='admin@test.com',
        username='admin_test',
        password='1234',
        first_name='Admin',
        last_name='Test',
        role=CustomUser.Role.ADMIN
    )
    print("✓ Admin cree : admin@test.com / 1234")
except Exception as e:
    print(f"✗ Erreur creation admin: {e}")

print("\n=== Verification finale ===")
users = CustomUser.objects.all()
print(f"Total utilisateurs: {users.count()}")
for user in users:
    print(f"  - {user.email} (role: {user.role}, actif: {user.is_active})")

print("\n========================================")
print("  Terminé ! Vous pouvez tester la connexion")
print("  avec ces identifiants dans l'app Flutter")
print("========================================")
EOF

echo.
pause
