import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:healthcare/auth/screens/doctor_appointment_screen.dart';
import 'package:healthcare/auth/screens/doctor_profile_screen.dart';

class SearchDoctorScreen extends StatefulWidget {
  const SearchDoctorScreen({super.key});

  @override
  State<SearchDoctorScreen> createState() => _SearchDoctorScreenState();
}

class _SearchDoctorScreenState extends State<SearchDoctorScreen> {
  final _searchController = TextEditingController();

  final List<String> categories = [
    'All',
    'Pills',
    'Dentist',
    'Cardiologist',
    'Neurologist',
    'Dermatologist',
    'Physician',
  ];

  String selectedCategory = 'All';

  final List<Map<String, dynamic>> doctors = [
    {
      'name': 'Dr. Anitha Ramesh',
      'speciality': 'Cardiologist',
      'rating': 4.8,
      'image': 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
    },
    {
      'name': 'Dr. Rahul Kumar',
      'speciality': 'Dentist',
      'rating': 4.6,
      'image': 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
    },
    {
      'name': 'Dr. Sneha Patel',
      'speciality': 'Neurologist',
      'rating': 4.9,
      'image': 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
    },
    {
      'name': 'Dr. Anitha Ramesh',
      'speciality': 'Cardiologist',
      'rating': 4.8,
      'image': 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
    },
    {
      'name': 'Dr. Rahul Kumar',
      'speciality': 'Dentist',
      'rating': 4.6,
      'image': 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
    },
    {
      'name': 'Dr. Sneha Patel',
      'speciality': 'Neurologist',
      'rating': 4.9,
      'image': 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Search Doctor'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔍 Search Field
            GFTextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search doctor or specialist...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                // Add search logic if needed
              },
            ),

            const SizedBox(height: 20),

            /// 💊 Categories Row
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category == selectedCategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    child: GFButton(
                      onPressed: () {},
                      text: category,
                      color: isSelected ? theme.primaryColor : GFColors.LIGHT,
                      textColor: isSelected ? Colors.white : Colors.black87,
                      size: GFSize.SMALL,
                      shape: GFButtonShape.pills,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            /// 👩‍⚕️ Doctor List
            Expanded(
              child: ListView.builder(
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doctor = doctors[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GFCard(
                      elevation: 3,
                      color: Colors.white,
                      boxFit: BoxFit.cover,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      content: Row(
                        children: [
                          /// Doctor image
                          GFAvatar(
                            backgroundImage: NetworkImage(doctor['image']),
                            size: 50,
                            shape: GFAvatarShape.circle,
                          ),
                          const SizedBox(width: 16),

                          /// Doctor details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DoctorProfileScreen(
                                          doctorName: "Dr. Priya Mehta",
                                          specialty: "Dermatologist",
                                          experience: "8 Years",
                                          about:
                                              "Dr. Priya Mehta is a highly experienced dermatologist known for her expertise in skin and hair care. She has helped over 5000+ patients regain their confidence.",
                                          imageUrl:
                                              "https://cdn-icons-png.flaticon.com/512/3774/3774299.png",
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    doctor['name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  doctor['speciality'],
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                    Text(
                                      '${doctor['rating']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          /// Book Now button
                          GFButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DoctorAppointmentScreen(
                                    doctorName: "Dr. Sarah Johnson",
                                    specialty: "Cardiologist",
                                    imageUrl:
                                        "https://cdn-icons-png.flaticon.com/512/3774/3774299.png",
                                  ),
                                ),
                              );
                              GFToast.showToast(
                                'Booking ${doctor['name']}...',
                                context,
                                toastPosition: GFToastPosition.CENTER,
                              );
                            },
                            text: 'Book',
                            color: theme.colorScheme.secondary,
                            shape: GFButtonShape.pills,
                            size: GFSize.SMALL,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
