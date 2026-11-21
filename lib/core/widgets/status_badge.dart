import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const StatusBadge({
    super.key,
    required this.label,
    this.icon,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });

  factory StatusBadge.success({required String label, IconData? icon}) {
    return StatusBadge(
      label: label,
      icon: icon ?? Icons.check_circle_rounded,
      backgroundColor: const Color(0xFFD1FAE5),
      textColor: const Color(0xFF065F46),
      borderColor: const Color(0xFFA7F3D0),
    );
  }

  factory StatusBadge.warning({required String label, IconData? icon}) {
    return StatusBadge(
      label: label,
      icon: icon ?? Icons.schedule_rounded,
      backgroundColor: const Color(0xFFFEF3C7),
      textColor: const Color(0xFF92400E),
      borderColor: const Color(0xFFFDE68A),
    );
  }

  factory StatusBadge.danger({required String label, IconData? icon}) {
    return StatusBadge(
      label: label,
      icon: icon ?? Icons.warning_amber_rounded,
      backgroundColor: const Color(0xFFFEE2E2),
      textColor: const Color(0xFF991B1B),
      borderColor: const Color(0xFFFECACA),
    );
  }

  factory StatusBadge.neutral({required String label, IconData? icon}) {
    return StatusBadge(
      label: label,
      icon: icon,
      backgroundColor: const Color(0xFFF1F5F9),
      textColor: const Color(0xFF475569),
      borderColor: const Color(0xFFE2E8F0),
    );
  }

  factory StatusBadge.primary({required String label, IconData? icon}) {
    return StatusBadge(
      label: label,
      icon: icon,
      backgroundColor: const Color(0xFFEEF2FF),
      textColor: const Color(0xFF4338CA),
      borderColor: const Color(0xFFC7D2FE),
    );
  }

  factory StatusBadge.fromTripStatus(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return const StatusBadge(
          label: 'Ongoing',
          backgroundColor: Color(0xFFD1FAE5),
          textColor: Color(0xFF065F46),
          borderColor: Color(0xFFA7F3D0),
        );
      case 'planning':
        return const StatusBadge(
          label: 'Planning',
          backgroundColor: Color(0xFFEEF2FF),
          textColor: Color(0xFF4338CA),
          borderColor: Color(0xFFC7D2FE),
        );
      case 'confirmed':
        return const StatusBadge(
          label: 'Confirmed',
          backgroundColor: Color(0xFFCCFBF1),
          textColor: Color(0xFF0F766E),
          borderColor: Color(0xFF99F6E4),
        );
      case 'upcoming':
        return const StatusBadge(
          label: 'Upcoming',
          backgroundColor: Color(0xFFE0F2FE),
          textColor: Color(0xFF0369A1),
          borderColor: Color(0xFFBAE6FD),
        );
      case 'settling':
        return const StatusBadge(
          label: 'Settling',
          backgroundColor: Color(0xFFFEF3C7),
          textColor: Color(0xFF92400E),
          borderColor: Color(0xFFFDE68A),
        );
      case 'closed':
      case 'completed':
        return const StatusBadge(
          label: 'Closed',
          backgroundColor: Color(0xFFF1F5F9),
          textColor: Color(0xFF475569),
          borderColor: Color(0xFFCBD5E1),
        );
      case 'cancelled':
        return const StatusBadge(
          label: 'Cancelled',
          backgroundColor: Color(0xFFFEE2E2),
          textColor: Color(0xFF991B1B),
          borderColor: Color(0xFFFECACA),
        );
      case 'draft':
      default:
        return const StatusBadge(
          label: 'Draft',
          backgroundColor: Color(0xFFF3F4F6),
          textColor: Color(0xFF6B7280),
          borderColor: Color(0xFFE5E7EB),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(99),
        border: borderColor != null ? Border.all(color: borderColor!, width: 1) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
