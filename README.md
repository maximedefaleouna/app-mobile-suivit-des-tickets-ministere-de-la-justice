# Plateforme de Gestion des Reclamations et Tickets - Ministere de la Justice

Systeme d'information multiplateforme et API REST dedies a la modernisation, a la centralisation et au traitement securise des reclamations, incidents techniques et demandes de services administratifs pour le Ministere de la Justice.

## Contexte et Genese du Projet

Ce projet a ete concu pour repondre a un besoin operationnel identifie au niveau du Ministere de la Justice et de la Legislation.

Dans le cadre des initiatives de modernisation et de digitalisation des services publics, l'objectif est d'offrir une plateforme unifiee permettant de substituer aux circuits papier traditionnels et aux signalements disperses un dispositif numerique transparent, rapide et rigoureusement auditable.

### Defis Adresses

- Rapprochement des usagers et de l'administration : permettre aux citoyens et aux agents d'enregistrer leurs doleances ou incidents a tout moment et depuis n'importe quel terminal.
- Reduction des delais de traitement : automatiser l'assignation des requetes aux techniciens et equipes sectorielles competentes.
- Tracabilite et conformite institutionnelle : conserver un historique immuable de chaque etape d'instruction, garantissant la preuve et la continuite du service public.
- Pilotage strategique par la donnee : fournir a la hierarchie ministerielle des tableaux de bord analytiques mesurant les volumes, les typologies d'incidents et le taux effectif de resolution.

## Architecture Technique Globale

La solution s'articule autour d'un decouplage complet entre une API metier robuste et une interface utilisateur multiplateforme :

- Backend : Developpe sous Python avec Django et Django REST Framework (DRF), assurant la logique metier, les regles d'acces et la persistance relationnelle.
- Base de donnees : PostgreSQL heberge sur une infrastructure cloud avec support du pooling de connexions.
- Frontend : Application cliente developpee avec Flutter et Dart, compatible nativement avec Android, iOS, le Web de bureau et les postes de travail administratifs (Linux, Windows, macOS).
- Securite : Authentification sans etat basee sur des jetons JSON Web Tokens (SimpleJWT), hachage cryptographique des mots de passe (PBKDF2 SHA-256) et controle d'acces base sur les roles (RBAC).

## Espaces Utilisateurs et Fonctionnalites

Le systeme structure les droits et ecrans selon trois profils d'utilisateurs distincts :

### 1. Espace Citoyen et Agent Public
- Inscription et authentification securisees par adresse email.
- Formulaire de creation simplifie permettant de qualifier le type de demande (Incident technique, Reclamation, Demande de service) et le niveau de priorite (Basse, Normale, Haute, Critique).
- Tableau de bord personnel visualisant l'ensemble de ses tickets, leur etat d'avancement et les commentaires d'instruction.
- Fil d'echange bidirectionnel permettant d'apporter des precisions ou des pieces complementaires.

### 2. Espace Technicien et Support
- Vue filtree des tickets ouverts dans sa zone de competence ou assignes directement a son compte.
- Prise en charge des requetes et passage d'etat selon le workflow reglementaire.
- Redaction de commentaires internes ou destines a l'usager.
- Indicateurs individuels de performance (temps de reponse et volume de tickets traites).

### 3. Espace Administration et Supervision
- Vue panoramique de l'ensemble des tickets du Ministere avec filtres multicriteres (statut, priorite, type, dates).
- Gestion centralisee des comptes utilisateurs, activation de comptes et affectation des roles (Citoyen, Technicien, Administrateur).
- Attribution manuelle ou reaffectation d'un ticket a un agent specifique.
- Tableaux de bord statistiques consolidant le taux de resolution, la repartition par departement et l'analyse tendancielle des requetes.

## Workflow du Cycle de Vie d'un Ticket

Chaque requete suit un cycle de traitement strictement norme en 4 etapes :

1. OUVERT : Le ticket est cree par l'usager et attend sa prise en charge ou son affectation.
2. EN COURS : Le ticket est assigne a un technicien ou un gestionnaire qui instruit le dossier.
3. RESOLU : La reponse metier ou le depannage technique est effectue et valide.
4. CLOS : La reclamation est cloturee et versee a l'archivage institutionnel.

Chaque transition d'etat genere automatiquement une entree dans le journal d'audit (HistoriqueStatut) precisant l'ancien etat, le nouvel etat, l'identifiant de l'agent responsable et l'horodatage a la seconde.

## Specification des Points d'Acces de l'API (Endpoints)

L'API REST Django est securisee et expose les routes suivantes :

