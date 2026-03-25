import 'package:flutter/material.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../services/ticket_service.dart';
import '../widgets/ticket_card.dart';
import 'ticket_detail_screen.dart';
import 'profile_screen.dart';

class TechnicianDashboardScreen extends StatefulWidget {
  const TechnicianDashboardScreen({super.key});

  @override
  State<TechnicianDashboardScreen> createState() =>
      _TechnicianDashboardScreenState();
}

class _TechnicianDashboardScreenState extends State<TechnicianDashboardScreen> {
  final _authService = AuthService();
  final _ticketService = TicketService();

  int _selectedIndex = 0;
  String? _userName;
  bool _loading = true;

  List<dynamic> _allTickets = [];
  List<dynamic> _myTickets = [];
  List<dynamic> _unassignedTickets = [];

  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      // Get user info
      _userName = await _authService.getUserName();

      // Load tickets
      final allTicketsData = await _ticketService.listerTickets();
      final allTickets = allTicketsData.map((t) => t.toJson()).toList();

      setState(() {
        _allTickets = allTickets;
        _myTickets = allTickets.where((t) => t['assigned_to'] != null).toList();
        _unassignedTickets = allTickets
            .where((t) => t['assigned_to'] == null)
            .toList();

        // Calculate stats
        _stats = {
          'total': _allTickets.length,
          'open': _allTickets.where((t) => t['status'] == 'OUVERT').length,
          'in_progress': _allTickets
              .where((t) => t['status'] == 'EN_COURS')
              .length,
          'resolved': _allTickets.where((t) => t['status'] == 'RESOLU').length,
        };
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketSection(
    String title,
    List<dynamic> tickets, {
    Color? headerColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.folder_outlined,
                color: headerColor ?? const Color(0xFF006743),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: headerColor ?? const Color(0xFF006743),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      headerColor?.withOpacity(0.1) ??
                      const Color(0xFF006743).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${tickets.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: headerColor ?? const Color(0xFF006743),
                  ),
                ),
              ),
            ],
          ),
        ),
        tickets.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Aucun ticket dans cette section',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            : SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return Container(
                      width: 300,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: TicketCard(
                        ticket: ticket,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TicketDetailScreen(ticketId: ticket['id']),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        // Dashboard
        return RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF006743), Color(0xFF004d33)],
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Cellule Informatique',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bonjour ${_userName ?? "Technicien"}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[200]),
                      ),
                    ],
                  ),
                ),

                // Stats
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard(
                        'Total Tickets',
                        _stats['total'] ?? 0,
                        Icons.folder_outlined,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Ouverts',
                        _stats['open'] ?? 0,
                        Icons.error_outline,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'En cours',
                        _stats['in_progress'] ?? 0,
                        Icons.pending_actions,
                        Colors.purple,
                      ),
                      _buildStatCard(
                        'Résolus',
                        _stats['resolved'] ?? 0,
                        Icons.check_circle_outline,
                        Colors.green,
                      ),
                    ],
                  ),
                ),

                // Sections
                _buildTicketSection(
                  'Non Assignés',
                  _unassignedTickets,
                  headerColor: Colors.orange,
                ),
                const Divider(),
                _buildTicketSection(
                  'Tous les Tickets',
                  _allTickets,
                  headerColor: Colors.blue,
                ),
              ],
            ),
          ),
        );

      case 1:
        // My Tickets
        return RefreshIndicator(
          onRefresh: _loadData,
          child: _myTickets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun ticket assigné',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _myTickets.length,
                  itemBuilder: (context, index) {
                    final ticket = _myTickets[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getPriorityColor(
                            ticket['priority'],
                          ),
                          child: Icon(
                            _getTypeIcon(ticket['type']),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          ticket['title'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Statut: ${ticket['status']}'),
                          ],
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TicketDetailScreen(ticketId: ticket['id']),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );

      case 2:
        // Profile
        return const ProfileScreen();

      default:
        return const SizedBox();
    }
  }

  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case 'CRITIQUE':
        return Colors.red;
      case 'ELEVEE':
        return Colors.orange;
      case 'MOYENNE':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String? type) {
    switch (type) {
      case 'INCIDENT':
        return Icons.bug_report;
      case 'RECLAMATION':
        return Icons.feedback;
      case 'DEMANDE':
        return Icons.help_outline;
      default:
        return Icons.confirmation_number_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF006743),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Mes Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
