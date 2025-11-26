import 'package:flutter/material.dart';
import 'core/config/supabase_config.dart';
import 'features/auth/pages/login_page.dart';
import 'features/auth/pages/signup_page.dart';
import 'features/auth/pages/password_reset_page.dart';
import 'features/home/pages/home_page.dart';
import 'features/dashboard/pages/dashboard_page.dart';
import 'features/dashboard/pages/chats_page.dart';
import 'features/dashboard/pages/settings_page.dart';
import 'shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    // If Supabase config fails, app will show error
    debugPrint('Failed to initialize Supabase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AChat',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/password-reset': (context) => const PasswordResetPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/chats': (context) => const ChatsPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // If Supabase failed to initialize (e.g., missing credentials), avoid
    // accessing the auth stream and show the HomePage with a gentle fallback.
    if (!SupabaseConfig.isInitialized) {
      return const HomePage();
    }

    return StreamBuilder(
      stream: SupabaseConfig.centralClient.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final authState = snapshot.data;
        final user = authState?.session?.user;

        if (user != null) {
          // User is logged in, show dashboard
          return const DashboardPage();
        } else {
          // User is not logged in, show home page
          return const HomePage();
        }
      },
    );
  }
}
