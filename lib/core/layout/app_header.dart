import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final bool showBackButton;
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    this.title,
    this.subtitle,
    this.showBackButton = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF01312F),
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: showBackButton,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () {
          // ✅ Open the drawer safely
          Scaffold.maybeOf(context)?.openDrawer();
        },
      ),
      actions: actions,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ?? "Wellness",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      bottom: subtitle != null
          ? PreferredSize(
              preferredSize: Size.fromHeight(20),
              child: Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  subtitle!,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
