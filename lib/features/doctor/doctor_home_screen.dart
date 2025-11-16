import 'package:flutter/material.dart';
import 'package:healthcare/app/app_routes.dart';
import 'package:healthcare/app/session/reachability_controller.dart';
import 'package:healthcare/core/layout/app_drawer.dart';
import 'package:healthcare/core/layout/app_header.dart';
import 'package:healthcare/core/widgets/offline_banner.dart';
import 'package:healthcare/features/doctor/appointments_screen.dart';
import 'package:healthcare/features/doctor/slot_management_screen.dart';
import 'package:healthcare/features/user/faq_screen.dart'; // If doctor also needs FAQ

import 'package:flutter/material.dart';
import 'package:healthcare/core/layout/app_drawer.dart';
import 'package:healthcare/core/layout/app_header.dart';
import 'package:healthcare/features/doctor/appointments_screen.dart';
import 'package:healthcare/features/doctor/slot_management_screen.dart';
import 'package:healthcare/features/user/faq_screen.dart';
import 'package:healthcare/features/doctor/application/application_status_screen.dart';
import 'package:healthcare/services/doctor_service.dart';
import 'package:provider/provider.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _currentIndex = 0;

  List<Widget> _screens = [
    DoctorAppointmentsScreen(),
    DoctorSlotManagementScreen(),
    FAQScreen(),
  ];
  List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_month_outlined),
      label: 'Appointments',
    ),
    BottomNavigationBarItem(icon: Icon(Icons.more_time), label: 'Slots'),
    BottomNavigationBarItem(icon: Icon(Icons.help), label: 'FAQs'),
  ];

  bool _loading = true;
  bool _isPending = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final isReachable = context
        .read<ReachabilityController>()
        .isServerReachable;

    if (isReachable && _loading) {
      _loadStatus();
    }
  }

  Future<void> _loadStatus() async {
    final doctorService = DoctorService();

    final res = await doctorService.getApplicationStatus();

    if (!mounted) return;
    final status = res['success'] == true ? res['data']['status'] : "approved";

    // ------- HANDLE PENDING OR REJECTED -------
    if (status == "pending" || status == "rejected") {
      _isPending = true;
    } else if (status == "not_started") {
      Navigator.pushReplacementNamed(context, AppRoutes.doctorApply);
      return;
    }
    // ------- ALLOW FULL APP AFTER APPROVAL -------
    else {
      _isPending = false;
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOffline = !context
        .watch<ReachabilityController>()
        .isServerReachable;

    return Scaffold(
      appBar: AppHeader(subtitle: "Your patient care dashboard"),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          if (isOffline) const OfflineBanner(), // ✅ show banner if offline
          Expanded(
            child: IndexedStack(children: _screens, index: _currentIndex),
          ),
        ],
      ),
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
