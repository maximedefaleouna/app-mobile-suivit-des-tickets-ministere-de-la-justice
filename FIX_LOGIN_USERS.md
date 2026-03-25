# 🔧 Solution - Login pour tous les utilisateurs

## ❌ Problème
Seul le superutilisateur peut se connecter. Les utilisateurs normaux ne peuvent pas s'authentifier.

## ✅ Solutions appliquées

### 1. Création d'une vue d'authentification personnalisée

**Fichier:** `server/accounts/views.py`

Ajout d'une vue `CustomTokenObtainPairView` qui permet à TOUS les utilisateurs authentifiés d'obtenir des tokens JWT :

```python
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework import permissions

class CustomTokenObtainPairView(TokenObtainPairView):
    """Vue personnalisée pour obtenir les tokens JWT - accessible à tous les utilisateurs"""
    permission_classes = [permissions.AllowAny]
```

### 2. Mise à jour des URLs

**Fichier:** `server/config/urls.py`

Remplacement de la vue par défaut par notre vue personnalisée :

```python
from accounts.views import CustomTokenObtainPairView

urlpatterns = [
    path('api/auth/login/', CustomTokenObtainPairView.as_view(), name='token_obtain'),
    # ... autres URLs
]
```

---

## 📝 Comment créer un utilisateur normal

### Option 1 : Via l'API (Recommandé)

Utilisez Postman ou votre frontend Flutter pour appeler :

```http
POST http://localhost:8000/api/auth/register/
Content-Type: application/json

{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "motdepasse123",
  "first_name": "John",
  "last_name": "Doe",
  "role": "CITOYEN"
}
```

### Option 2 : Via le shell Django

```bash
cd server
python manage.py shell
```

```python
from accounts.models import CustomUser

# Créer un utilisateur
user = CustomUser.objects.create_user(
    email='user@example.com',
    username='user123',
    password='motdepasse123',
    first_name='John',
    last_name='Doe',
    role=CustomUser.Role.CITOYEN  # ou TECHNICIEN ou ADMIN
)
user.save()
print(f"Utilisateur créé: {user.email}")
```

### Option 3 : Via l'admin Django

1. Créez un superutilisateur si ce n'est pas déjà fait :
```bash
python manage.py createsuperuser
```

2. Lancez le serveur :
```bash
python manage.py runserver
```

3. Allez sur : `http://localhost:8000/admin/`

4. Connectez-vous avec le superutilisateur

5. Cliquez sur "Users" → "Add User"

6. Remplissez les informations et définissez un mot de passe

---

## 🧪 Tester la connexion

### Avec le superutilisateur
```bash
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin"}'
```

### Avec un utilisateur normal
```bash
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"motdepasse123"}'
```

Les deux doivent retourner :
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

---

## 🔍 Vérifier les utilisateurs existants

```bash
cd server
python manage.py shell
```

```python
from accounts.models import CustomUser

# Lister tous les utilisateurs
users = CustomUser.objects.all()
for user in users:
    print(f"{user.email} - Rôle: {user.role} - Actif: {user.is_active}")
```

---

## 🚀 Étapes complètes pour tester

### 1. Installer les dépendances manquantes
```bash
cd server
pip install django-cors-headers djangorestframework djangorestframework-simplejwt django-filter psycopg2-binary
```

### 2. Appliquer les migrations
```bash
python manage.py migrate
```

### 3. Créer un utilisateur test
```bash
python manage.py shell << EOF
from accounts.models import CustomUser
user = CustomUser.objects.create_user(
    email='test@example.com',
    username='testuser',
    password='test123',
    first_name='Test',
    last_name='User',
    role=CustomUser.Role.CITOYEN
)
print(f"Utilisateur créé: {user.email}")
EOF
```

### 4. Lancer le serveur
```bash
python manage.py runserver 0.0.0.0:8000
```

### 5. Tester avec le frontend Flutter
- Email: `test@example.com`
- Mot de passe: `test123`

---

## ⚠️ Points importants

### Rôles disponibles
- `CITOYEN` - Utilisateur normal (défaut)
- `TECHNICIEN` - Technicien support
- `ADMIN` - Administrateur

### Champs requis pour créer un utilisateur
- `email` (unique)
- `username`
- `password`
- `role` (optionnel, défaut: CITOYEN)

### Permissions JWT
- **TOUS** les utilisateurs actifs peuvent obtenir des tokens
- Le token contient les informations de rôle
- Le backend vérifie le rôle pour certaines actions

---

## 🐛 Debugging

### Erreur: "User not found"
✅ Vérifiez que l'utilisateur existe :
```python
from accounts.models import CustomUser
CustomUser.objects.filter(email='user@example.com').exists()
```

### Erreur: "Password incorrect"
✅ Le mot de passe doit être haché avec `set_password()` ou `create_user()`

### Erreur: "User is inactive"
✅ Vérifiez que `is_active=True` :
```python
user = CustomUser.objects.get(email='user@example.com')
print(user.is_active)  # Doit être True
```

### Erreur CORS
✅ Vérifiez que `CORS_ALLOW_ALL_ORIGINS = True` dans `settings.py`

### Erreur: Module not found
✅ Installez les dépendances :
```bash
pip install django-cors-headers djangorestframework djangorestframework-simplejwt
```

---

## ✅ Checklist finale

- [ ] Dependencies installées (`pip install ...`)
- [ ] Migrations appliquées (`python manage.py migrate`)
- [ ] Au moins un utilisateur créé
- [ ] Serveur Django lancé (`python manage.py runserver`)
- [ ] Frontend Flutter configuré avec la bonne URL
- [ ] Test de connexion avec un utilisateur normal
- [ ] Test de connexion avec le superutilisateur

---

**🎉 Si tout est vert, tous les utilisateurs peuvent maintenant se connecter !**
