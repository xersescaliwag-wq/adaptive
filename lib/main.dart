import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    Center(child: Text('home')),
    Center(child: Text('search')),
    Center(child: Text('post')),
    Center(child: Text('notification')),
    Center(child: Text('profile')),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveApp(
      cupertinoDarkTheme: const CupertinoThemeData(brightness: Brightness.dark),
      home: AdaptiveScaffold(
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
              icon: PlatformInfo.isIOS ? 'magnifyingglass' : CupertinoIcons.search,
              label: 'Search',
            ),
            AdaptiveNavigationDestination(
              icon: PlatformInfo.isIOS ? 'plus.circle.fill' : CupertinoIcons.add_circled_solid,
              label: 'Post',
            ),
            AdaptiveNavigationDestination(
              icon: PlatformInfo.isIOS ? 'bell.fill' : CupertinoIcons.bell_fill,
              label: 'Alerts',
            ),
            AdaptiveNavigationDestination(
              icon: PlatformInfo.isIOS ? 'person.fill' : CupertinoIcons.person_fill,
              label: 'Profile',
            ),
          ],
        ),
        body: _pages[_selectedIndex],
      ),
    );
  }
}