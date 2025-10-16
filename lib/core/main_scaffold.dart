import 'package:flutter/material.dart';
import 'package:healthcare/appointments/booking_screen.dart';
import 'package:healthcare/appointments/user_appointments_screen.dart';
import 'package:healthcare/dashboard/faq_screen.dart';
import 'package:healthcare/dashboard/home_screen.dart';
import 'package:healthcare/doctors/chat_screen.dart';
import 'package:healthcare/doctors/videocall_screen.dart';
import 'package:healthcare/user/profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    UserAppointmentsScreen(),
    FAQScreen(),
    VideoCallScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadiusGeometry.horizontal(
          left: Radius.circular(30),
          right: Radius.circular(30),
        ),
        child: Container(
          color: theme.colorScheme.primary,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.transparent,
            selectedItemColor: theme.colorScheme.secondary,
            unselectedItemColor: Colors.white70,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),

              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Bookings',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.help), label: 'FAQs'),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