### Authentification et Profils
- POST `/api/auth/register/` : Enregistrement d'un nouvel usager.
- POST `/api/auth/login/` : Authentification et delivrance de la paire de jetons JWT (access et refresh).
- POST `/api/auth/refresh/` : Renouvellement du jeton de session arrive a expiration.
- GET `/api/auth/profil/` : Consultation des donnees de compte et du role attribue.

### Gestion des Tickets
- GET `/api/tickets/` : Liste filtree et paginee des tickets accessibles selon les droits de l'utilisateur.
- POST `/api/tickets/` : Enregistrement d'un nouveau ticket.
- GET `/api/tickets/{id}/` : Consultation detaillee d'un ticket avec historique et commentaires associes.
- PATCH `/api/tickets/{id}/changer_statut/` : Mise a jour de l'etat d'avancement (reserve aux techniciens et administrateurs).
- POST `/api/tickets/{id}/commenter/` : Ajout d'un commentaire d'echange sur le ticket.
- PATCH `/api/tickets/{id}/assigner/` : Affectation du ticket a un technicien support.

### Pilotage et Reporting
- GET `/api/dashboard/` : Indicateurs de synthese pour la page d'accueil de l'espace.
- GET `/api/statistics/` : Metriques consolidees pour les rapports d'activite ministeriels.

## Technologies et Dependances

### Serveur (Backend)
- Langage : Python 3.x
- Framework principal : Django 6.0
- API Toolkit : Django REST Framework (DRF) 3.15
- Authentification : djangorestframework-simplejwt 5.3
- Filtrage et CORS : django-filter, django-cors-headers
- Base de donnees : PostgreSQL via le connecteur psycopg2-binary
- Serveur de production : Gunicorn avec WhiteNoise pour la distribution des fichiers statiques

### Client (Frontend)
- Framework multiplateforme : Flutter 3.x
- Langage : Dart
- Gestion d'etat : BLoC / Cubit (architecture par etats et evenements)
- Communication HTTP : Paquet http avec intercepteur d'autorisation Bearer JWT
- Stockage persistant securise : shared_preferences pour la persistance locale des sessions
- Design : Material Design 3 aux couleurs ministerielles (palette verte #006743)

## Installation et Lancement Local

### Prerequis

- Python 3.11 ou superieur
- Flutter SDK (version stable 3.x)
- Une instance PostgreSQL accessible ou un environnement de test local

### 1. Configuration et Demarrage du Serveur Django

Positionnez-vous dans le repertoire serveur :

```bash
cd server
```

Creez et activez un environnement virtuel Python :

```bash
python3 -m venv venv
source venv/bin/activate
```

Installez les dependances requises :

```bash
pip install -r requirements.txt
```

Appliquez les migrations a la base de donnees :

```bash
python manage.py migrate
```

Creez un compte administrateur principal :

```bash
python manage.py createsuperuser
```

Demarrez le serveur de developpement :

```bash
python manage.py runserver 0.0.0.0:8000
```

L'API est des lors joignable sur `http://localhost:8000`.

### 2. Configuration et Lancement de l'Application Flutter

Dans un second terminal, positionnez-vous dans le repertoire du client mobile et de bureau :

```bash
cd client/reclamations_app
```

Recuperez l'ensemble des paquets Dart :

```bash
flutter pub get
```

Verifiez la disponibilite des peripheriques de test :

```bash
flutter devices
```

Lancez l'application (sur Chrome, simulateur Android ou poste local) :

```bash
flutter run
```

## Organisation du Depot

- `server/` : Code source du backend Django (modules accounts, tickets, configuration globale et scripts de deploiement).
- `server/tickets/` : Modeles de donnees (Ticket, Commentaire, HistoriqueStatut), controleurs de vues et regles d'assignation.
- `server/accounts/` : Modele CustomUser personnalise, controle d'acces par role et gestion JWT.
- `client/reclamations_app/` : Projet Flutter complet multiplateforme.
- `client/reclamations_app/lib/screens/` : Interfaces utilisateurs ventilees par profil (citoyen, technicien, administrateur).
- `client/reclamations_app/lib/services/` : Couche de services HTTP et passerelle API.
- `client/reclamations_app/lib/providers/` : Gestionnaires d'etat d'authentification et de session.

## Auteur

- Concepteur et Developpeur : Maxime DEFALEOUNA ([@maximedefaleouna](https://github.com/maximedefaleouna))

## Licence

Ce projet est distribue sous licence MIT. Libre a vous de l'utiliser, de l'adapter ou de le deployer pour d'autres administrations et cas d'usage institutionnels.
