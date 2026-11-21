import 'package:flutter/material.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../core/widgets/app_buttons.dart';

class LocationSharingPrivacySheet extends StatefulWidget {
  final bool initialIsSharing;
  final ValueChanged<bool> onToggleSharing;

  const LocationSharingPrivacySheet({
    super.key,
    required this.initialIsSharing,
    required this.onToggleSharing,
  });

  static Future<void> show(
    BuildContext context, {
    required bool initialIsSharing,
    required ValueChanged<bool> onToggleSharing,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => LocationSharingPrivacySheet(
        initialIsSharing: initialIsSharing,
        onToggleSharing: onToggleSharing,
      ),
    );
  }

  @override
  State<LocationSharingPrivacySheet> createState() => _LocationSharingPrivacySheetState();
}

class _LocationSharingPrivacySheetState extends State<LocationSharingPrivacySheet> {
  late bool _isSharing;
  String _visibility = 'Trip members only';
  String _shareUntil = 'Today, 11:59 PM';

  @override
  void initState() {
    super.initState();
    _isSharing = widget.initialIsSharing;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Location Sharing',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: isDark ? Colors.white : AppPallete.navy,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Intro text
            Text(
              'Share your live location with trip members to travel together and stay in sync.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : AppPallete.gray,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // Share My Location Toggle Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppPallete.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Share My Location',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppPallete.navy,
                    ),
                  ),
                  Switch.adaptive(
                    value: _isSharing,
                    activeColor: AppPallete.indigo,
                    onChanged: (val) {
                      setState(() => _isSharing = val);
                      widget.onToggleSharing(val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Visible To Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppPallete.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Visible To', style: TextStyle(fontWeight: FontWeight.w600)),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _visibility,
                      items: const [
                        DropdownMenuItem(
                          value: 'Trip members only',
                          child: Text('Trip members only'),
                        ),
                        DropdownMenuItem(
                          value: 'Circle admins only',
                          child: Text('Circle admins only'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _visibility = val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Share Until Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppPallete.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Share Until', style: TextStyle(fontWeight: FontWeight.w600)),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _shareUntil,
                      items: const [
                        DropdownMenuItem(
                          value: 'Today, 11:59 PM',
                          child: Text('Today, 11:59 PM'),
                        ),
                        DropdownMenuItem(
                          value: 'For 2 hours',
                          child: Text('For 2 hours'),
                        ),
                        DropdownMenuItem(
                          value: 'Trip Completion',
                          child: Text('Trip Completion'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _shareUntil = val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Privacy by Design Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, color: AppPallete.teal, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Privacy',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppPallete.navy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '• Voluntary and can be turned off anytime.\n'
                          '• Only visible to this trip\'s members.\n'
                          '• Auto-stops when the trip ends.',
                          style: TextStyle(fontSize: 12, height: 1.5, color: AppPallete.gray),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            PrimaryButton(
              label: 'Done',
              onPressed: () => Navigator.pop(context),
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
