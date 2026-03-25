import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'admin_dashboard_screen.dart';
import 'technician_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  String? _erreur;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _erreur = null;
    });

    final result = await _authService.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );

    setState(() => _loading = false);

    if (result['success'] == true) {
      // Get user role from result
      final userInfo = result['user'] as Map<String, dynamic>?;
      final userRole = userInfo?['role'] as String?;

      // DEBUG: Afficher les infos
      print('=== LOGIN SUCCESS ===');
      print('User Info: $userInfo');
      print('User Role: $userRole');
      print('=====================');

      // Navigate based on role
      Widget destinationScreen;

      if (userRole == 'ADMIN') {
        print('NAVIGATION: Admin Dashboard');
        destinationScreen = const AdminDashboardScreen();
      } else if (userRole == 'TECHNICIEN') {
        print('NAVIGATION: Technician Dashboard');
        destinationScreen = const TechnicianDashboardScreen();
      } else {
        print('NAVIGATION: Home Screen (role=$userRole)');
        // CITOYEN
        destinationScreen = const HomeScreen();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destinationScreen),
      );
    } else {
      setState(() {
        _erreur = result['message'];
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF006743),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo / Titre
                    const Icon(
                      Icons.support_agent,
                      color: Color(0xFF006743),
                      size: 60,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Gestion des Réclamations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006743),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Champ email
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Champ mot de passe
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Mot de passe',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    // Message d'erreur
                    if (_erreur != null) ...[
                      const SizedBox(height: 10),
                      Text(_erreur!, style: const TextStyle(color: Colors.red)),
                    ],

                    const SizedBox(height: 24),

                    // Bouton connexion
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006743),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Se connecter',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Lien vers inscription
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Pas encore de compte ?'),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text("S'inscrire"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
