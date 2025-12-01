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
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white, size: 28),
        onPressed: () => Scaffold.maybeOf(context)?.openDrawer(),
        constraints: const BoxConstraints(
          minHeight: kToolbarHeight,
          minWidth: kToolbarHeight,
        ),
        padding: EdgeInsets.zero, // ensures full hitbox
      ),
      title: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // ✅ vertically centers text block
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
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
