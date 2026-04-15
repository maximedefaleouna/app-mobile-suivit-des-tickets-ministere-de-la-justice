import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

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
  String _searchQuery = '';
  String _filterRole = 'all';

  final List<Map<String, dynamic>> _roles = [
    {'value': 'all', 'label': 'Tous'},
    {'value': 'CITOYEN', 'label': 'Citoyens'},
    {'value': 'TECHNICIEN', 'label': 'Techniciens'},
    {'value': 'ADMIN', 'label': 'Admins'},
  ];

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

  List<dynamic> get _filteredUsers {
    return _users.where((user) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          (user['first_name'] ?? '').toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          (user['last_name'] ?? '').toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          (user['email'] ?? '').toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      final matchesRole = _filterRole == 'all' || user['role'] == _filterRole;

      return matchesSearch && matchesRole;
    }).toList();
  }

  Future<void> _changeRole(int userId, String currentRole) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Changer le rôle',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.person_outline,
                color: Color(0xFF006A4E),
              ),
              title: const Text('Citoyen'),
              trailing: currentRole == 'CITOYEN'
                  ? const Icon(Icons.check, color: Color(0xFF006A4E))
                  : null,
              onTap: () => Navigator.pop(context, 'CITOYEN'),
            ),
            ListTile(
              leading: const Icon(Icons.build_outlined, color: Colors.orange),
              title: const Text('Technicien'),
              trailing: currentRole == 'TECHNICIEN'
                  ? const Icon(Icons.check, color: Color(0xFF006A4E))
                  : null,
              onTap: () => Navigator.pop(context, 'TECHNICIEN'),
            ),
            ListTile(
              leading: const Icon(
                Icons.admin_panel_settings,
                color: Colors.red,
              ),
              title: const Text('Administrateur'),
              trailing: currentRole == 'ADMIN'
                  ? const Icon(Icons.check, color: Color(0xFF006A4E))
                  : null,
              onTap: () => Navigator.pop(context, 'ADMIN'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (selected != null && selected != currentRole) {
      final result = await _adminService.updateUserRole(
        userId.toString(),
        selected,
      );
      if (mounted) {
        _showSnackBar(
          result['success'] == true ? 'Rôle mis à jour' : result['message'],
          result['success'] == true,
        );
        if (result['success'] == true) _loadUsers();
      }
    }
  }

  Future<void> _toggleUserActive(int userId, bool isActive) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isActive ? 'Désactiver' : 'Activer'),
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
              foregroundColor: Colors.white,
            ),
            child: Text(isActive ? 'Désactiver' : 'Activer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await _adminService.toggleUserActive(
        userId.toString(),
        !isActive,
      );
      if (mounted) {
        _showSnackBar(
          result['success'] == true
              ? 'Utilisateur ${!isActive ? 'activé' : 'désactivé'}'
              : result['message'],
          result['success'] == true,
        );
        if (result['success'] == true) _loadUsers();
      }
    }
  }

  Future<void> _deleteUser(int userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer'),
        content: const Text(
          'Cette action est irréversible. Confirmer la suppression ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await _adminService.deleteUser(userId.toString());
    if (mounted) {
      _showSnackBar(
        success ? 'Utilisateur supprimé' : 'Erreur lors de la suppression',
        success,
      );
      if (success) _loadUsers();
    }
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green[600] : Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getInitials(dynamic user) {
    String first = user['first_name'] ?? '';
    String last = user['last_name'] ?? '';

    if (first.isEmpty && last.isEmpty) return '?';
    if (first.isEmpty) return last.substring(0, 1).toUpperCase();
    if (last.isEmpty) return first.substring(0, 1).toUpperCase();

    return '${first[0]}${last[0]}'.toUpperCase();
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'ADMIN':
        return Colors.red.shade600;
      case 'TECHNICIEN':
        return Colors.orange.shade600;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Utilisateurs',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false, // Important : désactive le centrage du titre
        automaticallyImplyLeading:
            false, // Enlève le bouton retour si nécessaire
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.grey))
          : _error != null
          ? _buildErrorView()
          : Column(
              children: [
                // Barre de recherche
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  color: Colors.white,
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un utilisateur...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[500],
                        size: 20,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                // Filtres
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  color: Colors.white,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _roles.map((role) {
                        final isSelected = _filterRole == role['value'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(role['label']),
                            selected: isSelected,
                            onSelected: (_) =>
                                setState(() => _filterRole = role['value']),
                            backgroundColor: Colors.grey[100],
                            selectedColor: Colors.grey[200],
                            checkmarkColor: Colors.grey[700],
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.black87
                                  : Colors.grey[600],
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.grey[400]!
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredUsers.isEmpty
                      ? _buildEmptyView()
                      : RefreshIndicator(
                          onRefresh: _loadUsers,
                          color: Colors.grey,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              return _buildUserCard(user);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildUserCard(dynamic user) {
    final isActive = user['is_active'] ?? false;
    final role = user['role'] ?? 'CITOYEN';
    final roleColor = _getRoleColor(role);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(user),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: roleColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'
                                .trim(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          if (!isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Inactif',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user['email'] ?? 'Pas d\'email',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: roleColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz, color: Colors.grey[500]),
                  onSelected: (value) {
                    if (value == 'role') _changeRole(user['id'], role);
                    if (value == 'toggle')
                      _toggleUserActive(user['id'], isActive);
                    if (value == 'delete') _deleteUser(user['id']);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'role',
                      child: Text('Changer le rôle'),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Text(isActive ? 'Désactiver' : 'Activer'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Supprimer',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Une erreur est survenue',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUsers,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('Aucun utilisateur', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}
