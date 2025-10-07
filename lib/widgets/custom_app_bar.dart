import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color? background;
  final List<Widget>? actions;

  const CustomAppBar({super.key, required this.title, this.background, this.actions});

  @override
  Widget build(BuildContext context) {
    // Dark Primary #0D1B2A
    return AppBar(
      backgroundColor: background ?? const Color(0xFF0D1B2A),
      elevation: 3,
      centerTitle: true,
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}