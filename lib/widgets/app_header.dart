import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final bool centerTitle;
  final double expandedHeight;
  final Color backgroundColor;

  const AppHeader({
    super.key,
    this.centerTitle = true,
    this.expandedHeight = 140,
    this.backgroundColor = const Color(0xFF01312F),
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () {},
      ),
      backgroundColor: backgroundColor,
      pinned: true,
      expandedHeight: expandedHeight,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: centerTitle,
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
    );
  }
}
