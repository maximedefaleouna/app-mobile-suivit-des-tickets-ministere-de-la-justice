import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/ticket_service.dart';
import '../../models/ticket.dart';
import 'ticket_list_screen.dart';
import 'ticket_detail_screen.dart';
import '../admin/statistics_screen.dart';
import 'profile_screen.dart';
import 'create_ticket_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TicketService _service = TicketService();
  final PageController _carouselController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  Map<String, int> _quickStats = {};
  List<Ticket> _recentTickets = [];
  bool _loading = true;
  String? _error;

  final List<Map<String, String>> _carouselItems = [
    {
      'image':
          'https://togoactualite.com/wp-content/uploads/2022/06/service_digitalise.jpg',
      'title': 'Services Digitalisés',
      'subtitle': 'Accédez aux services publics en ligne',
      'flagPosition': 'topLeft',
    },
    {
      'image':
          'https://yop.l-frii.com/wp-content/uploads/2024/12/Togo-ces-services-publics-sont-desormais-en-ligne-1024x683.jpg',
      'title': 'Administration Moderne',
      'subtitle': 'Une administration au service des citoyens',
      'flagPosition': 'topLeft',
    },
    {
      'image':
          'https://media.licdn.com/dms/image/v2/D4D3DAQHHZzwrgXQ1Sw/image-scale_191_1128/B4DZnImraUJEAg-/0/1760007210911/numeriquetg_cover?e=2147483647&v=beta&t=J6HBte8uW6QWt1RbtMQQo3qG3PB61MGXHYyuiZdmRoc',
      'title': 'Togo Numérique',
      'subtitle': 'La transformation digitale du Togo',
      'flagPosition': 'topRight',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _carouselController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= _carouselItems.length) nextPage = 0;
        _carouselController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _service.getDashboardData();
      final quickStatsRaw = data['quick_stats'] as Map<String, dynamic>? ?? {};

      setState(() {
        _quickStats = quickStatsRaw.map(
          (key, value) => MapEntry(key, value as int),
        );
        _recentTickets = (data['recent_tickets'] as List)
            .map((j) => Ticket.fromJson(j))
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _carouselController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Tableau de bord',
          style: TextStyle(
            color: Color(0xFF006A4E),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF006A4E)),
            onPressed: _loadDashboard,
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Color(0xFF006A4E)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Color(0xFF006A4E),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chargement...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : _error != null
          ? _buildErrorView()
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              color: const Color(0xFF006A4E),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carrousel
                    SizedBox(
                      height: 200,
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _carouselController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                              _startAutoPlay();
                            },
                            itemCount: _carouselItems.length,
                            itemBuilder: (context, index) {
                              final item = _carouselItems[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        item['image']!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      Color(0xFF006A4E),
                                                      Color(0xFFFCD116),
                                                      Color(0xFFCE1126),
                                                    ],
                                                  ),
                                                ),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.photo,
                                                    size: 50,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              );
                                            },
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.7),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 12,
                                        left: item['flagPosition'] == 'topLeft'
                                            ? 12
                                            : null,
                                        right:
                                            item['flagPosition'] == 'topRight'
                                            ? 12
                                            : null,
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.2,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: ClipOval(
                                            child: Image.network(
                                              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS11eGraM2jGuglZxjaWy_nLortYrUQKcL3jw&s',
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                                  colors: [
                                                                    Color(
                                                                      0xFF006A4E,
                                                                    ),
                                                                    Color(
                                                                      0xFFFCD116,
                                                                    ),
                                                                    Color(
                                                                      0xFFCE1126,
                                                                    ),
                                                                  ],
                                                                ),
                                                          ),
                                                      child: const Icon(
                                                        Icons.flag,
                                                        color: Colors.white,
                                                        size: 24,
                                                      ),
                                                    );
                                                  },
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 16,
                                        left: 16,
                                        right: 16,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['title']!,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item['subtitle']!,
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.9,
                                                ),
                                                fontSize: 12,
                                              ),
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
                          Positioned(
                            bottom: 12,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _carouselItems.length,
                                (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  width: _currentPage == index ? 20 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: _currentPage == index
                                        ? const Color(0xFF006A4E)
                                        : Colors.white.withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Message de bienvenue
                    const Row(
                      children: [
                        Icon(
                          Icons.dashboard_outlined,
                          color: Color(0xFF006A4E),
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Bienvenue sur votre espace citoyen',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Suivez vos réclamations et créez de nouveaux tickets',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 24),

                    // Statistiques
                    const Text(
                      'Vue d\'ensemble',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Ouverts',
                            _quickStats['open'] ?? 0,
                            Icons.folder_open_outlined,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'En cours',
                            _quickStats['in_progress'] ?? 0,
                            Icons.pending_actions_outlined,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Résolus',
                            _quickStats['resolved'] ?? 0,
                            Icons.check_circle_outline,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Critiques',
                            _quickStats['critical'] ?? 0,
                            Icons.warning_amber_outlined,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Tickets récents
                    const Text(
                      'Tickets récents',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_recentTickets.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'Aucun ticket récent',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ),
                      )
                    else
                      ..._recentTickets
                          .take(5)
                          .map((ticket) => _buildTicketCard(ticket)),

                    const SizedBox(height: 16),

                    // Boutons
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TicketListScreen(),
                          ),
                        ).then((_) => _loadDashboard()),
                        icon: const Icon(Icons.list_alt),
                        label: const Text('Voir tous mes tickets'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFF006A4E)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StatisticsScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.bar_chart),
                        label: const Text('Voir les statistiques'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFF006A4E)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateTicketScreen()),
        ).then((_) => _loadDashboard()),
        backgroundColor: const Color(0xFF006A4E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(Ticket ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TicketDetailScreen(ticketId: ticket.id),
            ),
          ).then((_) => _loadDashboard()),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getColorStatut(ticket.statut),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.titre,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '#${ticket.id}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            ticket.statut,
                            style: TextStyle(
                              fontSize: 11,
                              color: _getColorStatut(ticket.statut),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
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
            onPressed: _loadDashboard,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006A4E),
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

  Color _getColorStatut(String statut) {
    switch (statut) {
      case 'OUVERT':
        return Colors.blue;
      case 'EN_COURS':
        return Colors.orange;
      case 'RESOLU':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
