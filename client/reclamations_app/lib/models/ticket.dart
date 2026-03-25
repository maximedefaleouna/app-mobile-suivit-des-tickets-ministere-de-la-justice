class Ticket {
  final int id;
  final String titre;
  final String description;
  final String typeTicket;
  final String statut;
  final String priorite;
  final String auteurNom;
  final String dateCreation;
  final String? assigneA;

  Ticket({
    required this.id,
    required this.titre,
    required this.description,
    required this.typeTicket,
    required this.statut,
    required this.priorite,
    required this.auteurNom,
    required this.dateCreation,
    this.assigneA,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    final auteur = json['auteur'] as Map<String, dynamic>?;
    final assigne = json['assigne_a'] as Map<String, dynamic>?;

    return Ticket(
      id: json['id'] as int,
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      typeTicket: json['type_ticket'] ?? '',
      statut: json['statut'] ?? '',
      priorite: json['priorite'] ?? '',
      auteurNom: auteur != null
          ? '${auteur["first_name"] ?? ''} ${auteur["last_name"] ?? ''}'
          : 'Inconnu',
      dateCreation: json['date_creation'] ?? '',
      assigneA: assigne != null
          ? '${assigne["first_name"] ?? ''} ${assigne["last_name"] ?? ''}'
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      'description': description,
      'type_ticket': typeTicket,
      'priorite': priorite,
    };
  }
}
