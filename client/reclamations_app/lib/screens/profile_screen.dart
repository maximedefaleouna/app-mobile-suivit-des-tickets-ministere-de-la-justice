import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();

  Map<String, dynamic>? _userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      // TODO: Implement getProfile method in AuthService
      setState(() {
        _loading = false;
        _userData = {
          'email': 'user@example.com',
          'first_name': 'John',
          'last_name': 'Doe',
          'role': 'CITOYEN',
          'telephone': '',
        };
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: const Color(0xFF006743),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
          ? const Center(child: Text('Erreur de chargement'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF006743).withOpacity(0.2),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFF006743),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text(
                    '${_userData!['first_name']} ${_userData!['last_name']}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _userData!['email'],
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getRoleColor(_userData!['role']),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _userData!['role'],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Info Cards
                  _buildInfoCard(
                    icon: Icons.email,
                    label: 'Email',
                    value: _userData!['email'],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.phone,
                    label: 'Téléphone',
                    value: _userData!['telephone'] ?? 'Non renseigné',
                  ),

                  const SizedBox(height: 32),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Se déconnecter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF006743)),
        title: Text(label, style: TextStyle(color: Colors.grey[600])),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'ADMIN':
        return Colors.red;
      case 'TECHNICIEN':
        return Colors.orange;
      default:
        return const Color(0xFF006743);
    }
  }
}
