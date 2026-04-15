import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../services/admin_service.dart';
import '../../providers/auth_cubit.dart';
import 'admin_users_screen.dart';
import 'admin_tickets_screen.dart';
import 'admin_settings_screen.dart';
import 'statistics_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  final PageController _carouselController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  Map<String, dynamic>? _stats;
  int _totalUsers = 0;
  int _totalTickets = 0;
  bool _loading = true;

  final List<Map<String, String>> _carouselItems = [
    {
      'image':
          'https://togoactualite.com/wp-content/uploads/2022/06/service_digitalise.jpg',
      'title': 'Services Digitalisés',
      'subtitle': 'Accédez aux services publics en ligne',
      'flagPosition': 'topLeft', // Drapeau en haut à gauche
    },
    {
      'image':
          'https://yop.l-frii.com/wp-content/uploads/2024/12/Togo-ces-services-publics-sont-desormais-en-ligne-1024x683.jpg',
      'title': 'Administration Moderne',
      'subtitle': 'Une administration au service des citoyens',
      'flagPosition': 'topLeft', // Drapeau en haut à gauche
    },
    {
      'image':
          'https://media.licdn.com/dms/image/v2/D4D3DAQHHZzwrgXQ1Sw/image-scale_191_1128/B4DZnImraUJEAg-/0/1760007210911/numeriquetg_cover?e=2147483647&v=beta&t=J6HBte8uW6QWt1RbtMQQo3qG3PB61MGXHYyuiZdmRoc',
      'title': 'Togo Numérique',
      'subtitle': 'La transformation digitale du Togo',
      'flagPosition': 'topRight', // Drapeau en haut à droite
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAdminData();
    _startAutoPlay();
  }

  void _startAutoPlay() {
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

  Future<void> _loadAdminData() async {
    setState(() => _loading = true);

    try {
      final stats = await _adminService.getSystemStats();
      final users = await _adminService.getAllUsers();
      final tickets = await _adminService.getAllTickets();

      setState(() {
        _stats = stats;
        _totalUsers = users.length;
        _totalTickets = tickets.length;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
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
            onPressed: _loadAdminData,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF006A4E)),
            onSelected: (value) async {
              if (value == 'logout') {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text('Déconnexion'),
                    content: const Text(
                      'Voulez-vous vraiment vous déconnecter ?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annuler'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Déconnecter'),
                      ),
                    ],
                  ),
                );
                if (shouldLogout == true && mounted) {
                  await context.read<AuthCubit>().logout();
                  context.go('/login');
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Déconnexion', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
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
          : RefreshIndicator(
              onRefresh: _loadAdminData,
              color: const Color(0xFF006A4E),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carrousel avec drapeau
                    SizedBox(
                      height: 200,
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _carouselController,
                            onPageChanged: (index) {
                              setState(() => _currentPage = index);
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
                                      // Image de fond
                                      Image.network(
                                        item['image']!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
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
                                      // Overlay sombre pour le texte
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
                                      // Drapeau togolais en superposition
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
                                      // Texte sur l'image
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
                          // Indicateurs
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
                          Icons.admin_panel_settings,
                          color: Color(0xFF006A4E),
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Bienvenue sur votre tableau de bord',
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
                      'Vous pouvez gérer les tickets, les utilisateurs et configurer le système',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 24),

                    // Statistiques
                    const Text(
                      'Statistiques',
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
                          child: _buildModernStatCard(
                            _totalTickets,
                            'Tickets',
                            Icons.receipt_long_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildModernStatCard(
                            _totalUsers,
                            'Utilisateurs',
                            Icons.people_outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernStatCard(
                            (_stats?['by_status']?['OUVERT'] as int?) ?? 0,
                            'En cours',
                            Icons.pending_actions_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildModernStatCard(
                            (_stats?['by_status']?['RESOLU'] as int?) ?? 0,
                            'Résolus',
                            Icons.check_circle_outline,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Section gestion
                    const Text(
                      'Gestion rapide',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildModernManagementCard(
                      title: 'Utilisateurs',
                      subtitle: 'Gérer les comptes et permissions',
                      icon: Icons.people_alt_outlined,
                      count: _totalUsers,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminUsersScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildModernManagementCard(
                      title: 'Tickets',
                      subtitle: 'Consulter et gérer les réclamations',
                      icon: Icons.receipt_long_outlined,
                      count: _totalTickets,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminTicketsScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildModernManagementCard(
                      title: 'Statistiques',
                      subtitle: 'Analyses et rapports détaillés',
                      icon: Icons.bar_chart_outlined,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StatisticsScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildModernManagementCard(
                      title: 'Paramètres',
                      subtitle: 'Configuration du système',
                      icon: Icons.settings_outlined,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminSettingsScreen(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildModernStatCard(int value, String title, IconData icon) {
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
              color: const Color(0xFF006A4E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF006A4E), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernManagementCard({
    required String title,
    required String subtitle,
    required IconData icon,
    int? count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF006A4E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF006A4E), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      if (count != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF006A4E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF006A4E),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 14),
          ],
        ),
      ),
    );
  }
}
