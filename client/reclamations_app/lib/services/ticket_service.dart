import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import 'auth_service.dart';
import '../models/ticket.dart';

class TicketService {
  String get _base => '${AppConstants.apiBaseUrl}/tickets';
  final AuthService _auth = AuthService();

  Future<List<Ticket>> listerTickets({String? statut, String? priorite}) async {
    try {
      String url = '$_base/';
      final params = <String, String>{};

      if (statut != null) params['statut'] = statut;
      if (priorite != null) params['priorite'] = priorite;

      if (params.isNotEmpty) {
        url += '?${Uri(queryParameters: params).query}';
      }

      final response = await _auth.getAuthorized(Uri.parse(url));

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
      final response = await _auth.getAuthorized(Uri.parse('$_base/$id/'));

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
      final response = await _auth.postAuthorized(
        Uri.parse('$_base/'),
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        return Ticket.fromJson(jsonDecode(response.body));
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Erreur (${response.statusCode}): ${errorBody.toString()}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changerStatut(int id, String nouveauStatut) async {
    try {
      final response = await _auth.patchAuthorized(
        Uri.parse('$_base/$id/changer_statut/'),
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
      final response = await _auth.postAuthorized(
        Uri.parse('$_base/$id/commenter/'),
        body: jsonEncode({'contenu': contenu}),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Erreur lors de l\'ajout du commentaire.');
      }
    } catch (e) {
      throw Exception('Impossible d\'ajouter un commentaire.');
    }
  }

  Future<void> assignerTicket(int id, int technicienId) async {
    try {
      final response = await _auth.patchAuthorized(
        Uri.parse('$_base/$id/assigner/'),
        body: jsonEncode({'technicien_id': technicienId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de l attribution du ticket.');
      }
    } catch (e) {
      throw Exception('Impossible d attribuer le ticket.');
    }
  }

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await _auth.getAuthorized(
        Uri.parse('${AppConstants.apiBaseUrl}/dashboard/'),
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
      final response = await _auth.getAuthorized(
        Uri.parse('${AppConstants.apiBaseUrl}/statistics/'),
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
