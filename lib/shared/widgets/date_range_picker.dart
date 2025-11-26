import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../features/dashboard/providers/analytics_provider.dart';

class DateRangePickerWidget extends StatelessWidget {
  final AnalyticsProvider provider;

  const DateRangePickerWidget({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildButton(context, 'Today', DateRangeType.today),
        const SizedBox(width: 8),
        _buildButton(context, '7 Days', DateRangeType.last7Days),
        const SizedBox(width: 8),
        _buildButton(context, '30 Days', DateRangeType.last30Days),
        const SizedBox(width: 8),
        _buildButton(context, 'All Time', DateRangeType.allTime),
        const SizedBox(width: 8),
        _buildCustomButton(context),
      ],
    );
  }

  Widget _buildButton(BuildContext context, String label, DateRangeType type) {
    final isSelected = provider.dateRangeType == type;
    return ElevatedButton(
      onPressed: () => provider.setDateRange(type),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
        foregroundColor: isSelected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
      ),
      child: Text(label),
    );
  }

  Widget _buildCustomButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        final DateTimeRange? picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDateRange: provider.dateRangeType == DateRangeType.custom
              ? DateTimeRange(
                  start: provider.customStartDate ?? DateTime.now(),
                  end: provider.customEndDate ?? DateTime.now(),
                )
              : null,
        );

        if (picked != null) {
          provider.setCustomDateRange(picked.start, picked.end);
        }
      },
      child: Text(
        provider.dateRangeType == DateRangeType.custom
            ? '${DateFormat('MMM d').format(provider.customStartDate!)} - ${DateFormat('MMM d').format(provider.customEndDate!)}'
            : 'Custom',
      ),
    );
  }
}

