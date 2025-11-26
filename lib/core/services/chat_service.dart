import 'package:supabase_flutter/supabase_flutter.dart' hide Session;
import '../models/chat_message.dart';
import '../models/session.dart' as models;
import '../services/tenant_service.dart';
import 'dart:async';

class ChatService {
  final TenantService _tenantService;
  RealtimeChannel? _realtimeChannel;

  ChatService(this._tenantService);

  /// Get all sessions (grouped by session_id, considering 1hr gaps)
  Future<List<models.Session>> getSessions() async {
    final client = _tenantService.tenantClient;
    if (client == null) throw Exception('Tenant client not initialized');

    dynamic response;
    final List<String> timeColumns = ['time', 'created_at', 'timestamp'];
    for (final col in timeColumns) {
      try {
        response = await client
        .from('n8n_chat_histories')
        .select()
            .order(col, ascending: false);
        break;
      } catch (_) {
        response = null;
      }
    }
    if (response == null) {
      throw Exception('Failed to load sessions: check table/columns and RLS');
    }

    final messages = (response as List)
        .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
        .toList();

    // Group by session_id and handle 1hr gaps
    final sessionMap = <String, List<ChatMessage>>{};
    
    for (final message in messages) {
      if (!sessionMap.containsKey(message.sessionId)) {
        sessionMap[message.sessionId] = [];
      }
      sessionMap[message.sessionId]!.add(message);
    }

    // Sort messages within each session by time
    for (final sessionId in sessionMap.keys) {
      sessionMap[sessionId]!.sort((a, b) => a.time.compareTo(b.time));
    }

    // Create Session objects
    final sessions = sessionMap.entries.map((entry) {
      final sessionMessages = entry.value;
      final lastMessage = sessionMessages.last;
      
      return models.Session(
        sessionId: entry.key,
        messages: sessionMessages,
        lastMessageTime: lastMessage.time,
      );
    }).toList();

    // Sort sessions by last message time (newest first)
    sessions.sort((a, b) => b.lastMessageDateTime.compareTo(a.lastMessageDateTime));

    return sessions;
  }

  /// Get messages for a specific session
  Future<List<ChatMessage>> getSessionMessages(String sessionId, {int limit = 50, int offset = 0}) async {
    final client = _tenantService.tenantClient;
    if (client == null) throw Exception('Tenant client not initialized');

    dynamic response;
    final List<String> timeColumns = ['time', 'created_at', 'timestamp'];
    for (final col in timeColumns) {
      try {
        response = await client
        .from('n8n_chat_histories')
        .select()
        .eq('session_id', sessionId)
            .order(col, ascending: false)
        .range(offset, offset + limit - 1);
        break;
      } catch (_) {
        response = null;
      }
    }
    if (response == null) {
      throw Exception('Failed to load session messages: check table/columns and RLS');
    }

    final messages = (response as List)
        .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
        .toList();

    // Reverse to get chronological order (oldest first)
    return messages.reversed.toList();
  }

  /// Subscribe to real-time updates for a session
  Stream<List<ChatMessage>> subscribeToSession(String sessionId) {
    final client = _tenantService.tenantClient;
    if (client == null) throw Exception('Tenant client not initialized');

    final controller = StreamController<List<ChatMessage>>();

    _realtimeChannel?.unsubscribe();
    _realtimeChannel = client
        .channel('chat_$sessionId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'n8n_chat_histories',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'session_id',
            value: sessionId,
          ),
          callback: (payload) {
            try {
              final message = ChatMessage.fromJson(payload.newRecord);
              controller.add([message]);
            } catch (e) {
              // Handle error
            }
          },
        )
        .subscribe();

    return controller.stream;
  }

  /// Subscribe to all new messages
  Stream<List<ChatMessage>> subscribeToAllMessages() {
    final client = _tenantService.tenantClient;
    if (client == null) throw Exception('Tenant client not initialized');

    final controller = StreamController<List<ChatMessage>>();

    _realtimeChannel?.unsubscribe();
    _realtimeChannel = client
        .channel('all_chats')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'n8n_chat_histories',
          callback: (payload) {
            try {
              final message = ChatMessage.fromJson(payload.newRecord);
              controller.add([message]);
            } catch (e) {
              // Handle error
            }
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

