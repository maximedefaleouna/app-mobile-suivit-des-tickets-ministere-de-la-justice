import 'package:equatable/equatable.dart';

class AdminStats extends Equatable {
  final int totalUsers;
  final int totalTickets;
  final int ticketsOuverts;
  final int ticketsEnCours;
  final int ticketsResolus;
  final double tauxResolution;

  const AdminStats({
    required this.totalUsers,
    required this.totalTickets,
    required this.ticketsOuverts,
    required this.ticketsEnCours,
    required this.ticketsResolus,
    required this.tauxResolution,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsers: json['total_users'] ?? 0,
      totalTickets: json['total_tickets'] ?? 0,
      ticketsOuverts: json['tickets_ouverts'] ?? 0,
      ticketsEnCours: json['tickets_en_cours'] ?? 0,
      ticketsResolus: json['tickets_resolus'] ?? 0,
      tauxResolution: (json['taux_resolution'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_users': totalUsers,
      'total_tickets': totalTickets,
      'tickets_ouverts': ticketsOuverts,
      'tickets_en_cours': ticketsEnCours,
      'tickets_resolus': ticketsResolus,
      'taux_resolution': tauxResolution,
    };
  }

  @override
  List<Object?> get props => [
    totalUsers,
    totalTickets,
    ticketsOuverts,
    ticketsEnCours,
    ticketsResolus,
    tauxResolution,
  ];
}
