import 'package:flutter/material.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int selectedDoctorIndex = 0;

  Map<String, String>? selectedSlot; // { "date": "Wed\n20", "time": "9.00 AM" }

  final List<Map<String, dynamic>> doctors = [
    {
      "name": "Jennifer Kay",
      "role": "Psychologist",
      "icon": Icons.person,
      "rating": 4.7,
      "slots": [
        {
          "date": "Wed\n20",
          "times": ["9.00 AM", "10.30 AM", "4.00 PM", "6.00 PM"],
        },
        {
          "date": "Thu\n21",
          "times": ["8.00 AM", "11.00 AM", "3.00 PM"],
        },
        {
          "date": "Fri\n22",
          "times": ["10.00 AM", "1.00 PM", "5.00 PM"],
        },
        {
          "date": "Fri\n22",
          "times": ["10.00 AM", "1.00 PM", "5.00 PM"],
        },
        {
          "date": "Fri\n22",
          "times": ["10.00 AM", "1.00 PM", "5.00 PM"],
        },
      ],
    },
    {
      "name": "Gary Olson",
      "role": "Therapist",
      "rating": 4.7,
      "icon": Icons.person_outline,
      "slots": [
        {
          "date": "Thu\n21",
          "times": ["10.00 AM", "2.00 PM", "4.00 PM"],
        },
        {
          "date": "Fri\n22",
          "times": ["9.00 AM", "12.00 PM", "3.00 PM", "6.00 PM"],
        },
        {
          "date": "Sat\n23",
          "times": ["8.30 AM", "11.30 AM", "2.30 PM"],
        },
      ],
    },
    {
      "name": "Dr. Mira Patel",
      "role": "Therapist",
      "rating": 4.7,
      "icon": Icons.person_2,
      "slots": [
        {
          "date": "Fri\n22",
          "times": ["11.00 AM", "1.00 PM", "3.00 PM", "5.00 PM"],
        },
        {
          "date": "Sat\n23",
          "times": ["9.00 AM", "12.00 PM", "4.00 PM"],
        },
        {
          "date": "Sun\n24",
          "times": ["10.00 AM", "2.00 PM", "6.00 PM"],
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedDoctor = doctors[selectedDoctorIndex];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF01312F), // dark teal header
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book Session',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(25),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Available Doctors',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ),
      ),

      backgroundColor: const Color(0xFFFFF3E9), // Light peach
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // Sliding Doctor Cards
            SizedBox(
              height: 160,
              child: PageView.builder(
                itemCount: doctors.length,
                controller: PageController(viewportFraction: 0.75),
                onPageChanged: (index) {
                  setState(() {
                    selectedDoctorIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final doctor = doctors[index];
                  return _buildProfileCard(
                    name: doctor["name"],
                    role: doctor["role"],
                    icon: doctor["icon"],
                    rating: doctor["rating"],
                    isSelected: index == selectedDoctorIndex,
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Available Dates",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Scrollable time/date slot list
                  SizedBox(
                    height: 280, // Adjust height as needed
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ...selectedDoctor["slots"].map<Widget>((slot) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDateBox(slot["date"]),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Wrap(
                                      spacing: 12,
                                      runSpacing: 8,
                                      children: List<Widget>.from(
                                        slot["times"].map<Widget>(
                                          (time) =>
                                              _buildTimeBox(slot["date"], time),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Book Now Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedSlot == null
                      ? null
                      : () {
                          // handle booking logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Booked for $selectedSlot')),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Book Now",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStarRating(double rating) {
    const totalStars = 5;
    List<Widget> stars = [];

    for (int i = 0; i < totalStars; i++) {
      if (rating >= i + 1) {
        stars.add(const Icon(Icons.star, color: Colors.orange, size: 16));
      } else if (rating > i && rating < i + 1) {
        stars.add(const Icon(Icons.star_half, color: Colors.orange, size: 16));
      } else {
        stars.add(
          const Icon(Icons.star_border, color: Colors.orange, size: 16),
        );
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...stars,
        const SizedBox(width: 6),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildProfileCard({
    required String name,
    required String role,
    required IconData icon,
    required bool isSelected,
    required double rating,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            width: 50,
            image: NetworkImage(
              "https://cdn-icons-png.flaticon.com/512/8815/8815112.png",
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(role, style: const TextStyle(fontSize: 14, color: Colors.grey)),

          // ⭐ Rating Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.orange[400], size: 16),
              const SizedBox(width: 4),
              buildStarRating(rating),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateBox(String text) {
    final parts = text.split('\n');
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF01312F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            parts[0], // Day
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            parts[1], // Date
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBox(String date, String time) {
    final isSelected =
        selectedSlot?["date"] == date && selectedSlot?["time"] == time;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedSlot = null; // deselect if tapped again
          } else {
            selectedSlot = {"date": date, "time": time};
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B35) : const Color(0xFFFFE0D1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF01312F)
                : const Color(0xFFFF6B35),
            width: 1.5,
          ),
        ),
        child: Text(
          time,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF01312F),
          ),
        ),
      ),
    );
  }
}
