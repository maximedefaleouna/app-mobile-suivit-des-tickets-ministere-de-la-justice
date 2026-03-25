# 🏗️ PLAN DE RECONSTRUCTION - SYSTÈME COMPLET À 3 RÔLES

## 📋 ARCHITECTURE DES RÔLES

### 1. CITOYEN (Citizen)
**Permissions:**
- ✅ S'inscrire / Se connecter
- ✅ Créer un ticket (incident, réclamation, demande)
- ✅ Voir SES tickets uniquement
- ✅ Suivre l'état de ses tickets
- ✅ Voir historique de SES demandes
- ✅ Recevoir notifications pour SES tickets

**Interface Flutter:**
- HomeScreen → Ses tickets personnels
- CreateTicketScreen → Formulaire de création
- TicketDetailScreen → Détails d'un ticket
- ProfileScreen → Son profil

---

### 2. TECHNICIEN (Technician - Cellule Informatique)
**Permissions:**
- ✅ Se connecter
- ✅ Tableau de bord des tickets (TOUS les tickets)
- ✅ Voir tickets non assignés
- ✅ Prendre en charge un ticket (s'assigner)
- ✅ Changer statut des tickets
- ✅ Ajouter commentaires/actions
- ✅ Filtrer/rechercher tickets
- ✅ Statistiques de traitement

**Interface Flutter:**
- TechnicianDashboard → Tous les tickets
- TicketAssignment → Prendre en charge
- TicketProcessing → Traiter un ticket
- StatisticsScreen → Stats de performance

---

### 3. ADMIN (Administrateur)
**Permissions:**
- ✅ Tout ce que fait le technicien
- ✅ Gérer TOUS les utilisateurs (CRUD)
- ✅ Changer les rôles (Citoyen → Technicien → Admin)
- ✅ Activer/Désactiver comptes
- ✅ Configurer types de tickets
- ✅ Configurer priorités
- ✅ Configurer délais de traitement
- ✅ Archivage automatique
- ✅ Statistiques globales
- ✅ Export rapports

**Interface Flutter:**
- AdminDashboard → Vue d'ensemble
- AdminUsersScreen → Gestion utilisateurs
- AdminTicketsScreen → Gestion tickets
- AdminSettingsScreen → Configuration
- GlobalStatisticsScreen → Stats complètes

---

## 🔧 BACKEND - API MANQUANTES À CRÉER

### A. Accounts App (`server/accounts/`)

**Fichier: `views.py`** - Ajouter:
```python
# GET /api/users/ - Liste tous les utilisateurs (ADMIN only)
# GET /api/users/<id>/ - Détail utilisateur
# PUT /api/users/<id>/role/ - Changer rôle (ADMIN only)
# PUT /api/users/<id>/toggle-active/ - Activer/Désactiver (ADMIN only)
# DELETE /api/users/<id>/ - Supprimer utilisateur (ADMIN only)
```

### B. Tickets App (`server/tickets/`)

**Fichier: `views.py`** - Déjà existant mais à vérifier:
```python
# GET /api/tickets/ - Liste tickets (filtré par rôle)
# POST /api/tickets/ - Créer ticket
# GET /api/tickets/<id>/ - Détail ticket
# PUT /api/tickets/<id>/ - Modifier ticket
# PUT /api/tickets/<id>/assign/ - Assigner à technicien
# PUT /api/tickets/<id>/status/ - Changer statut
# GET /api/tickets/unassigned/ - Tickets non assignés
# GET /api/statistics/ - Statistiques (déjà existant)
# GET /api/dashboard/ - Dashboard data (déjà existant)
```

---

## 📱 FRONTEND - ÉCRANS À CRÉER/MODIFIER

### Pour CITOYEN:
- ✅ HomeScreen (déjà existant) → Affiche SES tickets
- ✅ CreateTicketScreen (déjà existant)
- ✅ TicketDetailScreen (à améliorer avec timeline)
- ✅ ProfileScreen (déjà existant)

### Pour TECHNICIEN:
- ❌ TechnicianDashboardScreen → NOUVEAU
- ❌ TicketAssignmentScreen → NOUVEAU
- ✅ TicketDetailScreen → Améliorer avec actions
- ❌ TechnicianStatisticsScreen → NOUVEAU

### Pour ADMIN:
- ✅ AdminDashboardScreen (déjà existant)
- ✅ AdminUsersScreen (déjà existant)
- ✅ AdminTicketsScreen (déjà existant)
- ✅ AdminSettingsScreen (déjà existant)

---

## 🔄 WORKFLOW COMPLET

### Workflow 1: Création de ticket par Citoyen
```
1. Citoyen se connecte
2. Va sur HomeScreen → "Nouveau ticket"
3. Remplit formulaire (type, sujet, description)
4. Soumet → Ticket créé avec statut "OUVERT"
5. Reçoit confirmation
6. Peut voir son ticket dans "Mes tickets"
```

### Workflow 2: Prise en charge par Technicien
```
1. Technicien se connecte → TechnicianDashboard
2. Voit liste de TOUS les tickets
3. Filtre par "Non assigné"
4. Clique sur un ticket → "Prendre en charge"
5. Le ticket lui est assigné
6. Change statut → "EN COURS"
7. Ajoute commentaire/action
```

### Workflow 3: Résolution par Technicien
```
1. Technicien traite le ticket
2. Ajoute solution/réponse
3. Change statut → "RÉSOLU"
4. Date de résolution enregistrée automatiquement
5. Citoyen reçoit notification
6. Après vérification → "CLOS"
```

### Workflow 4: Administration par Admin
```
1. Admin se connecte → AdminDashboard
2. Voit statistiques globales
3. Va dans "Gestion utilisateurs"
4. Crée/modifie/supprime utilisateurs
5. Change les rôles si besoin
6. Configure types de tickets
7. Archive les vieux tickets
```

---

## 🎯 PRIORITÉS DE DÉVELOPPEMENT

### Phase 1: Backend - APIs manquantes
1. ✅ API Users CRUD (pour admin)
2. ✅ API Ticket assignment
3. ✅ API Ticket status change
4. ✅ Permissions basées sur le rôle

### Phase 2: Frontend - Écrans Technicien
1. TechnicianDashboardScreen
2. TicketAssignmentScreen
3. TicketProcessingScreen
4. TechnicianStatisticsScreen

### Phase 3: Frontend - Améliorations
1. Timeline dans TicketDetailScreen
2. Notifications en temps réel
3. Filtrage avancé
4. Recherche

### Phase 4: Admin avancé
1. Configuration types de tickets
2. Archivage automatique
3. Export rapports
4. Analytics avancés

---

## 📊 MODÈLE DE DONNÉES

### User Model (déjà existant):
```python
email (username field)
password (hashed)
first_name
last_name
role: CITOYEN | TECHNICIEN | ADMIN
telephone
is_active
is_staff
date_joined
```

### Ticket Model (déjà existant):
```python
titre
description
auteur (ForeignKey User)
statut: OUVERT | EN_COURS | RESOLU | CLOS
type: INCIDENT | RECLAMATION | DEMANDE
priorite: FAIBLE | MOYENNE | ELEVEE | CRITIQUE
assigned_to (ForeignKey User, nullable)
date_creation
date_resolution (nullable)
```

---

## 🔐 GESTION DES PERMISSIONS

### Middleware/Fonction utilitaire:
```python
def is_admin(user): return user.role == 'ADMIN'
def is_technician(user): return user.role in ['TECHNICIEN', 'ADMIN']
def is_citizen(user): return user.role == 'CITOYEN'
```

### Permissions par endpoint:
```
/api/auth/* → Public ou Authenticated
/api/users/* → Admin only
/api/tickets/ → 
  - GET: All authenticated (filtered by role)
  - POST: All authenticated
  - PUT/PATCH: Assigned technician or Admin
/api/statistics/ → All authenticated (filtered by role)
/api/dashboard/ → All authenticated (filtered by role)
```

---

## ✅ CHECKLIST FINALE

### Backend:
- [ ] Users API (CRUD complet)
- [ ] Role change API
- [ ] Toggle active API
- [ ] Ticket assignment API
- [ ] Ticket status API
- [ ] Unassigned tickets API
- [ ] Permissions checkers

### Frontend Citizen:
- [x] Login/Register
- [x] View personal tickets
- [x] Create ticket
- [ ] Notifications
- [ ] Ticket timeline

### Frontend Technician:
- [ ] Dashboard tickets
- [ ] Filter tickets
- [ ] Assign to self
- [ ] Process ticket
- [ ] Add comments/actions
- [ ] Statistics view

### Frontend Admin:
- [x] Admin dashboard
- [x] User management
- [x] Ticket management
- [ ] Settings configuration
- [ ] Global statistics
- [ ] Export reports

---

**Date:** 25 Mars 2026
**Objectif:** Reconstruire proprement avec 3 rôles distincts
**Approche:** Backend d'abord, puis Frontend par rôle
