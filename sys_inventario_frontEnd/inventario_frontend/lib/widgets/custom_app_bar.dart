import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: showBackButton,
      actions: actions,
      backgroundColor: const Color(0xFF667eea),
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 