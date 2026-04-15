import 'package:flutter/material.dart';
import '../../models/ticket.dart';
import '../../services/ticket_service.dart';
import '../../widgets/ticket_card.dart';
import 'ticket_detail_screen.dart';
import 'create_ticket_screen.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  final TicketService _service = TicketService();
  late Future<List<Ticket>> _futureTickets;

  String? _filtreStatut;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  void _charger() {
    _futureTickets = _service.listerTickets(statut: _filtreStatut);
    setState(() {});
  }

  Color _couleurStatut(String statut) {
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
        title: const Text('Mes tickets'),
        backgroundColor: const Color(0xFF006743),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (val) {
              _filtreStatut = val;
              _charger();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: null, child: Text('Tous')),
              PopupMenuItem(value: 'OUVERT', child: Text('Ouvert')),
              PopupMenuItem(value: 'EN_COURS', child: Text('En cours')),
              PopupMenuItem(value: 'RESOLU', child: Text('Résolu')),
              PopupMenuItem(value: 'CLOS', child: Text('Clos')),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Ticket>>(
        future: _futureTickets,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final tickets = snapshot.data ?? [];

          if (tickets.isEmpty) {
            return const Center(child: Text('Aucun ticket trouvé.'));
          }

          return RefreshIndicator(
            onRefresh: () async => _charger(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: tickets.length,
              itemBuilder: (_, i) => TicketCard(
                ticket: tickets[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TicketDetailScreen(ticketId: tickets[i].id),
                  ),
                ).then((_) => _charger()),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateTicketScreen()),
        ).then((_) => _charger()),
        label: const Text('Nouveau ticket'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF006743),
      ),
    );
  }
}
