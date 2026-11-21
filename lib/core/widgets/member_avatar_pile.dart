import 'package:flutter/material.dart';

class MemberAvatarPile extends StatelessWidget {
  final List<String> memberNames;
  final List<String?>? photoUrls;
  final int maxVisible;
  final double radius;
  final VoidCallback? onTap;

  const MemberAvatarPile({
    super.key,
    required this.memberNames,
    this.photoUrls,
    this.maxVisible = 4,
    this.radius = 14,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (memberNames.isEmpty) return const SizedBox.shrink();

    final visibleCount = memberNames.length > maxVisible ? maxVisible : memberNames.length;
    final remainingCount = memberNames.length - visibleCount;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: radius * 2 + 4,
        width: (visibleCount * radius * 1.3) + (remainingCount > 0 ? radius * 2 : radius * 0.7),
        child: Stack(
          children: [
            for (int i = 0; i < visibleCount; i++)
              Positioned(
                left: i * (radius * 1.3),
                child: Container(
                  padding: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: radius,
                    backgroundImage: photoUrls != null &&
                            i < photoUrls!.length &&
                            photoUrls![i] != null &&
                            photoUrls![i]!.isNotEmpty
                        ? NetworkImage(photoUrls![i]!)
                        : null,
                    backgroundColor: Colors.primaries[i % Colors.primaries.length].shade100,
                    child: photoUrls == null ||
                            i >= photoUrls!.length ||
                            photoUrls![i] == null ||
                            photoUrls![i]!.isEmpty
                        ? Text(
                            memberNames[i].isNotEmpty ? memberNames[i][0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: radius * 0.8,
                              fontWeight: FontWeight.bold,
                              color: Colors.primaries[i % Colors.primaries.length].shade800,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            if (remainingCount > 0)
              Positioned(
                left: visibleCount * (radius * 1.3),
                child: Container(
                  padding: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: radius,
                    backgroundColor: Colors.grey.shade200,
                    child: Text(
                      '+$remainingCount',
                      style: TextStyle(
                        fontSize: radius * 0.75,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
