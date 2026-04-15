import 'package:flutter/material.dart';
import '../../services/ticket_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final TicketService _service = TicketService();

  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _service.getStatistics();
      setState(() {
        _stats = data;
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF006A4E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Statistiques',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.grey))
          : _error != null
          ? _buildErrorView()
          : _stats == null
          ? const Center(child: Text('Aucune donnée'))
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              color: Colors.grey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carte total
                    _buildSummaryCard(),
                    const SizedBox(height: 24),

                    // Par statut
                    if (_stats!['by_status'] != null) ...[
                      const Text(
                        'Répartition par statut',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildStatusStats(_stats!['by_status']),
                      const SizedBox(height: 24),
                    ],

                    // Par type
                    if (_stats!['by_type'] != null) ...[
                      const Text(
                        'Répartition par type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTypeStats(_stats!['by_type']),
                      const SizedBox(height: 24),
                    ],

                    // Par priorité
                    if (_stats!['by_priority'] != null) ...[
                      const Text(
                        'Répartition par priorité',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPriorityStats(_stats!['by_priority']),
                      const SizedBox(height: 24),
                    ],

                    // Temps de résolution
                    if (_stats!['average_resolution_time'] != null) ...[
                      _buildResolutionTimeCard(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    final total = _stats!['total'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.analytics, size: 28, color: Colors.grey[700]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total des tickets',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  total.toString(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStats(Map<String, dynamic> data) {
    final statusOrder = ['OUVERT', 'EN_COURS', 'RESOLU', 'CLOS'];
    final sortedData = Map.fromEntries(
      statusOrder
          .where((key) => data.containsKey(key))
          .map((key) => MapEntry(key, data[key])),
    );

    return Column(
      children: sortedData.entries.map((entry) {
        final percentage = _stats!['total'] > 0
            ? ((entry.value / _stats!['total']) * 100).toInt()
            : 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _getColor(entry.key),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatLabel(entry.key),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${entry.value} tickets',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getColor(entry.key),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: entry.value / _stats!['total'],
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getColor(entry.key),
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$percentage%',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypeStats(Map<String, dynamic> data) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final entry = data.entries.elementAt(index);
        final percentage = _stats!['total'] > 0
            ? ((entry.value / _stats!['total']) * 100).toInt()
            : 0;
        return Container(
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getTypeIcon(entry.key),
                size: 28,
                color: _getColor(entry.key),
              ),
              const SizedBox(height: 8),
              Text(
                _formatLabel(entry.key),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${entry.value}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _getColor(entry.key),
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriorityStats(Map<String, dynamic> data) {
    final priorityOrder = ['CRITIQUE', 'HAUTE', 'NORMALE', 'BASSE'];
    final sortedData = Map.fromEntries(
      priorityOrder
          .where((key) => data.containsKey(key))
          .map((key) => MapEntry(key, data[key])),
    );

    return Column(
      children: sortedData.entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getColor(entry.key).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getPriorityIcon(entry.key),
                  color: _getColor(entry.key),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatLabel(entry.key),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${entry.value} tickets',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getColor(entry.key).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getPercentage(entry.value),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getColor(entry.key),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResolutionTimeCard() {
    final time = _stats!['average_resolution_time'] as Map<String, dynamic>;
    final days = time['days'] ?? 0;
    final hours = time['hours'] ?? 0;
    final minutes = time['minutes'] ?? 0;

    return Container(
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.timer_outlined,
              size: 24,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Temps moyen de résolution',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (days > 0) ...[
                      Text(
                        '$days',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('j ', style: TextStyle(fontSize: 16)),
                    ],
                    if (hours > 0) ...[
                      Text(
                        '$hours',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('h ', style: TextStyle(fontSize: 16)),
                    ],
                    Text(
                      '$minutes',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('m', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPercentage(int value) {
    if (_stats!['total'] == 0) return '0%';
    final percentage = ((value / _stats!['total']) * 100).toInt();
    return '$percentage%';
  }

  String _formatLabel(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  Color _getColor(String key) {
    switch (key) {
      case 'OUVERT':
        return Colors.blue;
      case 'EN_COURS':
        return Colors.orange;
      case 'RESOLU':
        return Colors.green;
      case 'CLOS':
        return Colors.grey;
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

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'PROBLEME_TECHNIQUE':
        return Icons.computer;
      case 'RECLAMATION':
        return Icons.feedback;
      case 'DEMANDE_INFO':
        return Icons.info;
      default:
        return Icons.category;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
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
            onPressed: _loadStatistics,
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
}
