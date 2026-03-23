import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_network_image.dart';

// ============================================================
// 💍 SUCCESS STORIES ROW
// Couple photos with quote overlay — horizontal scroll
// ============================================================
class SuccessStoriesRow extends StatelessWidget {
  const SuccessStoriesRow({super.key, required this.stories});
  final List<Map<String, dynamic>> stories;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 162,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          return Container(
            width: 275,
            margin: const EdgeInsets.symmetric(horizontal: 7),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Photo
                  CustomNetworkImage(
                    imageUrl: story['image'],
                    borderRadius: 0,
                  ),

                  // Left-heavy gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.80),
                          Colors.black.withValues(alpha: 0.12),
                        ],
                      ),
                    ),
                  ),

                  // Quote + names
                  Positioned(
                    left: 16, top: 16, bottom: 16, right: 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.format_quote_rounded,
                          color: Colors.white38,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          story['quote'],
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          story['couple'],
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.brandPrimary,
                          ),
                        ),
                        Text(
                          story['since'],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}