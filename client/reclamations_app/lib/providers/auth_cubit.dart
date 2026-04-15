import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user/user_model.dart';
import '../services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(const AuthInitial());

  Future<void> checkAuthentication() async {
    final isLogged = await _authService.isLoggedIn();
    if (!isLogged) {
      emit(const AuthUnauthenticated());
      return;
    }

    final profile = await _authService.getProfile();
    if (profile == null) {
      await _authService.logout();
      emit(const AuthUnauthenticated());
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    final role = profile['role']?.toString() ?? 'CITOYEN';
    final email = profile['email']?.toString() ?? '';
    final name =
        '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'.trim();

    await prefs.setString('user_role', role);
    await prefs.setString('user_email', email);
    await prefs.setString('user_name', name);

    emit(
      AuthAuthenticated(
        token: token,
        role: role,
        email: email,
        name: name,
      ),
    );
  }

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());

    try {
      final result = await _authService.login(email, password);

      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token') ?? '';
        final role = prefs.getString('user_role') ?? '';
        final userEmail = prefs.getString('user_email') ?? '';
        final userName = prefs.getString('user_name') ?? '';

        emit(
          AuthAuthenticated(
            token: token,
            role: role,
            email: userEmail,
            name: userName,
          ),
        );
      } else {
        emit(AuthError(message: result['message'] ?? 'Erreur de connexion'));
      }
    } catch (e) {
      emit(AuthError(message: 'Erreur de connexion au serveur'));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    emit(const AuthLoading());

    try {
      final result = await _authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );

      if (result['success'] == true) {
        // Auto-login after successful registration
        await login(email, password);
      } else {
        emit(
          AuthError(
            message: result['message'] ?? 'Erreur lors de l\'inscription',
          ),
        );
      }
    } catch (e) {
      emit(AuthError(message: 'Erreur de connexion au serveur'));
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    emit(const AuthUnauthenticated());
  }

  User? getCurrentUser() {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      return User(
        id: 0,
        email: currentState.email,
        username: currentState.email.split('@').first,
        firstName: currentState.name.split(' ').first,
        lastName: currentState.name.split(' ').last,
        role: _parseRole(currentState.role),
        isActive: true,
        dateJoined: DateTime.now(),
      );
    }
    return null;
  }

  UserRole _parseRole(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return UserRole.admin;
      case 'TECHNICIEN':
      case 'TECHNICIAN':
        return UserRole.technician;
      default:
        return UserRole.citizen;
    }
  }

  bool get isAuthenticated => state is AuthAuthenticated;
  String? get userRole {
    if (state is AuthAuthenticated) {
      return (state as AuthAuthenticated).role;
    }
    return null;
  }
}
