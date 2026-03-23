import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({super.key, required this.stats});
  final Map<String, dynamic> stats;

  @override
  Widget build(BuildContext context) {
    final items = [
      {'label': 'Views',    'value': '${stats['profileViews']}'},
      {'label': 'Sent',     'value': '${stats['interestsSent']}'},
      {'label': 'Received', 'value': '${stats['interestsReceived']}'},
      {'label': 'Matches',  'value': '${stats['matches']}'},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          return Expanded(
            child: Row(
              children: [
                if (i > 0)
                  Container(width: 1, height: 36, color: Colors.grey.shade100),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        items[i]['value']!,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.brandDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i]['label']!,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}