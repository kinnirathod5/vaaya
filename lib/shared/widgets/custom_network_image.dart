import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

// ============================================================
// 🖼️ CUSTOM NETWORK IMAGE
// Cached image with shimmer loading, retry on error,
// gradient overlay support, and multiple error states.
//
// Packages required:
//   cached_network_image: ^3.x.x
//   shimmer: ^3.x.x
//
// Usage:
//   CustomNetworkImage(imageUrl: url)
//
//   CustomNetworkImage(
//     imageUrl: url,
//     width: 80, height: 80,
//     borderRadius: 14,
//     errorType: ImageErrorType.avatar,
//   )
//
//   CustomNetworkImage(
//     imageUrl: url,
//     showBottomGradient: true,   // for card overlays
//   )
// ============================================================

enum ImageErrorType {
  /// Person icon — for profile photos (default)
  avatar,

  /// Image broken icon — for general images
  image,

  /// Blank grey box — for background / non-critical images
  blank,
}

class CustomNetworkImage extends StatefulWidget {
  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 20.0,
    this.fit = BoxFit.cover,
    this.errorType = ImageErrorType.avatar,
    this.showBottomGradient = false,
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
  });

  /// Remote image URL
  final String imageUrl;

  final double? width;
  final double? height;

  /// Corner radius (default: 20)
  final double borderRadius;

  final BoxFit fit;

  /// What to show when image fails to load
  final ImageErrorType errorType;

  /// Adds a dark gradient at the bottom — useful for card overlays
  final bool showBottomGradient;

  /// Override shimmer base color (default: grey.shade200)
  final Color? shimmerBaseColor;

  /// Override shimmer highlight color (default: grey.shade100)
  final Color? shimmerHighlightColor;

  @override
  State<CustomNetworkImage> createState() => _CustomNetworkImageState();
}

class _CustomNetworkImageState extends State<CustomNetworkImage> {

  // Allows manual retry on error
  int _retryKey = 0;

  void _retry() => setState(() => _retryKey++);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Stack(
        fit: StackFit.passthrough,
        children: [

          // ── Image ──────────────────────────────────
          CachedNetworkImage(
            key: ValueKey('${widget.imageUrl}_$_retryKey'),
            imageUrl: widget.imageUrl,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            placeholder: (context, url) => _ShimmerPlaceholder(
              width: widget.width,
              height: widget.height,
              borderRadius: widget.borderRadius,
              baseColor: widget.shimmerBaseColor ?? Colors.grey.shade200,
              highlightColor:
              widget.shimmerHighlightColor ?? Colors.grey.shade100,
            ),
            errorWidget: (context, url, error) => _ErrorPlaceholder(
              width: widget.width,
              height: widget.height,
              errorType: widget.errorType,
              onRetry: _retry,
            ),
          ),

          // ── Bottom gradient overlay ─────────────────
          if (widget.showBottomGradient)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                height: (widget.height ?? 200) * 0.55,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.65),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}


// ── Shimmer placeholder ───────────────────────────────────────
class _ShimmerPlaceholder extends StatelessWidget {
  const _ShimmerPlaceholder({
    this.width,
    this.height,
    required this.borderRadius,
    required this.baseColor,
    required this.highlightColor,
  });

  final double? width;
  final double? height;
  final double borderRadius;
  final Color baseColor;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}


// ── Error placeholder ─────────────────────────────────────────
class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder({
    this.width,
    this.height,
    required this.errorType,
    required this.onRetry,
  });

  final double? width;
  final double? height;
  final ImageErrorType errorType;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRetry,
      child: Container(
        width: width,
        height: height,
        color: Colors.grey.shade100,
        child: switch (errorType) {
          ImageErrorType.avatar => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_rounded,
                color: Colors.grey.shade300,
                size: _iconSize,
              ),
            ],
          ),
          ImageErrorType.image => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                color: Colors.grey.shade300,
                size: _iconSize,
              ),
              const SizedBox(height: 6),
              Text(
                'Tap to retry',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
          ImageErrorType.blank => const SizedBox.shrink(),
        },
      ),
    );
  }

  double get _iconSize {
    final h = height ?? 80;
    if (h < 60) return 20;
    if (h < 120) return 28;
    return 40;
  }
}