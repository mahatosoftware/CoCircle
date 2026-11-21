import 'package:flutter/material.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../domain/trip_readiness_model.dart';

class TripReadinessCard extends StatelessWidget {
  final TripReadinessModel readiness;
  final VoidCallback? onFixBlockers;

  const TripReadinessCard({
    super.key,
    required this.readiness,
    this.onFixBlockers,
  });

  @override
  Widget build(BuildContext context) {
    final scoreColor = readiness.scoreColor;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Score & Badge
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 54,
                      height: 54,
                      child: CircularProgressIndicator(
                        value: readiness.overallScore / 100,
                        backgroundColor: Colors.grey.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                        strokeWidth: 6,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      '${readiness.overallScore}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'TRIP READINESS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: Colors.grey,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: scoreColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: scoreColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              readiness.scoreBadgeLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: scoreColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        readiness.tripName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Critical Blockers Alert (if any)
            if (readiness.criticalBlockers.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppPallete.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Action Needed Before Departure',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF991B1B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            readiness.criticalBlockers.first,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7F1D1D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onFixBlockers != null)
                      TextButton(
                        onPressed: onFixBlockers,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Fix', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Category Progress Grid
            const Text(
              'Preparation Checklist',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: readiness.categories.map((cat) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(cat.icon, size: 14, color: cat.isReady ? AppPallete.tertiary : Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        cat.statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cat.isReady ? const Color(0xFF065F46) : Colors.grey.shade700,
                        ),
                      ),
                      if (cat.isReady) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.check_circle_rounded, size: 12, color: AppPallete.tertiary),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),

            // Recommended Action Pill
            if (readiness.recommendedActions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, size: 14, color: AppPallete.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      readiness.recommendedActions.first,
                      style: const TextStyle(fontSize: 12, color: AppPallete.primary, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
