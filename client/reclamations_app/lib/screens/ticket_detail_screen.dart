import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/ticket_service.dart';

class TicketDetailScreen extends StatefulWidget {
  final int ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final TicketService _service = TicketService();
  late Future<Ticket> _ticketFuture;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _ticketFuture = _service.getTicket(widget.ticketId);
  }

  Future<void> _changerStatut(String nouveauStatut) async {
    setState(() => _loading = true);

    try {
      await _service.changerStatut(widget.ticketId, nouveauStatut);
      setState(() {
        _ticketFuture = _service.getTicket(widget.ticketId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Statut mis à jour : $nouveauStatut'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showStatutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Changer le statut'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['OUVERT', 'EN_COURS', 'RESOLU', 'CLOS']
              .map(
                (statut) => ListTile(
                  title: Text(statut),
                  onTap: () {
                    Navigator.pop(context);
                    _changerStatut(statut);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail du ticket'),
        backgroundColor: const Color(0xFF006743),
        foregroundColor: Colors.white,
        actions: [
          if (!_loading)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Changer le statut',
              onPressed: _showStatutDialog,
            ),
        ],
      ),
      body: FutureBuilder<Ticket>(
        future: _ticketFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erreur: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _ticketFuture = _service.getTicket(widget.ticketId);
                      });
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Ticket introuvable'));
          }

          final ticket = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with ID and status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '#${ticket.id} - ${ticket.titre}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getColorStatut(ticket.statut),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        ticket.statut,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Info cards
                _buildInfoCard(
                  icon: Icons.description,
                  label: 'Description',
                  value: ticket.description,
                ),

                const SizedBox(height: 16),

                _buildInfoCard(
                  icon: Icons.category,
                  label: 'Type',
                  value: ticket.typeTicket,
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.flag,
                        label: 'Priorité',
                        value: ticket.priorite,
                        color: _getColorPriorite(ticket.priorite),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.person,
                        label: 'Auteur',
                        value: ticket.auteurNom,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _buildInfoCard(
                  icon: Icons.calendar_today,
                  label: 'Date de création',
                  value: ticket.dateCreation,
                ),

                if (ticket.assigneA != null) ...[
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    icon: Icons.support_agent,
                    label: 'Assigné à',
                    value: ticket.assigneA!,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color ?? const Color(0xFF006743), size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
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
        return Colors.black;
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
}
