import 'package:flutter/material.dart';
import 'package:healthcare/core/layout/app_drawer.dart';
import 'package:healthcare/core/layout/app_header.dart';
import 'package:healthcare/features/user/dashboard/home_screen.dart';
import 'package:healthcare/features/user/appointments/appointments_screen.dart';
import 'package:healthcare/features/user/dashboard/faq_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    AppointmentsScreen(),
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
      body: _screens[_currentIndex],
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
