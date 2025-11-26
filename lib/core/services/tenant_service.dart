import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/tenant_connection.dart';

class TenantService {
  final SupabaseClient _centralClient = SupabaseConfig.centralClient;
  static SupabaseClient? _tenantClient;

  SupabaseClient? get tenantClient => _tenantClient;

  /// Get tenant connection for an organization
  Future<TenantConnection?> getTenantConnection(String orgId) async {
    try {
      final response = await _centralClient
          .from('tenant_connections')
          .select()
          .eq('org_id', orgId)
          .maybeSingle();

      if (response == null) return null;

      return TenantConnection.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch tenant connection: $e');
    }
  }

  /// Save or update tenant connection
  Future<void> saveTenantConnection({
    required String orgId,
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    final user = _centralClient.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Check if connection exists
    final existing = await _centralClient
        .from('tenant_connections')
        .select()
        .eq('org_id', orgId)
        .maybeSingle();

    if (existing != null) {
      // Update existing
      await _centralClient
          .from('tenant_connections')
          .update({
            'supabase_url': supabaseUrl,
            'supabase_anon_key': supabaseAnonKey,
          })
          .eq('org_id', orgId);
    } else {
      // Create new
      await _centralClient.from('tenant_connections').insert({
        'org_id': orgId,
        'supabase_url': supabaseUrl,
        'supabase_anon_key': supabaseAnonKey,
        'created_by': user.id,
      });
    }

    // Initialize tenant client
    await initializeTenantClient(orgId);
  }

  /// Initialize tenant client for an organization
  Future<void> initializeTenantClient(String orgId) async {
    final connection = await getTenantConnection(orgId);
    if (connection == null) {
      _tenantClient = null;
      return;
    }

    _tenantClient = SupabaseConfig.createTenantClient(
      connection.supabaseUrl,
      connection.supabaseAnonKey,
    );

    // Validate connection by making a test query
    try {
      await _tenantClient!.from('n8n_chat_histories').select().limit(1);
    } catch (e) {
      _tenantClient = null;
      throw Exception('Invalid Supabase connection: $e');
    }
  }

  /// Clear tenant client
  void clearTenantClient() {
    _tenantClient = null;
  }
}

