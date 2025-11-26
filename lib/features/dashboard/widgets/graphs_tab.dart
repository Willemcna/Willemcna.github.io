import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/models/kpi_data.dart';
import '../../../features/dashboard/providers/analytics_provider.dart';
import '../../../shared/widgets/date_range_picker.dart';

class GraphsTab extends StatefulWidget {
  final AnalyticsProvider provider;
  final AnalyticsService analyticsService;

  const GraphsTab({
    super.key,
    required this.provider,
    required this.analyticsService,
  });

  @override
  State<GraphsTab> createState() => _GraphsTabState();
}

class _GraphsTabState extends State<GraphsTab> {
  List<Map<String, dynamic>> _timeSavedData = [];
  List<Map<String, dynamic>> _messageVolumeData = [];
  bool _isLoading = true;
  VoidCallback? _providerListener;

  @override
  void initState() {
    super.initState();
    _loadChartData();
    _providerListener = () {
      _loadChartData();
    };
    widget.provider.addListener(_providerListener!);
  }

  @override
  void didUpdateWidget(covariant GraphsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provider != widget.provider) {
      oldWidget.provider.removeListener(_providerListener!);
      widget.provider.addListener(_providerListener!);
      _loadChartData();
    }
  }

  @override
  void dispose() {
    if (_providerListener != null) {
      widget.provider.removeListener(_providerListener!);
    }
    super.dispose();
  }

  Future<void> _loadChartData() async {
    setState(() => _isLoading = true);

    try {
      final startDate = widget.provider.startDate ?? DateTime(2020);
      final endDate = widget.provider.endDate ?? DateTime.now();

      _timeSavedData = await widget.analyticsService.getTimeSavedOverTime(
        startDate: startDate,
        endDate: endDate,
      );

      _messageVolumeData = await widget.analyticsService.getMessageVolumeOverTime(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DateRangePickerWidget(provider: widget.provider),
          const SizedBox(height: 24),
          _buildTimeSavedChart(),
          const SizedBox(height: 24),
          _buildMessageVolumeChart(),
          const SizedBox(height: 24),
          _buildMessageTypesChart(),
          const SizedBox(height: 24),
          _buildTopProductsChart(),
        ],
      ),
    );
  }

  Widget _buildTimeSavedChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time Saved Over Time',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(title: AxisTitle(text: 'Time Saved (seconds)')),
                series: <LineSeries<Map<String, dynamic>, String>>[
                  LineSeries<Map<String, dynamic>, String>(
                    dataSource: _timeSavedData,
                    xValueMapper: (data, _) => data['date'] as String,
                    yValueMapper: (data, _) => data['timeSaved'] as double,
                    name: 'Time Saved',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageVolumeChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Message Volume Over Time',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(title: AxisTitle(text: 'Message Count')),
                series: <ColumnSeries<Map<String, dynamic>, String>>[
                  ColumnSeries<Map<String, dynamic>, String>(
                    dataSource: _messageVolumeData,
                    xValueMapper: (data, _) => data['date'] as String,
                    yValueMapper: (data, _) => data['count'] as int,
                    name: 'Messages',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageTypesChart() {
    final kpiData = widget.provider.kpiData;
    if (kpiData == null) return const SizedBox.shrink();

    final data = [
      {'type': 'Order Links', 'count': kpiData.orderLinksSent},
      {'type': 'Handovers', 'count': kpiData.handovers},
      {'type': 'Regular', 'count': kpiData.totalMessages - kpiData.orderLinksSent - kpiData.handovers},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Message Types Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCircularChart(
                series: <PieSeries<Map<String, dynamic>, String>>[
                  PieSeries<Map<String, dynamic>, String>(
                    dataSource: data,
                    xValueMapper: (data, _) => data['type'] as String,
                    yValueMapper: (data, _) => data['count'] as int,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductsChart() {
    final kpiData = widget.provider.kpiData;
    if (kpiData == null || kpiData.topProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    final top10 = kpiData.topProducts.take(10).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Products',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(title: AxisTitle(text: 'Mentions')),
                series: <BarSeries<ProductMention, String>>[
                  BarSeries<ProductMention, String>(
                    dataSource: top10,
                    xValueMapper: (data, _) => data.productName,
                    yValueMapper: (data, _) => data.mentionCount,
                    name: 'Mentions',
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

