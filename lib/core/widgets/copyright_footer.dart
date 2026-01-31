import 'package:flutter/material.dart';

class CopyrightFooter extends StatelessWidget {
  const CopyrightFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          '© ${DateTime.now().year} CoCircle. All rights reserved.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
