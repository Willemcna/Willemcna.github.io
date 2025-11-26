import 'package:flutter/foundation.dart';
import '../../../core/models/kpi_data.dart';
import '../../../core/services/analytics_service.dart';

enum DateRangeType { today, last7Days, last30Days, allTime, custom }

class AnalyticsProvider with ChangeNotifier {
  final AnalyticsService _analyticsService;

  AnalyticsProvider(this._analyticsService);

  KPIData? _kpiData;
  DateRangeType _dateRangeType = DateRangeType.allTime;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  bool _isLoading = false;
  String? _error;

  KPIData? get kpiData => _kpiData;
  DateRangeType get dateRangeType => _dateRangeType;
  DateTime? get customStartDate => _customStartDate;
  DateTime? get customEndDate => _customEndDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  DateTime? get startDate {
    final now = DateTime.now();
    switch (_dateRangeType) {
      case DateRangeType.today:
        return DateTime(now.year, now.month, now.day);
      case DateRangeType.last7Days:
        return now.subtract(const Duration(days: 7));
      case DateRangeType.last30Days:
        return now.subtract(const Duration(days: 30));
      case DateRangeType.custom:
        return _customStartDate;
      case DateRangeType.allTime:
        return null;
    }
  }

  DateTime? get endDate {
    if (_dateRangeType == DateRangeType.custom) {
      return _customEndDate;
    }
    return DateTime.now();
  }

  Future<void> loadKPIs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _kpiData = await _analyticsService.calculateKPIs(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setDateRange(DateRangeType type) {
    _dateRangeType = type;
    loadKPIs();
  }

  void setCustomDateRange(DateTime start, DateTime end) {
    _dateRangeType = DateRangeType.custom;
    _customStartDate = start;
    _customEndDate = end;
    loadKPIs();
  }
}

