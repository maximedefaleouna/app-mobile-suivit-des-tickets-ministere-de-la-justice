# 🏗️ RECONSTRUCTION COMPLÈTE - SYSTÈME À 3 RÔLES

## 📅 DATE: 25 Mars 2026

---

## 🎯 OBJECTIF

Reconstruire proprement le système avec **3 rôles bien distincts** comme spécifié dans le cahier des charges du Ministère de la Justice.

---

## 🔧 CHANGEMENTS EFFECTUÉS

### 1. BACKEND - Nouvelles API Créées ✅

#### A. Gestion des Utilisateurs (ADMIN only)

**Fichier:** `server/accounts/views.py`

**Nouvelles API:**

```python
# GET /api/users/
# Liste tous les utilisateurs (réservé ADMIN)
user_list_view()

# GET /api/users/<id>/
# Détail d'un utilisateur (réservé ADMIN)
user_detail_view()

# PUT /api/users/<id>/
# Modifier un utilisateur (réservé ADMIN)
user_detail_view()

# DELETE /api/users/<id>/
# Supprimer un utilisateur (réservé ADMIN)
user_detail_view()

# PATCH /api/users/<id>/role/
# Changer le rôle d'un utilisateur (réservé ADMIN)
user_role_update()

# PATCH /api/users/<id>/toggle-active/
# Activer/Désactiver un utilisateur (réservé ADMIN)
user_toggle_active()
```

#### B. URLs Mises à Jour ✅

**Fichier:** `server/config/urls.py`

Ajout des routes:
```python
path('api/users/', user_list_view, name='user-list'),
path('api/users/<int:pk>/', user_detail_view, name='user-detail'),
path('api/users/<int:pk>/role/', user_role_update, name='user-role'),
path('api/users/<int:pk>/toggle-active/', user_toggle_active, name='user-toggle-active'),
```

---

## 📊 ARCHITECTURE DES 3 RÔLES

### 👤 1. CITOYEN (Utilisateur standard)

**Profil type:** Jean Citoyen - `citoyen@test.com`

**Permissions:**
- ✅ S'inscrire via l'application
- ✅ Se connecter
- ✅ Créer des tickets (INCIDENT, RÉCLAMATION, DEMANDE)
- ✅ Voir SES tickets uniquement
- ✅ Suivre l'état de ses tickets
- ✅ Consulter historique de SES demandes
- ✅ Recevoir notifications pour SES tickets

**Interface Flutter:**
```
HomeScreen → "Bienvenue Jean"
  ↓
[Mes Tickets] → Liste de SES tickets personnels
  ↓
[Créer Ticket] → Formulaire: Type, Sujet, Description
  ↓
[Ticket Detail] → État d'avancement, commentaires
```

**Ce qu'il voit:**
- Uniquement les tickets qu'il a créés
- Statistiques personnelles
- Son profil utilisateur

---

### 👨‍💻 2. TECHNICIEN (Cellule informatique)

**Profil type:** Marie Technicien - `technicien@test.com`

