import 'package:flutter/material.dart';
import 'package:healthcare/app/app_routes.dart';
import 'package:healthcare/core/layout/app_drawer.dart';
import 'package:healthcare/core/layout/app_header.dart';
import 'package:healthcare/features/doctor/application/application_status_screen.dart';
import 'package:healthcare/features/doctor/doctor_appointments_screen.dart';
import 'package:healthcare/features/doctor/slot_management_screen.dart';
import 'package:healthcare/features/user/faq_screen.dart';
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
    final doctorService = DoctorService();

    final res = await doctorService.getApplicationStatus();
    if (!mounted) return;

    final status = res['success'] == true ? res['data']['status'] : "approved";

    if (status == "not_started") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.doctorApply);
      });
      return;
    }

    setState(() {
      _isPending = status == "pending" || status == "rejected";

      _screens = [];
      _navItems = [];

      if (_isPending) {
        _screens.add(const ApplicationStatusScreen());
        _navItems.add(
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'App Status',
          ),
        );
        _currentIndex = 0; // start on App Status tab
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
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return false; // prevent exiting
        }
        return true; // allow exit
      },
      child: Scaffold(
        appBar: const AppHeader(subtitle: "Your patient care dashboard"),
        drawer: const AppDrawer(),
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: theme.colorScheme.secondary,
            unselectedItemColor: Colors.white70,
            backgroundColor: theme.colorScheme.primary,
            onTap: _isPending
                ? null // prevent switching if pending
                : (index) {
                    setState(() => _currentIndex = index);
                  },
            items: _navItems,
          ),
        ),
      ),
    );
  }
}
