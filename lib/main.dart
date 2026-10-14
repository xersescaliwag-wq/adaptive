import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show Supabase, AuthState;

import 'home_shell.dart';
import 'login_screen.dart';
import 'supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveApp(
      cupertinoDarkTheme: const CupertinoThemeData(brightness: Brightness.dark),
      // Rebuilds on login / logout, so no manual navigation is needed.
      home: StreamBuilder<AuthState>(
        stream: supabase.auth.onAuthStateChange,
        builder: (context, _) {
          return supabase.auth.currentSession == null
              ? const LoginScreen()
              : const HomeShell();
        },
      ),
    );
  }
}
