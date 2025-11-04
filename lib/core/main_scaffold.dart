import 'package:flutter/material.dart';
import 'package:healthcare/core/app_drawer.dart';
import 'package:healthcare/core/app_header.dart';
import 'package:healthcare/features/doctor/appointments/appointments_screen.dart';
import 'package:healthcare/features/doctor/slot_management_screen.dart';

// --- User feature imports
import 'package:healthcare/features/user/dashboard/home_screen.dart';
import 'package:healthcare/features/user/appointments/appointments_screen.dart';
import 'package:healthcare/features/user/dashboard/faq_screen.dart';
import 'package:healthcare/features/user/doctors/videocall_screen.dart';

// --- Doctor feature imports
import 'package:healthcare/features/doctor/appointments/appointments_screen.dart';
// You can later create these screens for doctor dashboard/chat etc.

class MainScaffold extends StatefulWidget {
  final bool isDoctorMode; // 'user' or 'doctor'

  const MainScaffold({super.key, required this.isDoctorMode});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  bool _initialized = false;

  late List<Widget> _screens;
  late List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();

    // Configure screens & bottom nav based on role
    if (widget.isDoctorMode) {
      _screens = const [
        DoctorAppointmentsScreen(),
        DoctorSlotManagementScreen(),
        FAQScreen(),
      ];

      _navItems = const [
        // BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          label: 'Appointments',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.more_time), label: 'Slots'),
        BottomNavigationBarItem(icon: Icon(Icons.help), label: 'FAQs'),
      ];
    } else {
      _screens = const [HomeScreen(), AppointmentsScreen(), FAQScreen()];

      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Appointments',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.help), label: 'FAQs'),
      ];
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        _currentIndex = args;
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppHeader(
        subtitle: widget.isDoctorMode
            ? "Your patient care dashboard"
            : "Your support for well-being",
      ),
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
            onTap: (index) {
              setState(() => _currentIndex = index);
            },
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
