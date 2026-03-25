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

        // Récupérer les informations de l'utilisateur
        final userInfo = await _getUserProfile(data['access']);

        if (userInfo != null) {
          await prefs.setString('user_role', userInfo['role'] ?? 'CITOYEN');
          await prefs.setString('user_email', userInfo['email'] ?? email);
          await prefs.setString(
            'user_name',
            '${userInfo['first_name'] ?? ''} ${userInfo['last_name'] ?? ''}'
                .trim(),
          );
        }

        return {
          'success': true,
          'access': data['access'],
          'refresh': data['refresh'],
          'user': userInfo,
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

  Future<Map<String, dynamic>?> _getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profil/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'username': email.split('@')[0], // Generate username from email
          if (phone != null && phone.isNotEmpty) 'telephone': phone,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Stocker les tokens si fournis
        if (data.containsKey('access')) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', data['access']);
          await prefs.setString('refresh_token', data['refresh']);
        }

        return {
          'success': true,
          'message': data['message'] ?? 'Compte créé avec succès',
        };
      } else {
        // Gérer les erreurs spécifiques
        String message = 'Erreur lors de l\'inscription';
        if (data.containsKey('errors')) {
          message = data['errors'].toString();
        } else if (data.containsKey('email')) {
          message = data['email'];
        } else if (data.containsKey('password_errors')) {
          message = data['password_errors'].join(', ');
        } else if (data.containsKey('detail')) {
          message = data['detail'];
        }

        return {'success': false, 'message': message};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion au serveur.'};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_role');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
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
