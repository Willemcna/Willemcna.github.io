import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/organization.dart';

class OrganizationService {
  final SupabaseClient _client = SupabaseConfig.centralClient;

  /// Get all organizations for the current user
  Future<List<Organization>> getUserOrganizations() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _client
        .from('organization_members')
        .select('org_id, organizations(*)')
        .eq('user_id', user.id);

    final organizations = <Organization>[];
    for (final item in response) {
      final orgData = item['organizations'] as Map<String, dynamic>;
      organizations.add(Organization.fromJson(orgData));
    }

    return organizations;
  }

  /// Create a new organization
  Future<Organization> createOrganization(String name, String userId) async {
    final response = await _client
        .from('organizations')
        .insert({'name': name}).select().single();

    final org = Organization.fromJson(response);

    // Add user as owner
    await _client.from('organization_members').insert({
      'org_id': org.id,
      'user_id': userId,
      'role': 'owner',
    });

    return org;
  }
}

