import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDEFEF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF002B25),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.orange.shade100,
              backgroundImage: const AssetImage('assets/images/avatar.png'),
            ),
            const SizedBox(height: 15),
            // Name & Role
            const Text(
              "Dr. Yuki Tanaka",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Psychologist",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            // Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "4.8",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 4),
                Icon(Icons.star, color: Colors.orange, size: 20),
                Icon(Icons.star, color: Colors.orange, size: 20),
                Icon(Icons.star, color: Colors.orange, size: 20),
                Icon(Icons.star, color: Colors.orange, size: 20),
                Icon(Icons.star, color: Colors.orange, size: 20),
              ],
            ),
            const SizedBox(height: 20),
            // Details
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Specialties: Anxiety, Stress",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 5),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Experience: 10+ years",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Empowering clients to achieve mental wellness through evidence-based therapy.",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 25),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "How was your experience?",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            // Feedback Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.star, color: Colors.orange, size: 40),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
