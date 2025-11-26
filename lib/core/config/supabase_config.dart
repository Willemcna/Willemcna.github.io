import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static SupabaseClient? _centralClient;
  
  static Future<void> initialize() async {
    // Prefer dart-define values when provided (recommended for production)
    String supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
    String supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');

    // Fallback to .env (if present). Do not crash if the file is missing on web.
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      try {
        await dotenv.load(fileName: '.env');
      } catch (_) {
        // Ignore: .env might not be bundled; dart-define may be used instead
      }
      supabaseUrl = supabaseUrl.isNotEmpty ? supabaseUrl : (dotenv.env['SUPABASE_URL'] ?? '');
      supabaseAnonKey = supabaseAnonKey.isNotEmpty ? supabaseAnonKey : (dotenv.env['SUPABASE_ANON_KEY'] ?? '');
    }

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      // At this point we could not find credentials from either dart-define or .env.
      // In development, ensure you have a .env file in the project root.
      // In production, pass SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define.
      throw Exception(
        'Supabase credentials missing. '
        'For development, create a .env file with SUPABASE_URL and SUPABASE_ANON_KEY. '
        'For production, pass them via --dart-define=SUPABASE_URL=... and '
        '--dart-define=SUPABASE_ANON_KEY=....',
      );
    }

    // Avoid re-initializing
    if (_centralClient != null) {
      return;
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    _centralClient = Supabase.instance.client;
  }
  
  static SupabaseClient get centralClient {
    if (_centralClient == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _centralClient!;
  }
  
  static bool get isInitialized => _centralClient != null;
  
  static SupabaseClient createTenantClient(String url, String anonKey) {
    return SupabaseClient(url, anonKey);
  }
}

