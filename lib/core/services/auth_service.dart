import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class AuthService {
  final SupabaseClient _client = SupabaseConfig.centralClient;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    // If email confirmation is disabled (dev), a session is returned.
    // If it's enabled, immediately sign in for testing so we have a session.
    if (response.session == null) {
      try {
        await _client.auth.signInWithPassword(email: email, password: password);
      } catch (e) {
        // During testing, if email confirmation is ON in Supabase,
        // sign-in will fail with an "email not confirmed" error.
        // Ignore that specific case so the UI can proceed for testing.
        final message = e.toString().toLowerCase();
        final isEmailNotConfirmed =
            message.contains('email') && message.contains('confirm');
        if (!isEmailNotConfirmed) {
          rethrow;
        }
      }
    }

    final hasSession = _client.auth.currentUser != null || response.session != null;
    final String? uid = _client.auth.currentUser?.id ?? response.user?.id;

    // Only attempt inserts when we have an authenticated session.
    if (hasSession && uid != null) {
      await _createProfile(uid, displayName ?? email.split('@')[0]);
      await _createOrganizationForUser(uid, displayName ?? 'My Organization');
    }

    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> _createProfile(String userId, String displayName) async {
    await _client.from('profiles').insert({
      'user_id': userId,
      'display_name': displayName,
    });
  }

  Future<void> _createOrganizationForUser(String userId, String orgName) async {
    // Create organization
    final orgResponse = await _client.from('organizations').insert({
      'name': orgName,
    }).select().single();

    final orgId = orgResponse['id'] as String;

    // Add user as owner
    await _client.from('organization_members').insert({
      'org_id': orgId,
      'user_id': userId,
      'role': 'owner',
    });
  }
}

