import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket.dart';
import 'auth_service.dart';

class TicketService {
  // Pour Android Emulator: http://10.0.2.2:8000
  // Pour iOS Simulator: http://localhost:8000
  // Pour appareil physique: http://YOUR_IP:8000
  static const String _base = 'http://192.168.1.66:8000/api/tickets';
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getAccessToken();

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Ticket>> listerTickets({String? statut, String? priorite}) async {
    try {
      String url = '$_base/';
      final params = <String, String>{};

      if (statut != null) params['statut'] = statut;
      if (priorite != null) params['priorite'] = priorite;

      if (params.isNotEmpty) {
        url += '?${Uri(queryParameters: params).query}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List results = data is Map && data.containsKey('results')
            ? data['results']
            : data;

        return results.map((j) => Ticket.fromJson(j)).toList();
      } else {
        throw Exception('Erreur serveur (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Impossible de charger les tickets.');
    }
  }

  Future<Ticket> getTicket(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/$id/'),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        return Ticket.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Ticket introuvable.');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération du ticket.');
    }
  }

  Future<Ticket> creerTicket(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/'),
        headers: await _headers(),
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        return Ticket.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Erreur (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création du ticket.');
    }
  }

  Future<void> changerStatut(int id, String nouveauStatut) async {
    try {
      final response = await http.patch(
        Uri.parse('$_base/$id/changer_statut/'),
        headers: await _headers(),
        body: jsonEncode({'statut': nouveauStatut}),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors du changement de statut.');
      }
    } catch (e) {
      throw Exception('Impossible de changer le statut.');
    }
  }

  Future<void> commenter(int id, String contenu) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/$id/commenter/'),
        headers: await _headers(),
        body: jsonEncode({'contenu': contenu}),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Erreur lors de l\'ajout du commentaire.');
      }
    } catch (e) {
      throw Exception('Impossible d\'ajouter un commentaire.');
    }
  }

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.66:8000/api/dashboard/'),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur lors du chargement du dashboard');
      }
    } catch (e) {
      throw Exception('Impossible de charger le dashboard.');
    }
  }

  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.66:8000/api/statistics/'),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur lors du chargement des statistiques');
      }
    } catch (e) {
      throw Exception('Impossible de charger les statistiques.');
    }
  }
}