**Permissions:**
- ✅ Se connecter
- ✅ Tableau de bord TOUS les tickets
- ✅ Voir tickets non assignés
- ✅ Prendre en charge un ticket (s'assigner automatiquement)
- ✅ Changer statut (OUVERT → EN COURS → RÉSOLU → CLOS)
- ✅ Ajouter commentaires et actions
- ✅ Filtrer par statut, priorité, type
- ✅ Rechercher par titre/description
- ✅ Voir statistiques de traitement

**Interface Flutter:**
```
TechnicianDashboard → "Tableau de bord - Cellule Informatique"
  ↓
[Tous les Tickets] + [Non Assignés] + [Mes Tickets]
  ↓
[Filtres] → Par statut, priorité, type
  ↓
[Ticket Detail] → Actions: Prendre en charge, Changer statut, Commenter
  ↓
[Statistiques] → Performance personnelle
```

**Ce qu'il voit:**
- TOUS les tickets (sauf filtrage)
- Tickets non assignés
- Ses tickets assignés
- Statistiques de performance

**Workflow typique:**
1. Voit un ticket non assigné
2. Clique "Prendre en charge"
3. Le ticket lui est assigné automatiquement
4. Change statut → "EN COURS"
5. Traite le problème
6. Ajoute commentaire/solution
7. Change statut → "RÉSOLU"
8. Attend validation citoyen/admin

---

### 👑 3. ADMIN (Administrateur système)

**Profil type:** Pierre Admin - `admin@test.com`

**Permissions:**
- ✅ TOUT ce que fait le TECHNICIEN
- ✅ Gérer TOUS les utilisateurs (CRUD complet)
- ✅ Changer les rôles (CITOYEN → TECHNICIEN → ADMIN)
- ✅ Activer/Désactiver comptes
- ✅ Supprimer utilisateurs
- ✅ Configurer types de tickets
- ✅ Configurer priorités
- ✅ Configurer délais de traitement
- ✅ Archivage automatique
- ✅ Statistiques GLOBALES
- ✅ Export rapports PDF/Excel

**Interface Flutter:**
```
AdminDashboard → "Tableau de bord Administrateur"
  ↓
[Statistiques Globales] → Total tickets, utilisateurs, temps moyen
  ↓
[Gestion Utilisateurs] → Liste, CRUD, rôles
  ↓
[Gestion Tickets] → Tous les tickets, interventions
  ↓
[Paramètres] → Configuration système
  ↓
[Archives] → Tickets clos archivés
```

**Ce qu'il voit:**
- Vue d'ensemble complète
- Tous les indicateurs
- Tous les utilisateurs
- Tous les tickets
- Configuration système

---

## 🔄 WORKFLOW COMPLET

### Scénario 1: Création et traitement d'un ticket

```
Étape 1: Jean Citoyen crée un ticket
  ↓
Citoyen se connecte (citoyen@test.com / 1234)
  ↓
Accueil → "Nouveau ticket"
  ↓
Remplit formulaire:
  - Type: INCIDENT
  - Sujet: "Problème de connexion"
  - Description: "Je n'arrive pas à accéder..."
  ↓
Soumet → Ticket créé avec statut "OUVERT"
  ↓
Reçoit confirmation


Étape 2: Marie Technicien prend en charge
  ↓
Technicien se connecte (technicien@test.com / 1234)
  ↓
Dashboard → Voir TOUS les tickets
  ↓
Filtre: "Non assignés"
  ↓
Voit le ticket de Jean
  ↓
Clique "Prendre en charge"
  ↓
Ticket assigné automatiquement à Marie
  ↓
Statut change → "EN COURS"


Étape 3: Marie traite le ticket
  ↓
Ajoute commentaire: "Je vérifie votre compte..."
  ↓
Investigue et résout le problème
  ↓
Ajoute solution: "Votre mot de passe a été réinitialisé"
  ↓
Change statut → "RÉSOLU"
  ↓
Date de résolution enregistrée automatiquement


Étape 4: Jean constate la résolution
  ↓
Jean reçoit notification
  ↓
Se connecte → Voit son ticket "RÉSOLU"
  ↓
Teste la solution → Ça fonctionne !
  ↓
Peut ajouter commentaire de remerciement


Étape 5: Clôture (automatique ou manuelle)
  ↓
Après 7 jours sans réponse → "CLOS" automatiquement
  ↓
Ou Admin clôture manuellement
```

---

### Scénario 2: Administration - Promotion d'un utilisateur

```
Étape 1: Admin veut promouvoir Jean en technicien
  ↓
Admin se connecte (admin@test.com / 1234)
  ↓
Admin Dashboard → "Gestion des utilisateurs"
  ↓
Cherche "Jean Citoyen" dans la liste
  ↓
Clique sur les 3 points (⋮)
  ↓
Sélectionne "Changer le rôle"
  ↓
Choisit "TECHNICIEN"
  ↓
Confirme


Étape 2: Système met à jour
  ↓
API appelle: PATCH /api/users/<id>/role/
  ↓
Backend vérifie que c'est bien ADMIN qui demande
  ↓
Change role: CITOYEN → TECHNICIEN
  ↓
Sauvegarde en base de données
  ↓
Retourne confirmation


Étape 3: Jean peut maintenant accéder aux fonctions tech
  ↓
Jean se déconnecte et se reconnecte
  ↓
Son rôle est maintenant TECHNICIEN
  ↓
Il voit le dashboard technicien
  ↓
Il peut prendre en charge des tickets
```

---

## 🗄️ BASE DE DONNÉES

### Nettoyage et Réinitialisation

**Script:** `reset_database.py`

**Ce qu'il fait:**
1. ✅ Supprime TOUS les tickets
2. ✅ Supprime TOUS les commentaires
3. ✅ Supprime TOUS les historiques
4. ✅ Supprime TOUS les utilisateurs
5. ✅ Recrée 3 utilisateurs de test (Citoyen, Technicien, Admin)
6. ✅ Crée 3 tickets de test pour exemples

**Exécution:**
```bash
cd c:\Users\defal\Donnees\Code\Projet\projet_framework
python reset_database.py
```

**Résultat:**
```
✅ BASE DE DONNÉES RÉINITIALISÉE AVEC SUCCÈS !

📊 RÉCAPITULATIF:
   - 3 utilisateur(s)
   - 3 ticket(s)
   - 0 commentaire(s)

🔑 IDENTIFIANTS DE TEST:
   👤 Citoyen: citoyen@test.com / 1234
   👨‍💻 Technicien: technicien@test.com / 1234
   👑 Admin: admin@test.com / 1234
```

---

## 📱 FRONTEND - État Actuel

### ✅ Écrans Déjà Créés

**Pour tous:**
- LoginScreen ✅
- RegisterScreen ✅
- HomeScreen ✅ (pour Citoyen)
- ProfileScreen ✅
- CreateTicketScreen ✅

**Pour Admin:**
- AdminDashboardScreen ✅
- AdminUsersScreen ✅
- AdminTicketsScreen ✅
- AdminSettingsScreen ✅

### ❌ Écrans à Créer

**Pour Technicien:**
- ❌ TechnicianDashboardScreen
- ❌ TicketAssignmentScreen  
- ❌ TicketProcessingScreen
- ❌ TechnicianStatisticsScreen

**Améliorations nécessaires:**
- ❌ Timeline dans TicketDetailScreen
- ❌ Notifications en temps réel
- ❌ Filtrage avancé dans HomeScreen

---

## 🔐 SÉCURITÉ ET PERMISSIONS

### Backend - Vérifications

```python
# Dans chaque vue admin
if request.user.role != 'ADMIN':
    return Response(
        {'error': 'Accès réservé aux administrateurs'},
        status=status.HTTP_403_FORBIDDEN
    )

# Pour les techniciens
permission_classes = [IsTechnicienOrAdmin]

# Pour les auteurs de tickets
permission_classes = [IsAuteurOrReadOnly]
```

### Frontend - Navigation par rôle

```dart
// Dans login_screen.dart
if (userRole == 'ADMIN') {
  destinationScreen = const AdminDashboardScreen();
} else if (userRole == 'TECHNICIEN') {
  destinationScreen = const TechnicianDashboardScreen(); // À créer
} else {
  destinationScreen = const HomeScreen();
}
```

---

## 🧪 TESTING

### Test rapide des API

**Script:** `test_admin_login.py`

```bash
python test_admin_login.py
```

**Vérifie:**
- ✅ Login admin@test.com fonctionne
- ✅ Token JWT généré correctement
- ✅ Rôle ADMIN retourné par l'API
- ✅ Endpoint /api/users/ accessible
- ✅ Permissions fonctionnent

---

## ✅ CHECKLIST FINALE

### Backend ✅
- [x] API Users CRUD complète
- [x] API Role update
- [x] API Toggle active
- [x] API Ticket assignment
- [x] API Ticket status change
- [x] API Statistics
- [x] API Dashboard
- [x] Permissions basées sur rôle

### Frontend Citizen ✅
- [x] Login/Register
- [x] View personal tickets
- [x] Create ticket
- [ ] Notifications (à faire)
- [ ] Ticket timeline (à faire)

### Frontend Technician ❌
- [ ] Dashboard tickets (à faire)
- [ ] Filter tickets (à faire)
- [ ] Assign to self (à faire)
- [ ] Process ticket (à faire)
- [ ] Add comments/actions (à faire)
- [ ] Statistics view (à faire)

### Frontend Admin ✅
- [x] Admin dashboard
- [x] User management (CRUD)
- [x] Ticket management
- [ ] Settings configuration (partiel)
- [ ] Global statistics (à améliorer)
- [ ] Export reports (à faire)

---

## 🚀 PROCÉDURE DE TEST COMPLÈTE

### Étape 1: Reset DB
```bash
cd c:\Users\defal\Donnees\Code\Projet\projet_framework
python reset_database.py
```

### Étape 2: Lancer backend
```bash
cd server
python manage.py runserver 0.0.0.0:8000
```

### Étape 3: Tester API admin
```bash
python test_admin_login.py
```
Doit afficher: ✅ L'utilisateur est bien ADMIN

### Étape 4: Redémarrer Flutter
```bash
cd client/reclamations_app
flutter run
```
**IMPORTANT:** Faire un VRAI redémarrage (pas hot reload)

### Étape 5: Tester chaque rôle

**Test Citoyen:**
- Login: citoyen@test.com / 1234
- Doit arriver sur HomeScreen
- Voit SES tickets uniquement
- Peut créer nouveau ticket

**Test Technicien:**
- Login: technicien@test.com / 1234
- Doit arriver sur TechnicianDashboard (à créer)
- Voit TOUS les tickets
- Peut prendre en charge

**Test Admin:**
- Login: admin@test.com / 1234
- Doit arriver sur AdminDashboard
- Voit statistiques globales
- Peut gérer utilisateurs
- Peut tout faire

---

## 📝 PROCHAINES ÉTAPES

1. ✅ Backend complet (FAIT)
2. ❌ Créer TechnicianDashboardScreen
3. ❌ Améliorer TicketDetailScreen avec timeline
4. ❌ Ajouter notifications push
5. ❌ Créer écrans statistiques technicien
6. ❌ Export PDF/Excel pour admin

---

**Document créé le:** 25 Mars 2026  
**Statut:** Backend ✅ | Frontend partiel ⚠️  
**Prochaine étape:** Frontend Technicien
