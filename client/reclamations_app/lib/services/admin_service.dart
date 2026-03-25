import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class AdminService {
  static const String baseUrl = 'http://192.168.1.66:8000/api';
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get all users
  Future<List<dynamic>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/'),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur lors du chargement des utilisateurs');
      }
    } catch (e) {
      throw Exception('Impossible de charger les utilisateurs.');
    }
  }

  // Update user role
  Future<Map<String, dynamic>> updateUserRole(
    String userId,
    String newRole,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/users/$userId/role/'),
        headers: await _headers(),
        body: jsonEncode({'role': newRole}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'user': data};
      } else {
        return {
          'success': false,
          'message': data['detail'] ?? 'Erreur lors de la mise à jour',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion au serveur.'};
    }
  }

  // Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$userId/'),
        headers: await _headers(),
      );

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get system statistics (admin view - all data)
  Future<Map<String, dynamic>> getSystemStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/statistics/'),
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

  // Get all tickets (admin view)
  Future<List<dynamic>> getAllTickets() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tickets/'),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is Map && data.containsKey('results')
            ? data['results']
            : data;
      } else {
        throw Exception('Erreur lors du chargement des tickets');
      }
    } catch (e) {
      throw Exception('Impossible de charger les tickets.');
    }
  }

  // Activate/Deactivate user
  Future<Map<String, dynamic>> toggleUserActive(
    String userId,
    bool isActive,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/users/$userId/'),
        headers: await _headers(),
        body: jsonEncode({'is_active': isActive}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'user': data};
      } else {
        return {
          'success': false,
          'message': data['detail'] ?? 'Erreur lors de la mise à jour',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion au serveur.'};
    }
  }
}
