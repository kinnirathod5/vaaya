import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'onboarding_helpers.dart';

// ============================================================
// 📸 STEP 6 — PHOTO
// City field removed — collected later inside the app.
// Full focus on photo upload with better centered layout.
// ============================================================
class Step6PhotoLocation extends StatelessWidget {
  const Step6PhotoLocation({
    super.key,
    required this.uploaded,
    required this.scanStep,
    required this.firstName,
    required this.onPhotoTap,
  });

  final bool uploaded;
  final int scanStep;
  final String firstName;
  final VoidCallback onPhotoTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // Title
          StepTitle(
            title: firstName.isNotEmpty
                ? 'Last step,\n$firstName!'
                : 'One last step!',
            subtitle: 'Add a profile photo so others can see you.',
          ),
          const SizedBox(height: 32),

          // Photo card — centered, bigger
          Center(
            child: GestureDetector(
              onTap: uploaded ? null : onPhotoTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                width: 180,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: scanStep == 2
                        ? AppTheme.success
                        : uploaded
                        ? Colors.grey.shade300
                        : AppTheme.brandPrimary.withValues(alpha: 0.30),
                    width: scanStep == 2 ? 2.5 : 1.5,
                  ),
                  boxShadow: scanStep == 2
                      ? [BoxShadow(
                    color: AppTheme.success.withValues(alpha: 0.20),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )]
                      : AppTheme.mediumShadow,
                  image: uploaded
                      ? const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=800&q=80',
                    ),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: !uploaded
                      ? _UploadPlaceholder()
                      : scanStep == 1
                      ? _ScanningOverlay()
                      : const _VerifiedBadge(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Status text below photo
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildStatusText(),
          ),
          const SizedBox(height: 32),

          // Info note — city will be added later
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: AppTheme.brandPrimary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.brandPrimary.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: AppTheme.brandPrimary.withValues(alpha: 0.65),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Your city and other details can be filled in after signing up inside the app.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppTheme.brandDark.withValues(alpha: 0.52),
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatusText() {
    if (scanStep == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        key: const ValueKey('verified'),
        children: [
          Icon(Icons.check_circle_rounded,
              size: 15, color: AppTheme.success),
          const SizedBox(width: 6),
          Text(
            'Photo verified — looking great!',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.success,
            ),
          ),
        ],
      );
    }
    if (scanStep == 1) {
      return Text(
        'Verifying your photo...',
        key: const ValueKey('scanning'),
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          color: Colors.grey.shade500,
        ),
      );
    }
    return Text(
      'Tap the card above to upload your photo',
      key: const ValueKey('idle'),
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        color: Colors.grey.shade500,
      ),
    );
  }
}


// ── Upload placeholder ────────────────────────────────────────
class _UploadPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: AppTheme.brandPrimary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_a_photo_rounded,
            color: AppTheme.brandPrimary,
            size: 28,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Upload Photo',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.brandDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap to choose',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}


// ── Scanning overlay ──────────────────────────────────────────
class _ScanningOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.48),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.brandPrimary,
            strokeWidth: 2.5,
          ),
          SizedBox(height: 14),
          Text(
            'Verifying...',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


// ── Verified badge overlay ────────────────────────────────────
class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 12, left: 10, right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.success,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.success.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user_rounded,
                    color: Colors.white, size: 13),
                SizedBox(width: 5),
                Text(
                  'Verified ✓',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}