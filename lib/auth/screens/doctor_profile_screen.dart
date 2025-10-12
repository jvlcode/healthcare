import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'doctor_appointment_screen.dart';

class DoctorProfileScreen extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final String about;
  final String experience;
  final String imageUrl;

  const DoctorProfileScreen({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.about,
    required this.experience,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GFAppBar(
        title: Text("Doctor Profile"),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Doctor Card
            GFCard(
              padding: const EdgeInsets.all(16),
              content: Column(
                children: [
                  GFAvatar(
                    backgroundImage: NetworkImage(imageUrl),
                    size: GFSize.LARGE * 2,
                    shape: GFAvatarShape.circle,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    doctorName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    specialty,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      Icon(Icons.star_half, color: Colors.amber, size: 20),
                      Icon(Icons.star_border, color: Colors.amber, size: 20),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("Experience:  $experience"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // About Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "About Doctor",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(about, style: const TextStyle(fontSize: 15, height: 1.4)),
            const SizedBox(height: 20),

            // Contact Info
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Clinic Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.location_on_outlined, color: Colors.grey),
                SizedBox(width: 6),
                Text("Medicare Clinic, Anna Nagar, Chennai"),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.phone, color: Colors.grey),
                SizedBox(width: 6),
                Text("+91 98765 43210"),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.access_time, color: Colors.grey),
                SizedBox(width: 6),
                Text("Mon - Sat, 10:00 AM - 6:00 PM"),
              ],
            ),
            const SizedBox(height: 30),

            // Book Appointment Button
            GFButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorAppointmentScreen(
                      doctorName: doctorName,
                      specialty: specialty,
                      imageUrl: imageUrl,
                    ),
                  ),
                );
              },
              text: "Book Appointment",
              fullWidthButton: true,
              color: Theme.of(context).primaryColor,
              size: GFSize.LARGE,
              shape: GFButtonShape.pills,
            ),
          ],
        ),
      ),
    );
  }
}
