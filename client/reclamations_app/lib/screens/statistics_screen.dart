import 'package:flutter/material.dart';
import '../services/ticket_service.dart';

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
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: const Color(0xFF006743),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erreur: $_error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadStatistics,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            )
          : _stats == null
          ? const Center(child: Text('Aucune donnée'))
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total
                    _buildSummaryCard(),
                    const SizedBox(height: 24),

                    // By Status
                    if (_stats!['by_status'] != null) ...[
                      const Text(
                        'Par statut',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildBarChart(_stats!['by_status']),
                      const SizedBox(height: 24),
                    ],

                    // By Type
                    if (_stats!['by_type'] != null) ...[
                      const Text(
                        'Par type',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPieChart(_stats!['by_type']),
                      const SizedBox(height: 24),
                    ],

                    // By Priority
                    if (_stats!['by_priority'] != null) ...[
                      const Text(
                        'Par priorité',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPriorityList(_stats!['by_priority']),
                      const SizedBox(height: 24),
                    ],

                    // Resolution Time
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF006743), Color(0xFF004d33)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.analytics, size: 48, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'Total: ${_stats!['total'] ?? 0}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Tickets',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, dynamic> data) {
    final maxCount = data.values.cast<int>().reduce((a, b) => a > b ? a : b);

    return Column(
      children: data.entries.map((entry) {
        final percentage = (entry.value / maxCount * 100).toInt();
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  _formatLabel(entry.key),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: entry.value / maxCount,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getColor(entry.key),
                    ),
                    minHeight: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${entry.value}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPieChart(Map<String, dynamic> data) {
    final total = data.values.fold<int>(0, (sum, val) => sum + (val as int));

    return Column(
      children: data.entries.map((entry) {
        final percentage = ((entry.value / total) * 100).toInt();
        return ListTile(
          leading: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _getColor(entry.key),
              shape: BoxShape.circle,
            ),
          ),
          title: Text(_formatLabel(entry.key)),
          trailing: Text('$percentage%'),
        );
      }).toList(),
    );
  }

  Widget _buildPriorityList(Map<String, dynamic> data) {
    return Column(
      children: data.entries.map((entry) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              _getPriorityIcon(entry.key),
              color: _getColor(entry.key),
            ),
            title: Text(_formatLabel(entry.key)),
            subtitle: Text('${entry.value} tickets'),
            trailing: Icon(Icons.chevron_right, color: _getColor(entry.key)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResolutionTimeCard() {
    final time = _stats!['average_resolution_time'] as Map<String, dynamic>;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.timer, size: 32, color: Color(0xFF006743)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Temps moyen de résolution',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '${time['days'] ?? 0}j ${time['hours'] ?? 0}h ${time['minutes'] ?? 0}m',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLabel(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
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

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'CRITIQUE':
        return Icons.error;
      case 'HAUTE':
        return Icons.warning;
      case 'NORMALE':
        return Icons.info;
      case 'BASSE':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }
}
