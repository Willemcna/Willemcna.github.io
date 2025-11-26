import 'package:flutter/material.dart';
import '../../../core/models/kpi_data.dart';

class KPICards extends StatelessWidget {
  final KPIData? kpiData;

  const KPICards({super.key, this.kpiData});

  String _formatTime(double seconds) {
    if (seconds < 60) {
      return '${seconds.toInt()}s';
    } else if (seconds < 3600) {
      return '${(seconds / 60).toStringAsFixed(1)}m';
    } else {
      return '${(seconds / 3600).toStringAsFixed(1)}h';
    }
  }

  String _formatPercent(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    if (kpiData == null) {
      return const Center(child: Text('No data available'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        final crossAxisCount = isWide ? 4 : 2;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildKPICard(
              context,
              'Time Saved',
              _formatTime(kpiData!.timeSaved),
              Icons.access_time,
              Colors.blue,
            ),
            _buildKPICard(
              context,
              'Avg Response Time',
              _formatTime(kpiData!.averageResponseTime),
              Icons.timelapse,
              Colors.teal,
            ),
            _buildKPICard(
              context,
              'P95 Response Time',
              _formatTime(kpiData!.p95ResponseTime),
              Icons.query_stats,
              Colors.indigo,
            ),
            _buildKPICard(
              context,
              'Total Messages',
              kpiData!.totalMessages.toString(),
              Icons.message,
              Colors.green,
            ),
            _buildKPICard(
              context,
              'Auto-Answered',
              _formatPercent(kpiData!.autoAnsweredPercentage),
              Icons.smart_toy,
              Colors.cyan,
            ),
            _buildKPICard(
              context,
              'Order Links Sent',
              kpiData!.orderLinksSent.toString(),
              Icons.link,
              Colors.orange,
            ),
            _buildKPICard(
              context,
              'Human Handovers',
              kpiData!.handovers.toString(),
              Icons.phone,
              Colors.purple,
            ),
            _buildKPICard(
              context,
              'Unique Customers',
              kpiData!.uniqueCustomers.toString(),
              Icons.people,
              Colors.brown,
            ),
            _buildKPICard(
              context,
              'Returning Customers',
              kpiData!.returningCustomers.toString(),
              Icons.repeat,
              Colors.pink,
            ),
          ],
        );
      },
    );
  }

  Widget _buildKPICard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
}

