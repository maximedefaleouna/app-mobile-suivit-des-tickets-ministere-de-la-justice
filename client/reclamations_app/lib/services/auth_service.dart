import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Pour Android Emulator: http://10.0.2.2:8000
  // Pour iOS Simulator: http://localhost:8000
  // Pour appareil physique: http://YOUR_IP:8000
  static const String baseUrl = 'http://192.168.1.66:8000/api';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('access_token', data['access']);
        await prefs.setString('refresh_token', data['refresh']);

        return {
          'success': true,
          'access': data['access'],
          'refresh': data['refresh'],
        };
      } else {
        return {
          'success': false,
          'message': data['detail'] ?? 'Email ou mot de passe incorrect.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion au serveur.'};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
