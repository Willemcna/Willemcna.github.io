import '../models/chat_message.dart';
import '../models/kpi_data.dart';
import '../utils/message_parser.dart';
import '../utils/time_calculator.dart';
import '../services/tenant_service.dart';
import '../services/product_service.dart';

class AnalyticsService {
  final TenantService _tenantService;
  final ProductService _productService;

  AnalyticsService(this._tenantService, this._productService);

  /// Get all messages for analytics
  Future<List<ChatMessage>> getAllMessages({DateTime? startDate, DateTime? endDate}) async {
    final client = _tenantService.tenantClient;
    if (client == null) throw Exception('Tenant client not initialized');

    // Try multiple timestamp columns for compatibility with different schemas
    final List<String> timeColumns = ['time', 'created_at', 'timestamp'];
    dynamic response;
    for (final col in timeColumns) {
      try {
    var query = client.from('n8n_chat_histories').select();
    if (startDate != null) {
          query = query.gte(col, startDate.toIso8601String());
    }
    if (endDate != null) {
          query = query.lte(col, endDate.toIso8601String());
    }
        response = await query.order(col, ascending: true);
        break; // success
      } catch (_) {
        response = null;
      }
    }

    if (response == null) {
      throw Exception('Failed to load messages: check table/columns and RLS');
    }

    return (response as List)
        .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Calculate KPIs for a date range
  Future<KPIData> calculateKPIs({DateTime? startDate, DateTime? endDate}) async {
    final messages = await getAllMessages(startDate: startDate, endDate: endDate);
    
    // Group messages by customer (session_id) for response and customer metrics
    final Map<String, List<ChatMessage>> messagesByCustomer = _groupMessagesByCustomer(messages);

    // Response efficiency metrics
    final _ResponseStats responseStats = _calculateResponseStats(messagesByCustomer);

    // Customer impact metrics
    final int uniqueCustomers = messagesByCustomer.keys.length;
    final int returningCustomers = _calculateReturningCustomers(messagesByCustomer, daysWindow: 7);

    // Calculate time saved
    final timeSaved = startDate != null && endDate != null
        ? TimeCalculator.calculateTimeSavedForPeriod(messages, startDate, endDate)
        : TimeCalculator.calculateTimeSaved(messages);

    // Count message types
    int orderLinksSent = 0;
    int handovers = 0;
    
    for (final message in messages) {
      if (MessageParser.hasOrderLink(message.message.content, message.message.isAI)) {
        orderLinksSent++;
      }
      if (MessageParser.hasHandover(message.message.content, message.message.isAI)) {
        handovers++;
      }
    }

    // Get top products
    final productNames = await _productService.getProductNames();
    final productMentions = <String, int>{};
    
    for (final message in messages) {
      final matchedProducts = MessageParser.matchProducts(
        message.message.content,
        productNames,
      );
      for (final product in matchedProducts) {
        productMentions[product] = (productMentions[product] ?? 0) + 1;
      }
    }

    final topProducts = productMentions.entries
        .map((e) => ProductMention(productName: e.key, mentionCount: e.value))
        .toList()
      ..sort((a, b) => b.mentionCount.compareTo(a.mentionCount));

    return KPIData(
      timeSaved: timeSaved,
      totalMessages: messages.length,
      orderLinksSent: orderLinksSent,
      handovers: handovers,
      averageResponseTime: responseStats.averageSeconds,
      p95ResponseTime: responseStats.p95Seconds,
      autoAnsweredPercentage: responseStats.autoAnsweredPercentage,
      uniqueCustomers: uniqueCustomers,
      returningCustomers: returningCustomers,
      topProducts: topProducts.take(10).toList(),
    );
  }

  Map<String, List<ChatMessage>> _groupMessagesByCustomer(List<ChatMessage> messages) {
    final Map<String, List<ChatMessage>> grouped = {};
    for (final msg in messages) {
      final key = msg.sessionId;
      if (key.isEmpty) continue;
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(msg);
    }
    for (final entry in grouped.entries) {
      entry.value.sort((a, b) => a.time.compareTo(b.time));
    }
    return grouped;
  }

  _ResponseStats _calculateResponseStats(Map<String, List<ChatMessage>> messagesByCustomer) {
    final List<double> responseSeconds = [];
    int totalHumanMessages = 0;
    int autoAnsweredCount = 0;

    for (final entry in messagesByCustomer.entries) {
      final List<ChatMessage> msgs = entry.value;
      for (int i = 0; i < msgs.length; i++) {
        final ChatMessage current = msgs[i];
        if (!current.message.isHuman) continue;
        totalHumanMessages++;
        // Find next AI response
        for (int j = i + 1; j < msgs.length; j++) {
          if (msgs[j].message.isAI) {
            final double secs = msgs[j].time.difference(current.time).inMilliseconds / 1000.0;
            if (secs >= 0) {
              responseSeconds.add(secs);
              autoAnsweredCount++;
            }
            break; // only the first AI following a human is considered
          }
          // If another human message appears before AI, we continue looking
        }
      }
    }

    responseSeconds.sort();
    double average = 0.0;
    double p95 = 0.0;
    if (responseSeconds.isNotEmpty) {
      final double sum = responseSeconds.fold(0.0, (a, b) => a + b);
      average = sum / responseSeconds.length;
      final int p95Index = ((responseSeconds.length - 1) * 0.95).round();
      p95 = responseSeconds[p95Index];
    }

    final double autoPct = totalHumanMessages == 0
        ? 0.0
        : (autoAnsweredCount * 100.0) / totalHumanMessages;

    return _ResponseStats(
      averageSeconds: average,
      p95Seconds: p95,
      autoAnsweredPercentage: autoPct,
    );
  }

  int _calculateReturningCustomers(
    Map<String, List<ChatMessage>> messagesByCustomer, {
    required int daysWindow,
  }) {
    int count = 0;
    final Duration window = Duration(days: daysWindow);

    for (final entry in messagesByCustomer.entries) {
      // Consider only human messages for "customer messaged again"
      final List<DateTime> humanTimes = entry.value
          .where((m) => m.message.isHuman)
          .map((m) => m.time)
          .toList()
        ..sort();
      if (humanTimes.length < 2) continue;
      final DateTime first = humanTimes.first;
      // Check if there exists a later human message within the window
      bool isReturning = false;
      for (int i = 1; i < humanTimes.length; i++) {
        final Duration delta = humanTimes[i].difference(first);
        if (delta.isNegative) continue;
        if (delta <= window) {
          isReturning = true;
          break;
        }
      }
      if (isReturning) count++;
    }
    return count;
  }

  /// Get time saved data over time for charts
  Future<List<Map<String, dynamic>>> getTimeSavedOverTime({
    required DateTime startDate,
    required DateTime endDate,
    String groupBy = 'day', // 'day', 'week', 'month'
  }) async {
    final messages = await getAllMessages(startDate: startDate, endDate: endDate);
    
    // Group messages by time period
    final grouped = <String, List<ChatMessage>>{};
    
    for (final message in messages) {
      String key;
      if (groupBy == 'day') {
        key = '${message.time.year}-${message.time.month.toString().padLeft(2, '0')}-${message.time.day.toString().padLeft(2, '0')}';
      } else if (groupBy == 'week') {
        final weekStart = message.time.subtract(Duration(days: message.time.weekday - 1));
        key = '${weekStart.year}-W${((weekStart.difference(DateTime(weekStart.year, 1, 1)).inDays) / 7).floor()}';
      } else {
        key = '${message.time.year}-${message.time.month.toString().padLeft(2, '0')}';
      }
      
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(message);
    }

    return grouped.entries.map((entry) {
      final timeSaved = TimeCalculator.calculateTimeSaved(entry.value);
      return {
        'date': entry.key,
        'timeSaved': timeSaved,
      };
    }).toList()
      ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
  }

  /// Get message volume over time
  Future<List<Map<String, dynamic>>> getMessageVolumeOverTime({
    required DateTime startDate,
    required DateTime endDate,
    String groupBy = 'day',
  }) async {
    final messages = await getAllMessages(startDate: startDate, endDate: endDate);
    
    final grouped = <String, int>{};
    
    for (final message in messages) {
      String key;
      if (groupBy == 'day') {
        key = '${message.time.year}-${message.time.month.toString().padLeft(2, '0')}-${message.time.day.toString().padLeft(2, '0')}';
      } else if (groupBy == 'week') {
        final weekStart = message.time.subtract(Duration(days: message.time.weekday - 1));
        key = '${weekStart.year}-W${((weekStart.difference(DateTime(weekStart.year, 1, 1)).inDays) / 7).floor()}';
      } else {
        key = '${message.time.year}-${message.time.month.toString().padLeft(2, '0')}';
      }
      
      grouped[key] = (grouped[key] ?? 0) + 1;
    }

    return grouped.entries.map((entry) {
      return {
        'date': entry.key,
        'count': entry.value,
      };
    }).toList()
      ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
  }
}

class _ResponseStats {
  final double averageSeconds;
  final double p95Seconds;
  final double autoAnsweredPercentage;

  _ResponseStats({
    required this.averageSeconds,
    required this.p95Seconds,
    required this.autoAnsweredPercentage,
  });
}

