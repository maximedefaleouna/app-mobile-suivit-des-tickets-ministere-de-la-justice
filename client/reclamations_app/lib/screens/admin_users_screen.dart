import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AdminService _adminService = AdminService();

  List<dynamic> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final users = await _adminService.getAllUsers();
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _changeRole(String userId, String currentRole) async {
    final roles = ['CITOYEN', 'TECHNICIEN', 'ADMIN'];
    final selectedIndex = roles.indexOf(currentRole);

    final selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Changer le rôle'),
        children: roles.map((role) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, role),
            child: Text(role),
          );
        }).toList(),
      ),
    );

    if (selected != null && selected != currentRole) {
      final result = await _adminService.updateUserRole(userId, selected);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['success'] == true
                  ? 'Rôle mis à jour avec succès'
                  : result['message'],
            ),
            backgroundColor: result['success'] == true
                ? Colors.green
                : Colors.red,
          ),
        );

        if (result['success'] == true) {
          _loadUsers();
        }
      }
    }
  }

  Future<void> _toggleUserActive(String userId, bool isActive) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isActive ? 'Désactiver utilisateur' : 'Activer utilisateur',
        ),
        content: Text(
          'Voulez-vous vraiment ${isActive ? 'désactiver' : 'activer'} cet utilisateur ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? Colors.red : Colors.green,
            ),
            child: Text(isActive ? 'Désactiver' : 'Activer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await _adminService.toggleUserActive(userId, !isActive);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['success'] == true
                  ? 'Utilisateur ${!isActive ? 'activé' : 'désactivé'} avec succès'
                  : result['message'],
            ),
            backgroundColor: result['success'] == true
                ? Colors.green
                : Colors.red,
          ),
        );

        if (result['success'] == true) {
          _loadUsers();
        }
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des utilisateurs'),
        backgroundColor: const Color(0xFF006743),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erreur: $_error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadUsers,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            )
          : _users.isEmpty
          ? const Center(child: Text('Aucun utilisateur trouvé'))
          : RefreshIndicator(
              onRefresh: _loadUsers,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: _getRoleColor(
                          user['role'],
                        ).withOpacity(0.2),
                        child: Icon(
                          Icons.person,
                          color: _getRoleColor(user['role']),
                          size: 28,
                        ),
                      ),
                      title: Text(
                        '${user['first_name']} ${user['last_name']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(user['email']),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getRoleColor(
                                    user['role'],
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getRoleColor(user['role']),
                                  ),
                                ),
                                child: Text(
                                  user['role'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _getRoleColor(user['role']),
                                  ),
                                ),
                              ),
                              if (!user['is_active']) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: const Text(
                                    'Inactif',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'role') {
                            _changeRole(user['id'], user['role']);
                          } else if (value == 'toggle') {
                            _toggleUserActive(user['id'], user['is_active']);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'role',
                            child: Row(
                              children: [
                                Icon(Icons.admin_panel_settings),
                                SizedBox(width: 8),
                                Text('Changer le rôle'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'toggle',
                            child: Row(
                              children: [
                                Icon(
                                  user['is_active']
                                      ? Icons.block
                                      : Icons.check_circle,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  user['is_active'] ? 'Désactiver' : 'Activer',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
