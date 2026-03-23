import 'package:flutter/material.dart';

// ============================================================
// 💭 THOUGHT OF THE DAY
// Warm quote card at the bottom of the home screen
// TODO: Pick randomly from a quotes list
// ============================================================
class ThoughtOfTheDay extends StatelessWidget {
  const ThoughtOfTheDay({super.key});

  static const String _quote =
      '"A successful marriage requires falling in love many times, always with the same person."';
  static const String _author = '— Mignon McLaughlin';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF2E9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8D0B3)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.format_quote_rounded,
              color: Color(0xFFD6A060),
              size: 26,
            ),
            const SizedBox(height: 10),
            Text(
              _quote,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Color(0xFF6B4E2D),
                height: 1.65,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              _author,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9B7450),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Banjara Vivah',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: Color(0xFFB89070),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}