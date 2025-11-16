import 'package:flutter/material.dart';
import 'package:healthcare/core/layout/app_drawer.dart';
import 'package:healthcare/core/layout/app_header.dart';
import 'package:healthcare/features/user/user_home_screen/home_screen.dart';
import 'package:healthcare/features/user/user_appointments_screen.dart';
import 'package:healthcare/features/user/user_home_screen/faq_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 0;
  bool _initializedFromArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initializedFromArgs) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is int && arg >= 0 && arg < _screens.length) {
        _currentIndex = arg;
      }
      _initializedFromArgs = true; // ✅ Prevent reapplying on back swipe
    }
  }

  final List<Widget> _screens = const [
    FindDoctor(),
    UserAppointmentsScreen(),
    FAQScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today),
      label: 'Appointments',
    ),
    BottomNavigationBarItem(icon: Icon(Icons.help), label: 'FAQs'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppHeader(subtitle: "Your support for well-being"),
      drawer: const AppDrawer(),
      body: IndexedStack(index: _currentIndex, children: _screens),

      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Container(
          color: theme.colorScheme.primary,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: Colors.transparent,
            selectedItemColor: theme.colorScheme.secondary,
            unselectedItemColor: Colors.white70,
            type: BottomNavigationBarType.fixed,
            items: _navItems,
          ),
        ),
      ),
    );
  }
}
