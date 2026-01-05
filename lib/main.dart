import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'screens/auth/auth_page.dart';
import 'screens/home/dashboard_page.dart';
import 'screens/modules/document_storage_page.dart';
import 'screens/modules/service_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: "https://ourzibbffztjnmswberx.supabase.co",
    anonKey: "sb_publishable_iedxxeo6yzX0ox8-SmjYzg_h3Lbt-vU",
  );

  runApp(const AutoCompanionApp());
}

class AutoCompanionApp extends StatelessWidget {
  const AutoCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "AutoCompanion",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050509),
      ),

      // 🔥 ROUTES (THIS FIXES EVERYTHING)
      routes: {
        '/': (_) => const AuthGate(),
        '/dashboard': (_) => const DashboardPage(),
        '/documents': (_) => const DocumentStoragePage(),
        '/service': (_) => const ServicePage(),
      },

      initialRoute: '/',
    );
  }
}

// ================= AUTH GATE =================
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      initialData: AuthState(
        AuthChangeEvent.initialSession,
        Supabase.instance.client.auth.currentSession,
      ),
      builder: (context, snapshot) {
        final session = snapshot.data?.session;

        if (session == null) {
          return const AuthPage();
        }

        // ✅ PUSH REPLACEMENT (NOT rebuild)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        });

        return const SizedBox.shrink();
      },
    );
  }
}
