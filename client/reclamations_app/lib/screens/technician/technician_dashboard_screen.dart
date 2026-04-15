// import 'package:flutter/material.dart';
// import '../../models/ticket.dart';
// import '../../services/auth_service.dart';
// import '../../services/ticket_service.dart';
// import '../../widgets/ticket_card.dart';
// import '../citizen/profile_screen.dart';
// import '../citizen/ticket_detail_screen.dart';

// class TechnicianDashboardScreen extends StatefulWidget {
//   const TechnicianDashboardScreen({super.key});

//   @override
//   State<TechnicianDashboardScreen> createState() =>
//       _TechnicianDashboardScreenState();
// }

// class _TechnicianDashboardScreenState extends State<TechnicianDashboardScreen> {
//   final _authService = AuthService();
//   final _ticketService = TicketService();

//   int _selectedIndex = 0;
//   String? _userName;
//   bool _loading = true;

//   List<Ticket> _allTickets = [];
//   List<Ticket> _myTickets = [];
//   List<Ticket> _unassignedTickets = [];

//   Map<String, int> _stats = {};

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     setState(() => _loading = true);

//     try {
//       _userName = await _authService.getUserName();
//       final allTickets = await _ticketService.listerTickets();

//       setState(() {
//         _allTickets = allTickets;
//         _myTickets = allTickets.where((t) => t.assigneA != null).toList();
//         _unassignedTickets = allTickets
//             .where((t) => t.assigneA == null)
//             .toList();

