import 'package:flutter/material.dart';
import 'package:healthcare/app/app_routes.dart';
import 'package:healthcare/core/layout/app_drawer.dart';
import 'package:healthcare/core/layout/app_header.dart';
import 'package:healthcare/features/doctor/appointments_screen.dart';
import 'package:healthcare/features/doctor/slot_management_screen.dart';
import 'package:healthcare/features/user/dashboard/faq_screen.dart'; // If doctor also needs FAQ

import 'package:flutter/material.dart';
import 'package:healthcare/core/layout/app_drawer.dart';
import 'package:healthcare/core/layout/app_header.dart';
import 'package:healthcare/features/doctor/appointments_screen.dart';
import 'package:healthcare/features/doctor/slot_management_screen.dart';
import 'package:healthcare/features/user/dashboard/faq_screen.dart';
import 'package:healthcare/features/doctor/application_status_screen.dart';
import 'package:healthcare/services/doctor_service.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _currentIndex = 0;

  List<Widget> _screens = [];
  List<BottomNavigationBarItem> _navItems = [];

  bool _loading = true;
  bool _isPending = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final doctorService = DoctorService();

    final res = await doctorService.getApplicationStatus();
    print("APP status $res");

    if (!mounted) return;

    final status = res['success'] == true ? res['data']['status'] : "approved";

    // ------- HANDLE PENDING OR REJECTED -------
    if (status == "pending" || status == "rejected") {
      _isPending = true;

      _screens = const [
        ApplicationStatusScreen(),
        DoctorAppointmentsScreen(),
        DoctorSlotManagementScreen(),
        FAQScreen(),
      ];

      _navItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.info_outline),
          label: "App Status",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          label: 'Appointments',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.more_time), label: 'Slots'),
        BottomNavigationBarItem(icon: Icon(Icons.help), label: 'FAQs'),
      ];
    } else if (status == "not_started") {
      Navigator.pushReplacementNamed(context, AppRoutes.doctorApply);
      return;
    }
    // ------- ALLOW FULL APP AFTER APPROVAL -------
    else {
      _isPending = false;

      _screens = const [
        DoctorAppointmentsScreen(),
        DoctorSlotManagementScreen(),
        FAQScreen(),
      ];

      _navItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          label: 'Appointments',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.more_time), label: 'Slots'),
        BottomNavigationBarItem(icon: Icon(Icons.help), label: 'FAQs'),
      ];
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
            backgroundColor: Colors.transparent,
            selectedItemColor: theme.colorScheme.secondary,
            unselectedItemColor: Colors.white70,
            type: BottomNavigationBarType.fixed,

            // Prevent switching when pending
            onTap: _isPending
                ? null // no navigation allowed
                : (index) => setState(() => _currentIndex = index),

            items: _navItems,
          ),
        ),
      ),
    );
  }
}
