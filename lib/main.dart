import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'screens/auth/auth_page.dart';
import 'screens/home/dashboard_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Supabase
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
    final initialSession =
        Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      title: "AutoCompanion",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050509),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),

      // ✅ FIXED: no infinite loading
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        initialData: AuthState(
          AuthChangeEvent.initialSession,
          initialSession,
        ),
        builder: (context, snapshot) {
          final session = snapshot.data?.session;

          return session == null
              ? const AuthPage()
              : const DashboardPage();
        },
      ),
    );
  }
}
