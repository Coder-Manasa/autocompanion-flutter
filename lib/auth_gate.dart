import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/auth/auth_page.dart';
import '../screens/home/dashboard_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return session == null
            ? const AuthPage()
            : const DashboardPage();
      },
    );
  }
}
