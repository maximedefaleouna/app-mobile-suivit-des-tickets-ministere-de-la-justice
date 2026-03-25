# 🚀 Démarrage Rapide - Gestion des Réclamations

## ⚡ En 3 étapes

### 1️⃣ Lancer le Backend
```bash
cd server
python manage.py runserver 0.0.0.0:8000
```

### 2️⃣ Lancer le Frontend (nouveau terminal)
```bash
cd client/reclamations_app
flutter pub get
flutter run
```

### 3️⃣ Tester la connexion
- Email : `admin@example.com`
- Mot de passe : (celui défini lors de la création)

---

## 🎯 URLs à connaître

| Service | URL | Description |
|---------|-----|-------------|
| **Backend API** | `http://localhost:8000` | Serveur Django |
| **Admin Django** | `http://localhost:8000/admin` | Interface admin |
| **Flutter (Android)** | `http://10.0.2.2:8000` | Émulateur Android |
| **Flutter (iOS)** | `http://localhost:8000` | Simulateur iOS |

---

## 📱 Endpoints principaux

### Se connecter
```http
POST http://localhost:8000/api/auth/login/
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "votre_password"
}
```

**Réponse :**
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

### Récupérer les tickets
```http
GET http://localhost:8000/api/tickets/
Authorization: Bearer {access_token}
```

### Créer un ticket
```http
POST http://localhost:8000/api/tickets/
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "titre": "Mon ticket",
  "description": "Description du problème",
  "type_ticket": "INCIDENT",
  "priorite": "NORMALE"
}
```

---

## 🔧 Commandes utiles

### Backend Django
```bash
# Créer un superutilisateur
python manage.py createsuperuser

# Appliquer les migrations
python manage.py migrate

# Créer une migration
python manage.py makemigrations

# Ouvrir le shell Django
python manage.py shell
```

### Frontend Flutter
```bash
# Nettoyer le projet
flutter clean

# Récupérer les dépendances
flutter pub get

# Lister les appareils
flutter devices

# Lancer en mode debug
flutter run

# Build APK
flutter build apk
```

---

## 🐛 Problèmes fréquents

### ❌ "Connection refused"
✅ Le backend n'est pas lancé → `python manage.py runserver`

### ❌ "CORS error"  
✅ Redémarrez le backend après avoir vérifié `CORS_ALLOW_ALL_ORIGINS = True`

### ❌ "Token expired"
✅ Reconnectez-vous ou utilisez le endpoint `/api/auth/refresh/`

### ❌ "Database connection failed"
✅ Vérifiez que PostgreSQL tourne et que les identifiants sont corrects dans `settings.py`

---

## 📦 Packages requis

### Backend (pip install)
```bash
pip install django djangorestframework djangorestframework-simplejwt django-cors-headers django-filter psycopg2-binary
```

### Frontend (déjà dans pubspec.yaml)
```yaml
dependencies:
  http: ^1.2.0
  shared_preferences: ^2.2.2
  provider: ^6.1.2
  intl: ^0.19.0
```

---

## 🎨 Couleurs du projet

```dart
Color(0xFF006743)  // Vert principal
Colors.white       // Texte blanc
Colors.grey        // Éléments secondaires
```

---

## 📝 Fichiers de configuration

### Backend
- `server/config/settings.py` - Configuration principale
- `server/config/urls.py` - Routes API

### Frontend  
- `client/reclamations_app/lib/main.dart` - Point d'entrée
- `client/reclamations_app/lib/services/auth_service.dart` - URLs API
- `client/reclamations_app/lib/services/ticket_service.dart` - URLs API

---

## 💡 Astuces

1. **Pour le développement web**, vous pouvez utiliser Chrome :
   ```bash
   flutter run -d chrome
   ```

2. **Pour tester l'API** sans le frontend, utilisez Postman ou Insomnia

3. **L'admin Django** permet de gérer les utilisateurs et tickets :
   ```bash
   python manage.py createsuperuser
   # Puis allez sur http://localhost:8000/admin
   ```

4. **Les logs Flutter** s'affichent dans le terminal où vous avez lancé `flutter run`

5. **Hot reload** : Appuyez sur `r` dans le terminal Flutter pour recharger sans perdre l'état

---

## ✅ Checklist de démarrage

- [ ] PostgreSQL installé et en cours d'exécution
- [ ] Base de données `reclamation_db` créée
- [ ] Backend Django configuré (`settings.py`)
- [ ] Migrations appliquées (`python manage.py migrate`)
- [ ] Utilisateur créé (via createsuperuser ou register)
- [ ] Backend démarré sur le port 8000
- [ ] Flutter dependencies installées (`flutter pub get`)
- [ ] Émulateur/simulateur démarré
- [ ] Application Flutter lancée (`flutter run`)

---

**🎉 Si tout est vert, vous êtes prêt !**
