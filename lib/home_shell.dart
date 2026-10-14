import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';

import 'notes_page.dart';
import 'supabase_client.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _ensureProfile();
  }

  /// Saves the user's name and email in the separate "user" table.
  Future<void> _ensureProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    try {
      await supabase.from('user').upsert({
        'id': user.id,
        'email': user.email,
        'username': user.userMetadata?['full_name'],
      });
    } catch (_) {
      // Ignore. It will be retried on the next login.
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const NotesPage(),
      const ProfilePage(),
    ];

    return AdaptiveScaffold(
      minimizeBehavior: TabBarMinimizeBehavior.automatic,
      bottomNavigationBar: AdaptiveBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          AdaptiveNavigationDestination(
            icon: PlatformInfo.isIOS ? 'house.fill' : CupertinoIcons.house_fill,
            label: 'Home',
          ),
          AdaptiveNavigationDestination(
            icon: PlatformInfo.isIOS ? 'person.fill' : CupertinoIcons.person_fill,
            label: 'Profile',
          ),
        ],
      ),
      body: pages[_selectedIndex],
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final email = supabase.auth.currentUser?.email ?? '';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(email, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          AdaptiveButton(
            onPressed: () {
              supabase.auth.signOut();
            },
            style: AdaptiveButtonStyle.filled,
            label: 'Log out',
          ),
        ],
      ),
    );
  }
}
