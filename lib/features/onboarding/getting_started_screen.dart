import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:healthcare/app/session/session_manager.dart';
import 'package:healthcare/core/utils/navigation_util.dart';

class GettingStartedScreen extends StatelessWidget {
  const GettingStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F2),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            // leading: IconButton(
            //   icon: const Icon(Icons.menu, color: Colors.white),
            //   onPressed: () {},
            // ),
            backgroundColor: theme.colorScheme.primary,
            pinned: true,
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Wellness',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Support for your well-being',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          /// 🧠 Main body content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'Talk to a professional',
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Connect with online experts for assistance',
                    style: TextStyle(fontSize: 20, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    child: GFButton(
                      onPressed: () {
                        navigateSlideLeft(
                          context,
                          routeName: "/language-selection",
                        );
                      },
                      text: 'Get Started',
                      color: theme.colorScheme.secondary,
                      fullWidthButton: false,
                      size: GFSize.LARGE,
                      shape: GFButtonShape.pills,
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          /// 🧩 Grid of Doctor Cards
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 10,
              ),
              delegate: SliverChildListDelegate([
                _buildDoctorCard(
                  title: 'Psychologist',
                  subtitle: 'Support',
                  imageUrl:
                      'https://cdn-icons-png.flaticon.com/512/8734/8734961.png',
                  backgroundColor: const Color(0xFFEFF6FF),
                ),
                _buildDoctorCard(
                  title: 'Physiotherapist',
                  subtitle: 'Recovery',
                  imageUrl:
                      'https://cdn-icons-png.flaticon.com/512/6172/6172724.png',
                  backgroundColor: const Color(0xFFE9F7EF),
                ),
                _buildDoctorCard(
                  title: 'Yoga Teacher',
                  subtitle: 'Diet & Wellness',
                  imageUrl:
                      'https://cdn-icons-png.flaticon.com/512/2647/2647625.png',
                  backgroundColor: const Color.fromARGB(255, 255, 239, 224),
                ),
                _buildDoctorCard(
                  title: 'Nutritionist',
                  subtitle: 'Health Care',
                  imageUrl:
                      'https://cdn-icons-png.flaticon.com/512/13195/13195430.png',
                  backgroundColor: const Color(0xFFF3E5F5),
                ),
                _buildDoctorCard(
                  title: 'Child Caregiver',
                  subtitle: 'Babysitting',
                  imageUrl:
                      'https://cdn-icons-png.flaticon.com/512/2867/2867024.png',
                  backgroundColor: const Color.fromARGB(255, 255, 210, 248),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// 🧠 Reusable Doctor Card
  Widget _buildDoctorCard({
    required String title,
    required String subtitle,
    required String imageUrl,
    required Color backgroundColor,
  }) {
    return GFCard(
      padding: EdgeInsets.all(5),

      color: backgroundColor,
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      content: Column(
        children: [
          GFAvatar(
            backgroundImage: NetworkImage(imageUrl),
            radius: 35,
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            softWrap: true,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
