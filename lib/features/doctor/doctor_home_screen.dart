import 'package:flutter/material.dart';
import 'package:healthcare/app/app_routes.dart';
import 'package:healthcare/app/session/session_manager.dart';
import 'package:healthcare/core/layout/app_drawer.dart';
import 'package:healthcare/core/layout/app_header.dart';
import 'package:healthcare/features/doctor/application/application_status_screen.dart';
import 'package:healthcare/features/doctor/doctor_appointments_screen.dart';
import 'package:healthcare/features/doctor/slot_management_screen.dart';
import 'package:healthcare/features/user/faq_screen.dart' show FAQScreen;
import 'package:healthcare/services/doctor_service.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _currentIndex = 0;
  bool _loading = true;
  bool _isPending = false;

  late List<Widget> _screens;
  late List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();
    _initDoctorHome();
  }

  Future<void> _initDoctorHome() async {
    /// 1️⃣ - If doctor already approved previously → show full home
    final isApproved = await SessionManager.isDoctorApproved();

    if (isApproved) {
      _buildUI(isPending: false);
      return;
    }

    /// 2️⃣ - Doctor not approved yet → check application status
    final res = await DoctorService().getApplicationStatus();
    if (!mounted) return;

    final status = res['success'] == true ? res['data']['status'] : "approved";

    /// 3️⃣ - Not started → force start application
    if (status == "not_started") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.doctorApply);
      });
      return;
    }

    /// 4️⃣ - Approved → save approval status permanently
    if (status == "approved") {
      await SessionManager.setDoctorApproved(true);
      _buildUI(isPending: false);
      return;
    }

    /// 5️⃣ - Pending / Rejected → show AppStatusScreen only
    final isPending = status == "pending" || status == "rejected";
    _buildUI(isPending: isPending);
  }

  void _buildUI({required bool isPending}) {
    setState(() {
      _isPending = isPending;
      _screens = [];
      _navItems = [];

      if (_isPending) {
        _screens.add(const ApplicationStatusScreen());
        _navItems.add(
          const BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: "App Status",
          ),
        );
        _currentIndex = 0;
      }

      _screens.addAll([
        const DoctorAppointmentsScreen(),
        const DoctorSlotManagementScreen(),
        const FAQScreen(),
      ]);

      _navItems.addAll([
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          label: 'Appointments',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.more_time),
          label: 'Slots',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.help), label: 'FAQs'),
      ]);

      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: const AppHeader(subtitle: "Your patient care dashboard"),
        drawer: const AppDrawer(),
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).primaryColor,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,

          /// ❗ Disable navigation if pending
          onTap: _isPending
              ? null
              : (i) {
                  setState(() => _currentIndex = i);
                },

          items: _navItems,
        ),
      ),
    );
  }
}
