import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingStepHeader extends StatelessWidget {
  const OnboardingStepHeader({
    super.key,
    required this.current,
    required this.total,
    required this.meta,
    required this.onBack,
  });

  final int current;
  final int total;
  final List<Map<String, String>> meta;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppTheme.brandDark, size: 16),
                ),
              ),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: Column(
                  key: ValueKey(current),
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${meta[current]['emoji']}  ${meta[current]['label']}',
                      style: const TextStyle(
                        fontFamily: 'Poppins', fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.brandPrimary,
                      ),
                    ),
                    Text('Step ${current + 1} of $total',
                        style: TextStyle(fontFamily: 'Poppins',
                            fontSize: 11, color: Colors.grey.shade400)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Emoji + bar row
          Row(
            children: List.generate(total, (i) {
              final done    = i < current;
              final active  = i == current;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        width: active ? 28 : 22,
                        height: active ? 28 : 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done
                              ? AppTheme.brandPrimary
                              : active
                              ? AppTheme.brandPrimary.withValues(alpha: 0.10)
                              : Colors.grey.shade100,
                          border: Border.all(
                            color: done || active
                                ? AppTheme.brandPrimary
                                : Colors.grey.shade200,
                            width: active ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: done
                              ? const Icon(Icons.check_rounded,
                              size: 12, color: Colors.white)
                              : Text(meta[i]['emoji']!,
                              style: TextStyle(fontSize: active ? 13 : 10)),
                        ),
                      ),
                      const SizedBox(height: 5),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 380),
                        height: 3,
                        decoration: BoxDecoration(
                          color: done || active
                              ? AppTheme.brandPrimary
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}