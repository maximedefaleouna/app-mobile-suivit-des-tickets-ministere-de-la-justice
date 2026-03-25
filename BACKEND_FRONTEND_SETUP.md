# Configuration pour la communication Frontend-Backend

## URLs de l'API Backend

### Frontend (Flutter)
Les fichiers de service sont configurés pour communiquer avec le backend Django :

- **Auth Service** : `lib/services/auth_service.dart`
- **Ticket Service** : `lib/services/ticket_service.dart`

### URLs configurées

```dart
// Pour Android Emulator
http://10.0.2.2:8000/api

// Pour iOS Simulator  
http://localhost:8000/api

// Pour appareil physique (remplacez par votre IP locale)
http://192.168.x.x:8000/api
```

---

## Démarrage du Backend (Django)

### 1. Activer l'environnement virtuel (si existe)
```bash
cd server
# Windows
python -m venv venv
venv\Scripts\activate

# Linux/Mac
python3 -m venv venv
source venv/bin/activate
```

### 2. Installer les dépendances
```bash
pip install django djangorestframework djangorestframework-simplejwt django-cors-headers django-filter psycopg2-binary
```

### 3. Configurer la base de données PostgreSQL
Dans `server/config/settings.py`, assurez-vous que la configuration correspond à votre installation :

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'reclamation_db',
        'USER': 'postgres',
        'PASSWORD': '1234',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
```

### 4. Créer la base de données
```bash
# Dans PostgreSQL
CREATE DATABASE reclamation_db;
```

### 5. Appliquer les migrations
```bash
cd server
python manage.py makemigrations
python manage.py migrate
```

### 6. Créer un superutilisateur (optionnel)
```bash
python manage.py createsuperuser
```

### 7. Lancer le serveur Django
```bash
python manage.py runserver 0.0.0.0:8000
```

Le backend est maintenant accessible sur : `http://localhost:8000`

---

## Démarrage du Frontend (Flutter)

### 1. Se rendre dans le dossier client
```bash
cd client/reclamations_app
```

### 2. Installer les dépendances Flutter
```bash
flutter pub get
```

### 3. Lancer l'application

#### Pour Android Emulator
```bash
flutter run
```

#### Pour iOS Simulator (Mac uniquement)
```bash
flutter run
```

#### Pour Chrome (Web)
```bash
flutter run -d chrome
```

---

## Points Importants

### CORS (Cross-Origin Resource Sharing)
Le backend est configuré pour accepter toutes les origines dans `settings.py` :
```python
CORS_ALLOW_ALL_ORIGINS = True
```

### Token JWT
L'authentification utilise JWT (JSON Web Tokens) :
- Access token : 2 heures
- Refresh token : 7 jours

### Endpoints API disponibles

#### Authentification
- `POST /api/auth/login/` - Connexion (obtenir tokens)
- `POST /api/auth/refresh/` - Rafraîchir token
- `POST /api/auth/register/` - Inscription
- `GET /api/auth/profil/` - Profil utilisateur

#### Tickets
- `GET /api/tickets/` - Liste des tickets
- `POST /api/tickets/` - Créer un ticket
- `GET /api/tickets/{id}/` - Détail d'un ticket
- `PUT/PATCH /api/tickets/{id}/` - Modifier un ticket
- `DELETE /api/tickets/{id}/` - Supprimer un ticket
- `PATCH /api/tickets/{id}/changer_statut/` - Changer le statut
- `POST /api/tickets/{id}/commenter/` - Ajouter un commentaire
- `PATCH /api/tickets/{id}/assigner/` - Assigner un technicien

---

## Résolution des problèmes courants

### Erreur de connexion au backend

1. **Vérifiez que le serveur Django tourne**
```bash
curl http://localhost:8000
```

2. **Pour Android Emulator**, utilisez `10.0.2.2` au lieu de `localhost`
3. **Pour un appareil physique**, utilisez l'IP locale de votre machine

### Erreur CORS

Assurez-vous que `corsheaders` est bien dans `INSTALLED_APPS` et que `CORS_ALLOW_ALL_ORIGINS = True`

### Erreur d'authentification

Vérifiez que les tokens JWT sont correctement stockés avec `shared_preferences`

---

## Structure des fichiers modifiés

### Backend
- `server/config/settings.py` - Configuration Django + CORS
- `server/config/urls.py` - Routes API
- `server/accounts/views.py` - Vues authentification
- `server/tickets/views.py` - Vues tickets

### Frontend
- `client/reclamations_app/lib/main.dart` - Point d'entrée
- `client/reclamations_app/lib/screens/login_screen.dart` - Page de connexion
- `client/reclamations_app/lib/screens/home_screen.dart` - Page d'accueil
- `client/reclamations_app/lib/screens/ticket_list_screen.dart` - Liste des tickets
- `client/reclamations_app/lib/screens/ticket_detail_screen.dart` - Détail d'un ticket
- `client/reclamations_app/lib/screens/create_ticket_screen.dart` - Créer un ticket
- `client/reclamations_app/lib/services/auth_service.dart` - Service d'authentification
- `client/reclamations_app/lib/services/ticket_service.dart` - Service des tickets
- `client/reclamations_app/lib/models/ticket.dart` - Modèle Ticket
- `client/reclamations_app/lib/widgets/ticket_card.dart` - Widget carte ticket
