import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../models/ticket.dart';
import 'ticket_detail_screen.dart';

class AdminTicketsScreen extends StatefulWidget {
  const AdminTicketsScreen({super.key});

  @override
  State<AdminTicketsScreen> createState() => _AdminTicketsScreenState();
}

class _AdminTicketsScreenState extends State<AdminTicketsScreen> {
  final AdminService _adminService = AdminService();

  List<Ticket> _tickets = [];
  bool _loading = true;
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() {
      _loading = true;
    });

    try {
      final data = await _adminService.getAllTickets();
      final tickets = (data as List).map((j) => Ticket.fromJson(j)).toList();

      setState(() {
        _tickets = tickets;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
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
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tous les tickets'),
        backgroundColor: const Color(0xFF006743),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTickets),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter chips
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Tous'),
                          selected: _filterStatus == null,
                          onSelected: (selected) {
                            setState(() => _filterStatus = null);
                          },
                        ),
                        const SizedBox(width: 8),
                        ...['OUVERT', 'EN_COURS', 'RESOLU', 'CLOS'].map((
                          status,
                        ) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(status),
                              selected: _filterStatus == status,
                              onSelected: (selected) {
                                setState(
                                  () =>
                                      _filterStatus = selected ? status : null,
                                );
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                // Tickets list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadTickets,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _filterStatus != null
                          ? _tickets
                                .where((t) => t.statut == _filterStatus)
                                .length
                          : _tickets.length,
                      itemBuilder: (context, index) {
                        final filteredTickets = _filterStatus != null
                            ? _tickets
                                  .where((t) => t.statut == _filterStatus)
                                  .toList()
                            : _tickets;

                        final ticket = filteredTickets[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(ticket.titre),
                            subtitle: Text(
                              '${ticket.auteurNom} - ${ticket.dateCreation}',
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getColorStatut(
                                  ticket.statut,
                                ).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getColorStatut(ticket.statut),
                                ),
                              ),
                              child: Text(
                                ticket.statut,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _getColorStatut(ticket.statut),
                                ),
                              ),
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TicketDetailScreen(ticketId: ticket.id),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
