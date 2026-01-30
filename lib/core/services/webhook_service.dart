import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class WebhookService {
  final SupabaseClient _centralClient = SupabaseConfig.centralClient;

  /// Get webhook URL for an organization
  /// Uses 'chat_toggle' as the webhook_key
  Future<String?> getWebhookUrl(String orgId) async {
    try {
      final response = await _centralClient
          .from('org_webhooks')
          .select()
          .eq('org_id', orgId)
          .eq('webhook_key', 'chat_toggle')
          .maybeSingle();

      if (response == null) return null;
      return response['webhook_url'] as String?;
    } catch (e) {
      throw Exception('Failed to fetch webhook URL: $e');
    }
  }

  /// Get message webhook URL for an organization
  /// Uses 'message_send' as the webhook_key
  Future<String?> getMessageWebhookUrl(String orgId) async {
    try {
      final response = await _centralClient
          .from('org_webhooks')
          .select()
          .eq('org_id', orgId)
          .eq('webhook_key', 'message_send')
          .maybeSingle();

      if (response == null) return null;
      return response['webhook_url'] as String?;
    } catch (e) {
      throw Exception('Failed to fetch message webhook URL: $e');
    }
  }

  /// Save or update webhook URL for an organization
  Future<void> saveWebhookUrl({
    required String orgId,
    required String webhookUrl,
  }) async {
    final user = _centralClient.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Check if webhook exists
    final existing = await _centralClient
        .from('org_webhooks')
        .select()
        .eq('org_id', orgId)
        .eq('webhook_key', 'chat_toggle')
        .maybeSingle();

    if (existing != null) {
      // Update existing
      await _centralClient
          .from('org_webhooks')
          .update({'webhook_url': webhookUrl})
          .eq('org_id', orgId)
          .eq('webhook_key', 'chat_toggle');
    } else {
      // Create new
      await _centralClient.from('org_webhooks').insert({
        'org_id': orgId,
        'webhook_key': 'chat_toggle',
        'webhook_url': webhookUrl,
      });
    }
  }

  /// Save or update message webhook URL for an organization
  Future<void> saveMessageWebhookUrl({
    required String orgId,
    required String webhookUrl,
  }) async {
    final user = _centralClient.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Check if webhook exists
    final existing = await _centralClient
        .from('org_webhooks')
        .select()
        .eq('org_id', orgId)
        .eq('webhook_key', 'message_send')
        .maybeSingle();

    if (existing != null) {
      // Update existing
      await _centralClient
          .from('org_webhooks')
          .update({'webhook_url': webhookUrl})
          .eq('org_id', orgId)
          .eq('webhook_key', 'message_send');
    } else {
      // Create new
      await _centralClient.from('org_webhooks').insert({
        'org_id': orgId,
        'webhook_key': 'message_send',
        'webhook_url': webhookUrl,
      });
    }
  }

  /// Send webhook when chat is toggled
  Future<void> sendChatToggleWebhook({
    required String orgId,
    required String sessionId,
    required bool isOn,
    String? message,
  }) async {
    try {
      final webhookUrl = await getWebhookUrl(orgId);
      if (webhookUrl == null || webhookUrl.isEmpty) {
        // No webhook configured, silently skip
        return;
      }

      final payload = isOn
          ? {'number': sessionId, 'state': 'on', 'bucket': 'General'}
          : {'number': sessionId, 'state': 'off'};

      final response = await http
          .post(
            Uri.parse(webhookUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Webhook request timeout');
            },
          );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Webhook request failed with status ${response.statusCode}',
        );
      }
    } catch (e) {
      // Log error but don't throw - webhook failures shouldn't break the app
      print('Webhook error: $e');
      // Don't rethrow - let the caller decide if they want to show an error
    }
  }

  /// Send webhook when a message is sent
  Future<void> sendMessageWebhook({
    required String orgId,
    required String sessionId,
    required String message,
  }) async {
    try {
      final webhookUrl = await getMessageWebhookUrl(orgId);
      if (webhookUrl == null || webhookUrl.isEmpty) {
        // No webhook configured, silently skip
        return;
      }

      final payload = {'session_id': sessionId, 'message': message};

      final response = await http
          .post(
            Uri.parse(webhookUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Webhook request timeout');
            },
          );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Webhook request failed with status ${response.statusCode}',
        );
      }
    } catch (e) {
      // Log error but don't throw - webhook failures shouldn't break the app
      print('Message webhook error: $e');
      // Don't rethrow - let the caller decide if they want to show an error
    }
  }
}
