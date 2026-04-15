import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/ticket_service.dart';
import 'create_ticket_screen.dart';
import 'profile_screen.dart';
import 'ticket_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _ticketService = TicketService();

  int _selectedIndex = 0;
  String? _userName;
  List<dynamic> _tickets = [];
  bool _loading = true;
  String _filterStatut = 'TOUS';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      _userName = await _authService.getUserName();
      final ticketsData = await _ticketService.listerTickets();
      setState(() {
        _tickets = ticketsData.map((t) => t.toJson()).toList();
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

  List<dynamic> get _filteredTickets {
    if (_filterStatut == 'TOUS') return _tickets;
    return _tickets.where((t) => t['statut'] == _filterStatut).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes tickets'),
        backgroundColor: const Color(0xFF006743),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildTicketsTab(),
          const CreateTicketScreen(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF006743),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Creer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateTicketScreen()),
                ).then((_) => _loadData());
              },
              backgroundColor: const Color(0xFF006743),
              icon: const Icon(Icons.add),
              label: const Text('Nouveau'),
            )
          : null,
    );
  }

  Widget _buildTicketsTab() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF006743), Color(0xFF004d33)],
            ),
          ),
          child: Column(
            children: [
              const Icon(Icons.account_balance, color: Colors.white, size: 48),
              const SizedBox(height: 8),
              Text(
                'Bonjour ${_userName ?? "Utilisateur"}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ministere de la Justice',
                style: TextStyle(fontSize: 14, color: Colors.grey[200]),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              _buildFilterChip('TOUS'),
              _buildFilterChip('OUVERT'),
              _buildFilterChip('EN_COURS'),
              _buildFilterChip('RESOLU'),
              _buildFilterChip('CLOS'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatBadge('Total', _tickets.length, Colors.blue),
              _buildStatBadge(
                'Ouverts',
                _tickets.where((t) => t['statut'] == 'OUVERT').length,
                Colors.orange,
              ),
              _buildStatBadge(
                'En cours',
                _tickets.where((t) => t['statut'] == 'EN_COURS').length,
                Colors.purple,
              ),
              _buildStatBadge(
                'Resolus',
                _tickets.where((t) => t['statut'] == 'RESOLU').length,
                Colors.green,
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _filteredTickets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun ticket',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateTicketScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Creer un ticket'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006743),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredTickets.length,
                    itemBuilder: (context, index) {
                      final ticket = _filteredTickets[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getPriorityColor(
                              ticket['priorite'] as String?,
                            ),
                            child: Icon(
                              _getTypeIcon(ticket['type_ticket'] as String?),
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            ticket['titre'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '#${ticket['id']} - ${ticket['date_creation']}',
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  _buildStatusBadge(ticket['statut']),
                                  const SizedBox(width: 8),
                                  if (ticket['assigne_a'] != null)
                                    Icon(
                                      Icons.assignment_ind,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TicketDetailScreen(ticketId: ticket['id']),
                              ),
                            ).then((_) => _loadData());
                          },
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String statut) {
    final isSelected = _filterStatut == statut;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(statut),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filterStatut = selected ? statut : 'TOUS';
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: const Color(0xFF006743).withOpacity(0.3),
        checkmarkColor: const Color(0xFF006743),
      ),
    );
  }

  Widget _buildStatBadge(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String statut) {
    Color color;
    switch (statut) {
      case 'OUVERT':
        color = Colors.blue;
        break;
      case 'EN_COURS':
        color = Colors.orange;
        break;
      case 'RESOLU':
        color = Colors.green;
        break;
      case 'CLOS':
        color = Colors.grey;
        break;
      default:
        color = Colors.black;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statut,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getPriorityColor(String? priorite) {
    switch (priorite) {
      case 'CRITIQUE':
        return Colors.red;
      case 'HAUTE':
      case 'ELEVEE':
        return Colors.orange;
      case 'NORMALE':
      case 'MOYENNE':
        return Colors.blue;
      case 'BASSE':
      case 'FAIBLE':
        return Colors.green;
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

  Widget _buildProfileTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle, size: 80, color: Color(0xFF006743)),
          const SizedBox(height: 24),
          Text(
            _userName ?? 'Utilisateur',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            icon: const Icon(Icons.settings),
            label: const Text('Gerer mon profil'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006743),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
