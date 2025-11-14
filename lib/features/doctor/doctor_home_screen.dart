import 'package:flutter/material.dart';
import 'package:healthcare/core/layout/app_drawer.dart';
import 'package:healthcare/core/layout/app_header.dart';
import 'package:healthcare/features/doctor/appointments/appointments_screen.dart';
import 'package:healthcare/features/doctor/slot_management_screen.dart';
import 'package:healthcare/features/user/dashboard/faq_screen.dart'; // If doctor also needs FAQ

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DoctorAppointmentsScreen(),
    DoctorSlotManagementScreen(),
    FAQScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_month_outlined),
      label: 'Appointments',
    ),
    BottomNavigationBarItem(icon: Icon(Icons.more_time), label: 'Slots'),
    BottomNavigationBarItem(icon: Icon(Icons.help), label: 'FAQs'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppHeader(subtitle: "Your patient care dashboard"),
      drawer: const AppDrawer(),
      body: IndexedStack(children: _screens, index: _currentIndex),
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
