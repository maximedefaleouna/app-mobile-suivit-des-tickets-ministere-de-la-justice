# 📱 GUIDE COMPLET - INTERFACE ADMINISTRateur (Mobile App)

## ✅ TOUT SE PASSE DANS L'APPLICATION MOBILE

Conformément aux exigences du Ministère de la Justice, **toute l'administration se fait via l'application mobile Flutter**. Il n'y a pas d'interface web séparée.

---

## 🎯 ACCÈS À L'INTERFACE ADMIN

### Étape 1 : Créer un compte Admin

**Option A - Script Python (Recommandé)**
```bash
cd c:\Users\defal\Donnees\Code\Projet\projet_framework
python create_test_users.py
```

Cela crée : `admin@test.com` / `1234` (Role: ADMIN)

**Option B - Django Shell**
```bash
cd server
python manage.py shell
```

```python
from accounts.models import CustomUser
admin = CustomUser.objects.create_user(
    email='admin@justice.gov',
    username='admin',
    password='admin123',
    first_name='Admin',
    last_name='Justice',
    role=CustomUser.Role.ADMIN
)
print(f"✓ Admin créé: {admin.email} / admin123")
```

### Étape 2 : Se connecter dans l'app mobile

1. Lancez l'application Flutter
2. Sur l'écran de connexion, utilisez :
   - **Email**: `admin@test.com`
   - **Mot de passe**: `1234`
3. Appuyez sur "Se connecter"

---

## 📍 OÙ TROUVER LE DASHBOARD ADMIN ?

### Après connexion automatique

**Dès que vous vous connectez en tant qu'ADMIN**, vous arrivez automatiquement sur le **Tableau de bord Administrateur** !

```
┌─────────────────────────────────────┐
│ Administration               [🔄] │
├─────────────────────────────────────┤
│                                     │
│  ┌──────────────────────────────┐  │
│  │   👑 Administration          │  │
│  │   Tableau de bord            │  │
│  │   Gestion complète           │  │
│  └──────────────────────────────┘  │
│                                     │
│  STATISTIQUES DU SYSTÈME           │
│  ┌──────┐ ┌──────┐                 │
│  │Tickets│ │Users │                │
│  │  25   │ │  8   │                │
│  └──────┘ └──────┘                 │
│  ┌──────┐ ┌──────┐                 │
│  │Ouverts│ │Résolus│               │
│  │   5   │ │  12   │               │
│  └──────┘ └──────┘                 │
│                                     │
│  GESTION                            │
│  ┌────────────────────────────┐    │
│  │ 👥 Gestion des utilisateurs│    │
│  │    Créer, modifier...      │ →  │
│  └────────────────────────────┘    │
│  ┌────────────────────────────┐    │
│  │ 📁 Gestion des tickets     │    │
│  │    Voir et gérer...        │ →  │
│  └────────────────────────────┘    │
│  ┌────────────────────────────┐    │
│  │ 📊 Statistiques avancées   │    │
│  │    Analytics complets      │ →  │
│  └────────────────────────────┘    │
│  ┌────────────────────────────┐    │
│  │ ⚙️ Paramètres système      │    │
│  │    Configuration...        │ →  │
│  └────────────────────────────┘    │
└─────────────────────────────────────┘
```

---

## 🎨 FONCTIONNALITÉS ADMIN DISPONIBLES

### 1. 📊 Vue d'ensemble du Dashboard

**Ce que vous voyez :**
- ✅ Statistiques en temps réel
- ✅ Total des tickets
- ✅ Nombre d'utilisateurs
- ✅ Tickets ouverts/résolus
- ✅ Accès rapide à toutes les sections

**Actions disponibles :**
- 🔄 Bouton "Actualiser" pour mettre à jour les données

---

### 2. 👥 Gestion des Utilisateurs

**Chemin :** Dashboard → "Gestion des utilisateurs"

**Fonctionnalités :**
- ✅ Voir TOUS les utilisateurs du système
- ✅ Changer les rôles (CITOYEN → TECHNICIEN → ADMIN)
- ✅ Activer/Désactiver des comptes
- ✅ Voir les détails (email, nom, rôle)

**Comment changer un rôle :**
1. Ouvrez la liste des utilisateurs
2. Trouvez l'utilisateur
3. Appuyez sur les 3 points (⋮) à droite
4. Sélectionnez "Changer le rôle"
5. Choisissez le nouveau rôle
6. Confirmez

**Comment activer/désactiver :**
1. Appuyez sur les 3 points (⋮)
2. Sélectionnez "Activer" ou "Désactiver"
3. Confirmez l'action

---

### 3. 📁 Gestion des Tickets

**Chemin :** Dashboard → "Gestion des tickets"

**Fonctionnalités :**
- ✅ Voir TOUS les tickets (de tous les utilisateurs)
- ✅ Filtrer par statut (Ouvert, En cours, Résolu, Clos)
- ✅ Accéder au détail de chaque ticket
- ✅ Modifier les statuts
- ✅ Assigner des techniciens
- ✅ Ajouter des commentaires

**Filtres disponibles :**
- Tous
- Ouvert
- En cours
- Résolu
- Clos

---

### 4. 📊 Statistiques Avancées

**Chemin :** Dashboard → "Statistiques avancées"

**Données affichées :**
- ✅ Total des tickets
- ✅ Distribution par statut (graphique)
- ✅ Distribution par type (graphique)
- ✅ Distribution par priorité
- ✅ Temps moyen de résolution
- ✅ Évolution sur 30 jours

