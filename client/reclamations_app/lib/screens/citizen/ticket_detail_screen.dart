import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/ticket.dart';
import '../../services/auth_service.dart';
import '../../services/ticket_service.dart';

class TicketDetailScreen extends StatefulWidget {
  final int ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final TicketService _service = TicketService();
  final AuthService _authService = AuthService();
  final TextEditingController _commentCtrl = TextEditingController();

  late Future<Ticket> _ticketFuture;
  bool _loading = false;
  bool _sendingComment = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _reloadTicket();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _reloadTicket() {
    setState(() {
      _ticketFuture = _service.getTicket(widget.ticketId);
    });
  }

  Future<void> _loadUserRole() async {
    final role = await _authService.getUserRole();
    if (mounted) {
      setState(() {
        _userRole = role;
      });
    }
  }

  bool get _canChangeStatus =>
      _userRole == 'ADMIN' || _userRole == 'TECHNICIEN';

  Future<void> _changerStatut(String nouveauStatut) async {
    setState(() => _loading = true);

    try {
      await _service.changerStatut(widget.ticketId, nouveauStatut);
      _reloadTicket();

      if (mounted) {
        _showSnackBar('Statut mis à jour: $nouveauStatut', true);
      }
    } catch (e) {
      _showSnackBar('Erreur: $e', false);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _ajouterCommentaire() async {
    final contenu = _commentCtrl.text.trim();
    if (contenu.isEmpty) return;

    setState(() => _sendingComment = true);

    try {
      await _service.commenter(widget.ticketId, contenu);
      _commentCtrl.clear();
      _reloadTicket();
      _showSnackBar('Commentaire ajouté avec succès', true);
    } catch (e) {
      _showSnackBar('Erreur: $e', false);
    } finally {
      setState(() => _sendingComment = false);
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

  void _showStatutDialog() {
    showModalBottomSheet(
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
              (statut) => ListTile(
                leading: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _getColorStatut(statut),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(statut),
                onTap: () {
                  Navigator.pop(context);
                  _changerStatut(statut);
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
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
          'Détail du ticket',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          if (_canChangeStatus)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.grey),
              tooltip: 'Changer le statut',
              onPressed: _showStatutDialog,
            ),
        ],
      ),
      body: FutureBuilder<Ticket>(
        future: _ticketFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.grey),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorView();
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Ticket introuvable'));
          }

          final ticket = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête du ticket
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              ticket.titre,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getColorStatut(
                                ticket.statut,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getColorStatut(ticket.statut),
                              ),
                            ),
                            child: Text(
                              ticket.statut,
                              style: TextStyle(
                                color: _getColorStatut(ticket.statut),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
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
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(ticket.dateCreation),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                _buildInfoSection(
                  icon: Icons.description_outlined,
                  title: 'Description',
                  content: ticket.description,
                ),

                const SizedBox(height: 16),

                // Type et Priorité
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoSection(
                        icon: Icons.category_outlined,
                        title: 'Type',
                        content: ticket.typeTicket,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoSection(
                        icon: Icons.flag_outlined,
                        title: 'Priorité',
                        content: ticket.priorite,
                        color: _getColorPriorite(ticket.priorite),
                      ),
                    ),
                  ],
                ),

                if (ticket.assigneA != null) ...[
                  const SizedBox(height: 16),
                  _buildInfoSection(
                    icon: Icons.support_agent_outlined,
                    title: 'Assigné à',
                    content: ticket.assigneA!,
                  ),
                ],

                const SizedBox(height: 24),

                // Section Commentaires
                Row(
                  children: [
                    const Icon(
                      Icons.comment_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Commentaires',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${ticket.commentaires.length}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Zone de commentaire
                _buildCommentComposer(),

                const SizedBox(height: 12),

                // Liste des commentaires
                if (ticket.commentaires.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Aucun commentaire',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  )
                else
                  ...ticket.commentaires.map(_buildCommentCard),

                const SizedBox(height: 24),

                // Section Historique
                Row(
                  children: [
                    const Icon(
                      Icons.history_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Historique',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${ticket.historique.length}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (ticket.historique.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Aucun historique',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  )
                else
                  ...ticket.historique.map(_buildHistoryCard),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color ?? Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content.isEmpty ? 'Non spécifié' : content,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentComposer() {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _commentCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ajouter un commentaire...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _sendingComment ? null : _ajouterCommentaire,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006A4E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _sendingComment
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Envoyer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentCard(TicketComment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                comment.auteurNom.isEmpty ? 'Utilisateur' : comment.auteurNom,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(comment.date),
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.contenu,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(TicketHistory history) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.history, size: 16, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${history.ancienStatut} → ${history.nouveauStatut}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${history.modifiePar.isEmpty ? 'Système' : history.modifiePar} • ${DateFormat('dd/MM/yyyy HH:mm').format(history.dateChangement)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
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
            onPressed: _reloadTicket,
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
}
