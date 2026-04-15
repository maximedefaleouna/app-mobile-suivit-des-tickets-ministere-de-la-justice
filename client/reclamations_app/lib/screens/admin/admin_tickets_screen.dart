// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../models/ticket.dart';
// import '../../services/admin_service.dart';
// import '../../services/ticket_service.dart';
// import '../citizen/ticket_detail_screen.dart';

// class AdminTicketsScreen extends StatefulWidget {
//   const AdminTicketsScreen({super.key});

//   @override
//   State<AdminTicketsScreen> createState() => _AdminTicketsScreenState();
// }

// class _AdminTicketsScreenState extends State<AdminTicketsScreen> {
//   final AdminService _adminService = AdminService();
//   final TicketService _ticketService = TicketService();

//   List<Ticket> _tickets = [];
//   List<Map<String, dynamic>> _technicians = [];
//   bool _loading = true;
//   String? _filterStatus;

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     setState(() {
//       _loading = true;
//     });

//     try {
//       final ticketData = await _adminService.getAllTickets();
//       final userData = await _adminService.getAllUsers();

//       setState(() {
//         _tickets = ticketData
//             .map((j) => Ticket.fromJson(j as Map<String, dynamic>))
//             .toList();
//         _technicians = userData
//             .where(
//               (user) =>
//                   user['role'] == 'TECHNICIEN' && (user['is_active'] == true),
//             )
//             .map((user) => Map<String, dynamic>.from(user))
//             .toList();
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _loading = false;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
//       }
//     }
//   }

//   List<Ticket> get _filteredTickets {
//     if (_filterStatus == null) {
//       return _tickets;
//     }
//     return _tickets.where((ticket) => ticket.statut == _filterStatus).toList();
//   }

//   Future<void> _changeStatus(Ticket ticket) async {
//     final selected = await showDialog<String>(
//       context: context,
//       builder: (context) => SimpleDialog(
//         title: const Text('Changer le statut'),
//         children: ['OUVERT', 'EN_COURS', 'RESOLU', 'CLOS']
//             .map(
//               (status) => SimpleDialogOption(
//                 onPressed: () => Navigator.pop(context, status),
//                 child: Text(status),
//               ),
//             )
//             .toList(),
//       ),
//     );

//     if (selected == null || selected == ticket.statut) {
//       return;
//     }

//     try {
//       await _ticketService.changerStatut(ticket.id, selected);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Statut mis a jour avec succes')),
//         );
//       }
//       await _loadData();
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
//       }
//     }
//   }

//   Future<void> _assignTicket(Ticket ticket) async {
//     if (_technicians.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Aucun technicien actif disponible')),
//       );
//       return;
//     }

//     final selected = await showDialog<Map<String, dynamic>>(
//       context: context,
//       builder: (context) => SimpleDialog(
//         title: const Text('Attribuer le ticket'),
//         children: _technicians
//             .map(
//               (tech) => SimpleDialogOption(
//                 onPressed: () => Navigator.pop(context, tech),
//                 child: Text(
//                   '${tech['first_name']} ${tech['last_name']} - ${tech['email']}',
//                 ),
//               ),
//             )
//             .toList(),
//       ),
//     );

//     if (selected == null) {
//       return;
//     }

//     try {
//       await _ticketService.assignerTicket(ticket.id, selected['id'] as int);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Ticket attribue avec succes')),
//         );
//       }
//       await _loadData();
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
//       }
//     }
//   }

//   Color _getColorStatut(String statut) {
//     switch (statut) {
//       case 'OUVERT':
//         return Colors.blue;
//       case 'EN_COURS':
//         return Colors.orange;
//       case 'RESOLU':
//         return Colors.green;
//       case 'CLOS':
//         return Colors.grey;
//       default:
//         return Colors.black;
//     }
//   }

//   Color _getColorPriorite(String priorite) {
//     switch (priorite) {
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Gestion des tickets'),
//         backgroundColor: const Color(0xFF006743),
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadData,
//           ),
//         ],
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Row(
//                       children: [
//                         FilterChip(
//                           label: const Text('Tous'),
//                           selected: _filterStatus == null,
//                           onSelected: (_) {
//                             setState(() {
//                               _filterStatus = null;
//                             });
//                           },
//                         ),
//                         const SizedBox(width: 8),
//                         ...['OUVERT', 'EN_COURS', 'RESOLU', 'CLOS'].map(
//                           (status) => Padding(
//                             padding: const EdgeInsets.only(right: 8),
//                             child: FilterChip(
//                               label: Text(status),
//                               selected: _filterStatus == status,
//                               onSelected: (selected) {
//                                 setState(() {
//                                   _filterStatus = selected ? status : null;
//                                 });
//                               },
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: RefreshIndicator(
//                     onRefresh: _loadData,
//                     child: ListView.builder(
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       itemCount: _filteredTickets.length,
//                       itemBuilder: (context, index) {
//                         final ticket = _filteredTickets[index];
//                         return Card(
//                           margin: const EdgeInsets.only(bottom: 10),
//                           child: ListTile(
//                             contentPadding: const EdgeInsets.all(12),
//                             title: Text(
//                               ticket.titre,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             subtitle: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const SizedBox(height: 6),
//                                 Text('Demandeur: ${ticket.auteurNom}'),
//                                 Text(
//                                   'Creation: ${DateFormat('dd/MM/yyyy HH:mm').format(ticket.dateCreation)}',
//                                 ),
//                                 const SizedBox(height: 6),
//                                 Wrap(
//                                   spacing: 8,
//                                   runSpacing: 8,
//                                   children: [
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 8,
//                                         vertical: 4,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: _getColorStatut(
//                                           ticket.statut,
//                                         ).withOpacity(0.15),
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       child: Text(
//                                         ticket.statut,
//                                         style: TextStyle(
//                                           color: _getColorStatut(ticket.statut),
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 8,
//                                         vertical: 4,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: _getColorPriorite(
//                                           ticket.priorite,
//                                         ).withOpacity(0.15),
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       child: Text(
//                                         ticket.priorite,
//                                         style: TextStyle(
//                                           color: _getColorPriorite(
//                                             ticket.priorite,
//                                           ),
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                     if (ticket.assigneA != null)
//                                       Text('Assigne a ${ticket.assigneA}'),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             onTap: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) =>
//                                     TicketDetailScreen(ticketId: ticket.id),
//                               ),
//                             ).then((_) => _loadData()),
//                             trailing: PopupMenuButton<String>(
//                               onSelected: (value) {
//                                 if (value == 'assign') {
//                                   _assignTicket(ticket);
//                                 } else if (value == 'status') {
//                                   _changeStatus(ticket);
//                                 } else if (value == 'detail') {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) => TicketDetailScreen(
//                                         ticketId: ticket.id,
//                                       ),
//                                     ),
//                                   ).then((_) => _loadData());
//                                 }
//                               },
//                               itemBuilder: (context) => const [
//                                 PopupMenuItem(
//                                   value: 'detail',
//                                   child: Text('Voir le detail'),
//                                 ),
//                                 PopupMenuItem(
//                                   value: 'assign',
//                                   child: Text('Attribuer'),
//                                 ),
//                                 PopupMenuItem(
//                                   value: 'status',
//                                   child: Text('Changer le statut'),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/ticket.dart';
import '../../services/admin_service.dart';
import '../../services/ticket_service.dart';
import '../citizen/ticket_detail_screen.dart';

class AdminTicketsScreen extends StatefulWidget {
  const AdminTicketsScreen({super.key});

  @override
  State<AdminTicketsScreen> createState() => _AdminTicketsScreenState();
}

class _AdminTicketsScreenState extends State<AdminTicketsScreen> {
  final AdminService _adminService = AdminService();
  final TicketService _ticketService = TicketService();

  List<Ticket> _tickets = [];
  List<Map<String, dynamic>> _technicians = [];
  bool _loading = true;
  String? _filterStatus;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
    });

    try {
      final ticketData = await _adminService.getAllTickets();
      final userData = await _adminService.getAllUsers();

      setState(() {
        _tickets = ticketData
            .map((j) => Ticket.fromJson(j as Map<String, dynamic>))
            .toList();
        _technicians = userData
            .where(
              (user) =>
                  user['role'] == 'TECHNICIEN' && (user['is_active'] == true),
            )
            .map((user) => Map<String, dynamic>.from(user))
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
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
    }
  }

  List<Ticket> get _filteredTickets {
    var filtered = _tickets;

    if (_filterStatus != null) {
      filtered = filtered
          .where((ticket) => ticket.statut == _filterStatus)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (ticket) =>
                ticket.titre.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                ticket.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                ticket.auteurNom.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    return filtered;
  }

  Future<void> _changeStatus(Ticket ticket) async {
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
                'Changer le statut',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ...['OUVERT', 'EN_COURS', 'RESOLU', 'CLOS'].map(
              (status) => ListTile(
                leading: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _getColorStatut(status),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(status),
                trailing: ticket.statut == status
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () => Navigator.pop(context, status),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (selected == null || selected == ticket.statut) return;

    try {
      await _ticketService.changerStatut(ticket.id, selected);
      if (mounted) {
        _showSnackBar('Statut mis à jour avec succès', true);
        await _loadData();
      }
    } catch (e) {
      _showSnackBar('Erreur: $e', false);
    }
  }

  Future<void> _assignTicket(Ticket ticket) async {
    if (_technicians.isEmpty) {
      _showSnackBar('Aucun technicien actif disponible', false);
      return;
    }

    final selected = await showModalBottomSheet<Map<String, dynamic>>(
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
                'Attribuer le ticket',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ..._technicians.map(
              (tech) => ListTile(
                leading: const Icon(Icons.person, color: Colors.grey),
                title: Text('${tech['first_name']} ${tech['last_name']}'),
                subtitle: Text(tech['email']),
                onTap: () => Navigator.pop(context, tech),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (selected == null) return;

    try {
      await _ticketService.assignerTicket(ticket.id, selected['id'] as int);
      _showSnackBar('Ticket attribué avec succès', true);
      await _loadData();
    } catch (e) {
      _showSnackBar('Erreur: $e', false);
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

  Color _getColorStatut(String statut) {
    switch (statut) {
      case 'OUVERT':
        return Colors.blue;
      case 'EN_COURS':
        return Colors.orange;
      case 'RESOLU':
        return Colors.green;
      case 'CLOS':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getColorPriorite(String priorite) {
    switch (priorite) {
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

  IconData _getPrioriteIcon(String priorite) {
    switch (priorite) {
      case 'CRITIQUE':
        return Icons.error_outline;
      case 'HAUTE':
        return Icons.warning_amber_outlined;
      case 'NORMALE':
        return Icons.info_outline;
      case 'BASSE':
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF006A4E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tickets',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.grey))
          : Column(
              children: [
                // Barre de recherche
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  color: Colors.white,
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un ticket...',
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
                      children: [
                        FilterChip(
                          label: const Text('Tous'),
                          selected: _filterStatus == null,
                          onSelected: (_) =>
                              setState(() => _filterStatus = null),
                          backgroundColor: Colors.grey[100],
                          selectedColor: Colors.grey[200],
                          labelStyle: TextStyle(
                            color: _filterStatus == null
                                ? Colors.black87
                                : Colors.grey[600],
                            fontWeight: _filterStatus == null
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ...['OUVERT', 'EN_COURS', 'RESOLU', 'CLOS'].map(
                          (status) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(status),
                              selected: _filterStatus == status,
                              onSelected: (selected) => setState(() {
                                _filterStatus = selected ? status : null;
                              }),
                              backgroundColor: Colors.grey[100],
                              selectedColor: _getColorStatut(
                                status,
                              ).withOpacity(0.1),
                              checkmarkColor: _getColorStatut(status),
                              labelStyle: TextStyle(
                                color: _filterStatus == status
                                    ? _getColorStatut(status)
                                    : Colors.grey[600],
                                fontWeight: _filterStatus == status
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                              side: BorderSide(
                                color: _filterStatus == status
                                    ? _getColorStatut(status)
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredTickets.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 64,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Aucun ticket trouvé',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          color: Colors.grey,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: _filteredTickets.length,
                            itemBuilder: (context, index) {
                              final ticket = _filteredTickets[index];
                              return _buildTicketCard(ticket);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildTicketCard(Ticket ticket) {
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
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TicketDetailScreen(ticketId: ticket.id),
            ),
          ).then((_) => _loadData()),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre et priorité
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ticket.titre,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _getColorPriorite(
                          ticket.priorite,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getPrioriteIcon(ticket.priorite),
                            size: 12,
                            color: _getColorPriorite(ticket.priorite),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ticket.priorite,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: _getColorPriorite(ticket.priorite),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Description (courte)
                Text(
                  ticket.description,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                // Infos supplémentaires
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ticket.auteurNom,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat(
                        'dd/MM/yyyy HH:mm',
                      ).format(ticket.dateCreation),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Badges et actions
                Row(
                  children: [
                    // Badge statut
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _getColorStatut(ticket.statut).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ticket.statut,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _getColorStatut(ticket.statut),
                        ),
                      ),
                    ),
                    if (ticket.assigneA != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person,
                              size: 10,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              ticket.assigneA!,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Spacer(),
                    // Menu actions
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_horiz, color: Colors.grey[500]),
                      onSelected: (value) {
                        if (value == 'assign') {
                          _assignTicket(ticket);
                        } else if (value == 'status') {
                          _changeStatus(ticket);
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'assign',
                          child: Text('Attribuer'),
                        ),
                        const PopupMenuItem(
                          value: 'status',
                          child: Text('Changer le statut'),
                        ),
                      ],
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
}
