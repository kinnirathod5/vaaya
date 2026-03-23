import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.user,
    required this.onEditTap,
    required this.onUpgradeTap,
  });

  final Map<String, dynamic> user;
  final VoidCallback onEditTap;
  final VoidCallback onUpgradeTap;

  @override
  Widget build(BuildContext context) {
    final bool isPremium  = user['isPremium']  as bool;
    final bool isVerified = user['isVerified'] as bool;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${user['name']}, ${user['age']}',
                          style: const TextStyle(
                            fontFamily: 'Cormorant Garamond',
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.brandDark,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded,
                              color: Color(0xFF2563EB), size: 18),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 13, color: Colors.grey.shade400),
                        const SizedBox(width: 3),
                        Text(
                          user['city'],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.work_outline_rounded,
                            size: 13, color: Colors.grey.shade400),
                        const SizedBox(width: 3),
                        Text(
                          user['profession'],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Member since
                    Text(
                      'Member since ${user['memberSince']}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Edit button
              GestureDetector(
                onTap: onEditTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.brandPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.brandPrimary.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.edit_rounded,
                          size: 14, color: AppTheme.brandPrimary),
                      const SizedBox(width: 5),
                      const Text(
                        'Edit',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.brandPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Premium nudge (if not premium)
          if (!isPremium) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: onUpgradeTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A0814), Color(0xFF2D1020)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.30),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.diamond_rounded,
                        color: Color(0xFFFFD700), size: 16),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Upgrade to Premium — unlock contact numbers & more',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: const Color(0xFFFFD700).withValues(alpha: 0.70)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}


// ════════════════════════════════════════════════════════════
// profile_completion_bar.dart
// Shows profile completion % with a CTA to complete it
// ════════════════════════════════════════════════════════════