//         _stats = {
//           'total': _allTickets.length,
//           'open': _allTickets.where((t) => t.statut == 'OUVERT').length,
//           'in_progress': _allTickets
//               .where((t) => t.statut == 'EN_COURS')
//               .length,
//           'resolved': _allTickets.where((t) => t.statut == 'RESOLU').length,
//         };
//       });
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Erreur: $e'),
//             backgroundColor: Colors.red[600],
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//       }
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   Widget _buildStatCard(String title, int value, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: color, size: 18),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   value.toString(),
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: color,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   title,
//                   style: TextStyle(fontSize: 11, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTicketSection(
//     String title,
//     List<Ticket> tickets, {
//     Color? headerColor,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           child: Row(
//             children: [
//               Icon(
//                 Icons.folder_outlined,
//                 color: headerColor ?? Colors.grey[700],
//                 size: 18,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                   color: headerColor ?? Colors.black87,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: (headerColor ?? Colors.grey[700])!.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   '${tickets.length}',
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                     color: headerColor ?? Colors.grey[700],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         tickets.isEmpty
//             ? Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 16),
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Center(
//                   child: Text(
//                     'Aucun ticket',
//                     style: TextStyle(color: Colors.grey[500], fontSize: 13),
//                   ),
//                 ),
//               )
//             : SizedBox(
//                 height: 100,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   padding: const EdgeInsets.symmetric(horizontal: 12),
//                   itemCount: tickets.length,
//                   itemBuilder: (context, index) {
//                     final ticket = tickets[index];
//                     return Container(
//                       width: 280,
//                       margin: const EdgeInsets.symmetric(horizontal: 4),
//                       child: TicketCard(
//                         ticket: ticket,
//                         onTap: () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) =>
//                                 TicketDetailScreen(ticketId: ticket.id),
//                           ),
//                         ).then((_) => _loadData()),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//       ],
//     );
//   }

//   Widget _buildDashboard() {
//     return RefreshIndicator(
//       onRefresh: _loadData,
//       color: Colors.grey,
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.only(bottom: 20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: const BorderRadius.only(
//                   bottomLeft: Radius.circular(20),
//                   bottomRight: Radius.circular(20),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.03),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF006A4E).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: const Icon(
//                       Icons.build_outlined,
//                       color: Color(0xFF006A4E),
//                       size: 24,
//                     ),
//                   ),
//                   const SizedBox(width: 14),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Bonjour ${_userName ?? "Technicien"}',
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         Text(
//                           'Tableau de bord technique',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[500],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Stats
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: GridView.count(
//                 crossAxisCount: 2,
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 mainAxisSpacing: 12,
//                 crossAxisSpacing: 12,
//                 childAspectRatio: 2.2,
//                 children: [
//                   _buildStatCard(
//                     'Total',
//                     _stats['total'] ?? 0,
//                     Icons.folder_outlined,
//                     Colors.blue,
//                   ),
//                   _buildStatCard(
//                     'Ouverts',
//                     _stats['open'] ?? 0,
//                     Icons.error_outline,
//                     Colors.orange,
//                   ),
//                   _buildStatCard(
//                     'En cours',
//                     _stats['in_progress'] ?? 0,
//                     Icons.pending_actions,
//                     Colors.purple,
//                   ),
//                   _buildStatCard(
//                     'Résolus',
//                     _stats['resolved'] ?? 0,
//                     Icons.check_circle_outline,
//                     Colors.green,
//                   ),
//                 ],
//               ),
//             ),

//             // Sections
//             _buildTicketSection(
//               'À prendre en charge',
//               _unassignedTickets,
//               headerColor: Colors.orange,
//             ),
//             const SizedBox(height: 8),
//             _buildTicketSection(
//               'Tous les tickets',
//               _allTickets,
//               headerColor: Colors.blue,
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMyTickets() {
//     return RefreshIndicator(
//       onRefresh: _loadData,
//       color: Colors.grey,
//       child: _myTickets.isEmpty
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[300]),
//                   const SizedBox(height: 12),
//                   Text(
//                     'Aucun ticket assigné',
//                     style: TextStyle(fontSize: 14, color: Colors.grey[500]),
//                   ),
//                 ],
//               ),
//             )
//           : ListView.builder(
//               padding: const EdgeInsets.all(12),
//               itemCount: _myTickets.length,
//               itemBuilder: (context, index) {
//                 final ticket = _myTickets[index];
//                 return _buildTicketItem(ticket);
//               },
//             ),
//     );
//   }

//   Widget _buildTicketItem(Ticket ticket) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 4,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => TicketDetailScreen(ticketId: ticket.id),
//             ),
//           ).then((_) => _loadData()),
//           borderRadius: BorderRadius.circular(12),
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               children: [
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: _getPriorityColor(ticket.priorite).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(
//                     _getTypeIcon(ticket.typeTicket),
//                     color: _getPriorityColor(ticket.priorite),
//                     size: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         ticket.titre,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 6,
//                               vertical: 2,
//                             ),
//                             decoration: BoxDecoration(
//                               color: _getStatusColor(
//                                 ticket.statut,
//                               ).withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Text(
//                               ticket.statut,
//                               style: TextStyle(
//                                 fontSize: 9,
//                                 fontWeight: FontWeight.w500,
//                                 color: _getStatusColor(ticket.statut),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 6),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 6,
//                               vertical: 2,
//                             ),
//                             decoration: BoxDecoration(
//                               color: _getPriorityColor(
//                                 ticket.priorite,
//                               ).withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Text(
//                               ticket.priorite,
//                               style: TextStyle(
//                                 fontSize: 9,
//                                 fontWeight: FontWeight.w500,
//                                 color: _getPriorityColor(ticket.priorite),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 Icon(Icons.chevron_right, color: Colors.grey[400], size: 18),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfile() {
//     return const ProfileScreen();
//   }

//   Color _getPriorityColor(String? priority) {
//     switch (priority) {
//       case 'CRITIQUE':
//         return Colors.red;
//       case 'HAUTE':
//         return Colors.orange;
//       case 'NORMALE':
//         return Colors.blue;
//       case 'BASSE':
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }

//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'OUVERT':
//         return Colors.blue;
//       case 'EN_COURS':
//         return Colors.orange;
//       case 'RESOLU':
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }

//   IconData _getTypeIcon(String? type) {
//     switch (type) {
//       case 'INCIDENT':
//         return Icons.bug_report_outlined;
//       case 'RECLAMATION':
//         return Icons.feedback_outlined;
//       case 'DEMANDE':
//         return Icons.help_outline;
//       default:
//         return Icons.receipt_long_outlined;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return Scaffold(
//         backgroundColor: const Color(0xFFF5F5F5),
//         body: const Center(
//           child: SizedBox(
//             width: 24,
//             height: 24,
//             child: CircularProgressIndicator(
//               strokeWidth: 2,
//               color: Color(0xFF006A4E),
//             ),
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       appBar: AppBar(
//         title: Text(
//           _selectedIndex == 0
//               ? 'Tableau de bord'
//               : (_selectedIndex == 1 ? 'Mes tickets' : 'Profil'),
//           style: const TextStyle(
//             color: Color(0xFF1A1A1A),
//             fontSize: 18,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: false,
//         leading: _selectedIndex != 0
//             ? IconButton(
//                 icon: const Icon(Icons.arrow_back_ios, size: 18),
//                 onPressed: () {
//                   setState(() {
//                     _selectedIndex = 0;
//                   });
//                 },
//                 color: const Color(0xFF006A4E),
//               )
//             : null,
//       ),
//       body: _selectedIndex == 0
//           ? _buildDashboard()
//           : _selectedIndex == 1
//           ? _buildMyTickets()
//           : _buildProfile(),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: (index) => setState(() => _selectedIndex = index),
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: Colors.white,
//         selectedItemColor: const Color(0xFF006A4E),
//         unselectedItemColor: Colors.grey,
//         elevation: 0,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.dashboard_outlined, size: 22),
//             activeIcon: Icon(Icons.dashboard, size: 22),
//             label: 'Accueil',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.assignment_outlined, size: 22),
//             activeIcon: Icon(Icons.assignment, size: 22),
//             label: 'Mes tickets',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline, size: 22),
//             activeIcon: Icon(Icons.person, size: 22),
//             label: 'Profil',
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../models/ticket.dart';
import '../../services/auth_service.dart';
import '../../services/ticket_service.dart';
import '../../widgets/ticket_card.dart';
import '../citizen/profile_screen.dart';
import '../citizen/ticket_detail_screen.dart';

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

  List<Ticket> _allTickets = [];
  List<Ticket> _myTickets = [];
  List<Ticket> _unassignedTickets = [];

  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      _userName = await _authService.getUserName();
      final allTickets = await _ticketService.listerTickets();

      setState(() {
        _allTickets = allTickets;
        _myTickets = allTickets.where((t) => t.assigneA != null).toList();
        _unassignedTickets = allTickets
            .where((t) => t.assigneA == null)
            .toList();

        _stats = {
          'total': _allTickets.length,
          'open': _allTickets.where((t) => t.statut == 'OUVERT').length,
          'in_progress': _allTickets
              .where((t) => t.statut == 'EN_COURS')
              .length,
          'resolved': _allTickets.where((t) => t.statut == 'RESOLU').length,
        };
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
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
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketSection(
    String title,
    List<Ticket> tickets, {
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
                color: headerColor ?? Colors.grey[700],
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: headerColor ?? Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (headerColor ?? Colors.grey[700])!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${tickets.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: headerColor ?? Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
        tickets.isEmpty
            ? Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Aucun ticket',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                ),
              )
            : SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return Container(
                      width: 280,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: TicketCard(
                        ticket: ticket,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TicketDetailScreen(ticketId: ticket.id),
                          ),
                        ).then((_) => _loadData()),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: Colors.grey,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
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
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.build_outlined,
                      color: Color(0xFF006A4E),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour ${_userName ?? "Technicien"}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Tableau de bord technique',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
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
                childAspectRatio: 2.2,
                children: [
                  _buildStatCard(
                    'Total',
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
              'À prendre en charge',
              _unassignedTickets,
              headerColor: Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildTicketSection(
              'Tous les tickets',
              _allTickets,
              headerColor: Colors.blue,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMyTickets() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: Colors.grey,
      child: _myTickets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    'Aucun ticket assigné',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _myTickets.length,
              itemBuilder: (context, index) {
                final ticket = _myTickets[index];
                return _buildTicketItem(ticket);
              },
            ),
    );
  }

  Widget _buildTicketItem(Ticket ticket) {
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
          ).then((_) => _loadData()),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(ticket.priorite).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getTypeIcon(ticket.typeTicket),
                    color: _getPriorityColor(ticket.priorite),
                    size: 20,
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
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                ticket.statut,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              ticket.statut,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: _getStatusColor(ticket.statut),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(
                                ticket.priorite,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              ticket.priorite,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: _getPriorityColor(ticket.priorite),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfile() {
    return ProfileScreen(
      onBackPressed: () {
        setState(() {
          _selectedIndex = 0;
        });
      },
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case 'CRITIQUE':
        return Colors.red;
      case 'HAUTE':
        return Colors.orange;
      case 'NORMALE':
        return Colors.blue;
      case 'BASSE':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
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

  IconData _getTypeIcon(String? type) {
    switch (type) {
      case 'INCIDENT':
        return Icons.bug_report_outlined;
      case 'RECLAMATION':
        return Icons.feedback_outlined;
      case 'DEMANDE':
        return Icons.help_outline;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF006A4E),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: _selectedIndex == 2
            ? null // ✅ Pas de titre sur Profil
            : Text(
                _selectedIndex == 0 ? 'Tableau de bord' : 'Mes tickets',
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: _selectedIndex == 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 18),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
                color: const Color(0xFF006A4E),
              )
            : null,
      ),
      body: _selectedIndex == 0
          ? _buildDashboard()
          : _selectedIndex == 1
          ? _buildMyTickets()
          : _buildProfile(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF006A4E),
        unselectedItemColor: Colors.grey,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined, size: 22),
            activeIcon: Icon(Icons.dashboard, size: 22),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined, size: 22),
            activeIcon: Icon(Icons.assignment, size: 22),
            label: 'Mes tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 22),
            activeIcon: Icon(Icons.person, size: 22),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
