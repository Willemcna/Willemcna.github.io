import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/handover.dart';
import '../services/tenant_service.dart';
import 'dart:async';

class HandoverService {
  final TenantService _tenantService;
  RealtimeChannel? _realtimeChannel;

  HandoverService(this._tenantService);

  /// Get all handover entries from the tenant database
  Future<List<Handover>> getHandovers() async {
    final client = _tenantService.tenantClient;
    if (client == null) throw Exception('Tenant client not initialized');

    try {
      final response = await client
          .from('Handover')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Handover.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load handovers: $e');
    }
  }

  /// Get handover bucket for a session ID
  Future<String?> getBucketForSession(String sessionId) async {
    final handovers = await getHandovers();
    final handover = handovers.firstWhere(
      (h) => h.sessionId == sessionId,
      orElse: () => throw StateError('No handover found'),
    );
    return handover.bucket;
  }

  /// Check if a session ID is in handover
  Future<bool> isSessionInHandover(String sessionId) async {
    try {
      await getBucketForSession(sessionId);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get all session IDs for a specific bucket
  Future<List<String>> getSessionIdsForBucket(String bucket) async {
    final handovers = await getHandovers();
    return handovers
        .where((h) => h.bucket.toLowerCase() == bucket.toLowerCase())
        .map((h) => h.sessionId)
        .toList();
  }

  /// Subscribe to real-time updates for handover table
  Stream<List<Handover>> subscribeToHandovers() {
    final client = _tenantService.tenantClient;
    if (client == null) throw Exception('Tenant client not initialized');

    final controller = StreamController<List<Handover>>();

    // Initial load
    getHandovers()
        .then((handovers) {
          if (!controller.isClosed) {
            controller.add(handovers);
          }
        })
        .catchError((e) {
          // Handle error silently
        });

    _realtimeChannel?.unsubscribe();
    _realtimeChannel = client
        .channel('handovers')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'Handover',
          callback: (payload) {
            // Reload all handovers when changes occur
            getHandovers()
                .then((handovers) {
                  if (!controller.isClosed) {
                    controller.add(handovers);
                  }
                })
                .catchError((e) {
                  // Handle error silently
                });
          },
        )
        .subscribe();

    return controller.stream;
  }

  /// Unsubscribe from real-time updates
  void unsubscribe() {
    _realtimeChannel?.unsubscribe();
    _realtimeChannel = null;
  }
}
