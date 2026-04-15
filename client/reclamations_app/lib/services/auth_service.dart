import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class AuthService {
  String get baseUrl => AppConstants.apiBaseUrl;

  Future<void> _storeUserSession({
    required String access,
    required String refresh,
    Map<String, dynamic>? userInfo,
    String? fallbackEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);

    if (userInfo != null) {
      await prefs.setString('user_role', userInfo['role'] ?? 'CITOYEN');
      await prefs.setString('user_email', userInfo['email'] ?? fallbackEmail ?? '');
      await prefs.setString(
        'user_name',
        '${userInfo['first_name'] ?? ''} ${userInfo['last_name'] ?? ''}'.trim(),
      );
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final userInfo = await getProfile(token: data['access']);
        await _storeUserSession(
          access: data['access'],
          refresh: data['refresh'],
          userInfo: userInfo,
          fallbackEmail: email,
        );

        return {
          'success': true,
          'access': data['access'],
          'refresh': data['refresh'],
          'user': userInfo,
        };
      }

      return {
        'success': false,
        'message': data['detail'] ?? 'Email ou mot de passe incorrect.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion au serveur.'};
    }
  }

  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await logout();
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode != 200) {
        await logout();
        return false;
      }

      final data = jsonDecode(response.body);
      final access = data['access'] as String?;
      if (access == null || access.isEmpty) {
        await logout();
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', access);
      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }

  Future<Map<String, String>> _authHeaders({String? token}) async {
    final authToken = token ?? await getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (authToken != null && authToken.isNotEmpty)
        'Authorization': 'Bearer $authToken',
    };
  }

  Future<http.Response> getAuthorized(Uri uri) async {
    var response = await http.get(uri, headers: await _authHeaders());
    if (response.statusCode == 401 && await refreshAccessToken()) {
      response = await http.get(uri, headers: await _authHeaders());
    }
    return response;
  }

  Future<http.Response> postAuthorized(Uri uri, {Object? body}) async {
    var response = await http.post(
      uri,
      headers: await _authHeaders(),
      body: body,
    );
    if (response.statusCode == 401 && await refreshAccessToken()) {
      response = await http.post(
        uri,
        headers: await _authHeaders(),
        body: body,
      );
    }
    return response;
  }

  Future<http.Response> patchAuthorized(Uri uri, {Object? body}) async {
    var response = await http.patch(
      uri,
      headers: await _authHeaders(),
      body: body,
    );
    if (response.statusCode == 401 && await refreshAccessToken()) {
      response = await http.patch(
        uri,
        headers: await _authHeaders(),
        body: body,
      );
    }
    return response;
  }

  Future<http.Response> deleteAuthorized(Uri uri) async {
    var response = await http.delete(uri, headers: await _authHeaders());
    if (response.statusCode == 401 && await refreshAccessToken()) {
      response = await http.delete(uri, headers: await _authHeaders());
    }
    return response;
  }

  Future<Map<String, dynamic>?> getProfile({String? token}) async {
    try {
      final response = token != null
          ? await http.get(
              Uri.parse('$baseUrl/auth/profil/'),
              headers: await _authHeaders(token: token),
            )
          : await getAuthorized(Uri.parse('$baseUrl/auth/profil/'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      if (response.statusCode == 401) {
        await logout();
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
          'username': email.split('@')[0],
          if (phone != null && phone.isNotEmpty) 'telephone': phone,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        if (data.containsKey('access')) {
          await _storeUserSession(
            access: data['access'],
            refresh: data['refresh'],
            userInfo: data['user'] as Map<String, dynamic>?,
            fallbackEmail: email,
          );
        }

        return {
          'success': true,
          'message': data['message'] ?? 'Compte cree avec succes',
        };
      }

      String message = 'Erreur lors de l inscription';
      if (data.containsKey('errors')) {
        message = data['errors'].toString();
      } else if (data.containsKey('email')) {
        message = data['email'].toString();
      } else if (data.containsKey('password_errors')) {
        message = (data['password_errors'] as List).join(', ');
      } else if (data.containsKey('detail')) {
        message = data['detail'].toString();
      }

      return {'success': false, 'message': message};
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