**Mise à jour :**
- 🔄 Bouton "Actualiser" en haut à droite

---

### 5. ⚙️ Paramètres Système

**Chemin :** Dashboard → "Paramètres système"

**Sections visibles :**
- ✅ Types de tickets configurés
  - Incident technique
  - Réclamation
  - Demande de service
  
- ✅ Priorités disponibles
  - Basse
  - Normale
  - Haute
  - Critique
  
- ✅ Statuts du workflow
  - Ouvert
  - En cours
  - Résolu
  - Clos

**Note :** Ces paramètres sont définis dans le code backend.

---

## 🔄 WORKFLOW COMPLET - EXEMPLE PRATIQUE

### Scénario : Gérer une réclamation citoyenne

**1. Le citoyen crée un ticket**
- Login : `citoyen@test.com`
- Crée un ticket "Problème casier judiciaire"
- Statut initial: OUVERT

**2. L'admin voit le ticket**
- Login : `admin@test.com`
- Dashboard → "Gestion des tickets"
- Voit le nouveau ticket en haut de liste

**3. L'admin assigne le ticket**
- Ouvre le détail du ticket
- Clique sur "Modifier"
- Assigne à un technicien
- Change le statut: EN_COURS

**4. Le technicien traite**
- Login : `technicien@test.com`
- Voit le ticket assigné dans son dashboard
- Traite le problème
- Ajoute un commentaire
- Change le statut: RESOLU

**5. L'admin valide**
- Reçoit une notification (futur)
- Vérifie le traitement
- Si OK: Change le statut: CLOS
- Archive le ticket

---

## 📋 TABLEAU COMPARATIF DES RÔLES

| Fonctionnalité | CITOYEN | TECHNICIEN | ADMIN |
|----------------|---------|------------|-------|
| Créer des tickets | ✅ | ✅ | ✅ |
| Voir SES tickets | ✅ | ❌ | ✅ (TOUS) |
| Voir TOUS les tickets | ❌ | Partiel | ✅ |
| Changer statuts | ❌ | ✅ (assignés) | ✅ (TOUS) |
| Assigner tickets | ❌ | ❌ | ✅ |
| Gérer utilisateurs | ❌ | ❌ | ✅ |
| Voir statistiques | Personnelles | Limitées | ✅ (COMPLÈTES) |
| Paramètres système | ❌ | ❌ | ✅ |

---

## 🎯 RÉSUMÉ - OÙ TROUVER CHAQUE CHOSE

### Dans l'Application Mobile

| Élément | Localisation | Description |
|---------|-------------|-------------|
| **Dashboard Admin** | Page principale après login admin | Vue d'ensemble |
| **Utilisateurs** | Dashboard → "Gestion des utilisateurs" | CRUD users |
| **Tickets** | Dashboard → "Gestion des tickets" | Tous les tickets |
| **Statistiques** | Dashboard → "Statistiques avancées" | Analytics |
| **Paramètres** | Dashboard → "Paramètres système" | Configuration |
| **Profil** | Bottom nav → "Profil" | Infos personnelles |

---

## 🔒 SÉCURITÉ ET PERMISSIONS

### Protection des accès

- ✅ Seul un utilisateur avec `role='ADMIN'` peut accéder au dashboard admin
- ✅ Les vérifications sont faites côté backend (API)
- ✅ Les tokens JWT contiennent le rôle de l'utilisateur
- ✅ Chaque API call vérifie les permissions

### Comment ça marche

```dart
// Dans l'API Django
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def dashboard_view(request):
    user = request.user
    
    if user.role == 'ADMIN':
        # Admin voit tout
        queryset = Ticket.objects.all()
    else:
        # Autres voient seulement leurs tickets
        queryset = Ticket.objects.filter(auteur=user)
```

---

## 💡 ASTUCES ET BONNES PRATIQUES

### Pour les Administrateurs

1. **Vérifiez régulièrement les statistiques**
   - Dashboard → "Statistiques avancées"
   - Surveillez les tendances

2. **Gérez les utilisateurs actifs**
   - Désactivez les comptes inutilisés
   - Attribuez les bons rôles

3. **Supervisez les tickets critiques**
   - Filtrez par "CRITIQUE"
   - Assurez-vous du traitement rapide

4. **Archivez les anciens tickets**
   - Changez le statut à "CLOS"
   - Gardez une base propre

### Pour les Techniciens

1. **Consultez votre dashboard quotidiennement**
2. **Traitez les tickets par priorité**
3. **Ajoutez des commentaires réguliers**
4. **Mettez à jour les statuts promptly**

### Pour les Citoyens

1. **Créez des tickets clairs et précis**
2. **Suivez l'avancement dans l'app**
3. **Consultez l'historique**

---

## 🎉 CONCLUSION

### ✅ TOUT EST DANS L'APP MOBILE

Contrairement aux systèmes traditionnels avec interface web séparée, **notre système utilise exclusivement l'application mobile Flutter** pour :

- ✅ La gestion quotidienne
- ✅ L'administration complète
- ✅ Le suivi des tickets
- ✅ La gestion des utilisateurs
- ✅ Les statistiques

### Avantages

- 📱 **100% mobile** - Accessible partout
- 🎯 **Unifié** - Une seule interface
- 🔒 **Sécurisé** - Rôles et permissions
- 📊 **Complet** - Toutes les fonctionnalités
- ⚡ **Rapide** - Pas de navigateur nécessaire

---

**Développé pour le Ministère de la Justice et de la Législation**  
**Université de Kara - 2024/2025**
