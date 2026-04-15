import 'package:equatable/equatable.dart';

class Ticket extends Equatable {
  final int id;
  final String titre;
  final String description;
  final String typeTicket;
  final String statut;
  final String priorite;
  final String auteurNom;
  final DateTime dateCreation;
  final String? assigneA;
  final String? localisation;
  final List<String>? images;
  final List<TicketComment> commentaires;
  final List<TicketHistory> historique;

  const Ticket({
    required this.id,
    required this.titre,
    required this.description,
    required this.typeTicket,
    required this.statut,
    required this.priorite,
    required this.auteurNom,
    required this.dateCreation,
    this.assigneA,
    this.localisation,
    this.images,
    this.commentaires = const [],
    this.historique = const [],
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    final auteur = json['auteur'] as Map<String, dynamic>?;
    final assigne = json['assigne_a'] as Map<String, dynamic>?;

    return Ticket(
      id: json['id'] ?? 0,
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      typeTicket: json['type_ticket'] ?? '',
      statut: json['statut'] ?? '',
      priorite: json['priorite'] ?? '',
      auteurNom: auteur != null
          ? '${auteur["first_name"] ?? ""} ${auteur["last_name"] ?? ""}'.trim()
          : 'Inconnu',
      dateCreation:
          DateTime.tryParse(json['date_creation'] ?? '') ?? DateTime.now(),
      assigneA: assigne != null
          ? '${assigne["first_name"] ?? ""} ${assigne["last_name"] ?? ""}'
                .trim()
          : null,
      localisation: json['localisation'] as String?,
      images: (json['images'] as List?)?.map((e) => e.toString()).toList(),
      commentaires: (json['commentaires'] as List<dynamic>? ?? [])
          .map((e) => TicketComment.fromJson(e as Map<String, dynamic>))
          .toList(),
      historique: (json['historique'] as List<dynamic>? ?? [])
          .map((e) => TicketHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      'description': description,
      'type_ticket': typeTicket,
      'priorite': priorite,
      if (localisation != null) 'localisation': localisation,
    };
  }

  bool get isOuvert => statut.toUpperCase() == 'OUVERT';
  bool get isEnCours => statut.toUpperCase() == 'EN_COURS';
  bool get isResolu => statut.toUpperCase() == 'RESOLU';
  bool get isFerme => statut.toUpperCase() == 'CLOS';

  @override
  List<Object?> get props => [
    id,
    titre,
    description,
    typeTicket,
    statut,
    priorite,
    auteurNom,
    dateCreation,
    assigneA,
    localisation,
    images,
    commentaires,
    historique,
  ];
}

class TicketComment extends Equatable {
  final int id;
  final String auteurNom;
  final String contenu;
  final DateTime date;

  const TicketComment({
    required this.id,
    required this.auteurNom,
    required this.contenu,
    required this.date,
  });

  factory TicketComment.fromJson(Map<String, dynamic> json) {
    final auteur = json['auteur'] as Map<String, dynamic>?;
    return TicketComment(
      id: json['id'] ?? 0,
      auteurNom: auteur != null
          ? '${auteur["first_name"] ?? ""} ${auteur["last_name"] ?? ""}'.trim()
          : 'Utilisateur',
      contenu: json['contenu'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, auteurNom, contenu, date];
}

class TicketHistory extends Equatable {
  final int id;
  final String ancienStatut;
  final String nouveauStatut;
  final String modifiePar;
  final DateTime dateChangement;

  const TicketHistory({
    required this.id,
    required this.ancienStatut,
    required this.nouveauStatut,
    required this.modifiePar,
    required this.dateChangement,
  });

  factory TicketHistory.fromJson(Map<String, dynamic> json) {
    final auteur = json['modifie_par'] as Map<String, dynamic>?;
    return TicketHistory(
      id: json['id'] ?? 0,
      ancienStatut: json['ancien_statut'] ?? '',
      nouveauStatut: json['nouveau_statut'] ?? '',
      modifiePar: auteur != null
          ? '${auteur["first_name"] ?? ""} ${auteur["last_name"] ?? ""}'.trim()
          : 'Systeme',
      dateChangement:
          DateTime.tryParse(json['date_changement'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    ancienStatut,
    nouveauStatut,
    modifiePar,
    dateChangement,
  ];
}
