import 'package:flutter/material.dart';

// ============================================================
// ✨ SHIMMER LOADING GRID
// Skeleton loader for grids and lists while data is fetching.
// Uses a custom sliding gradient — no external shimmer package.
//
// Modes:
//   ShimmerMode.grid → 2-column profile card grid (default)
//   ShimmerMode.list → full-width list tiles (chat, notifications)
//   ShimmerMode.row  → horizontal scrollable row (stories, matches row)
//
// Usage:
//   ShimmerLoadingGrid()                     // default 2-col grid
//   ShimmerLoadingGrid(itemCount: 4)
//   ShimmerLoadingGrid(mode: ShimmerMode.list)
//   ShimmerLoadingGrid(mode: ShimmerMode.row, itemCount: 5)
// ============================================================

enum ShimmerMode { grid, list, row }

class ShimmerLoadingGrid extends StatefulWidget {
  const ShimmerLoadingGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.68,
    this.mode = ShimmerMode.grid,
    this.padding,
  });

  /// Number of skeleton items to show
  final int itemCount;

  /// Columns for grid mode (default: 2)
  final int crossAxisCount;

  /// Height/width ratio for grid cards (default: 0.68 — profile cards)
  final double childAspectRatio;

  /// Layout mode — grid, list, or horizontal row
  final ShimmerMode mode;

  /// Override outer padding
  final EdgeInsets? padding;

  @override
  State<ShimmerLoadingGrid> createState() => _ShimmerLoadingGridState();
}

class _ShimmerLoadingGridState extends State<ShimmerLoadingGrid>
    with SingleTickerProviderStateMixin {

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this)
      ..repeat(
        min: -0.5,
        max: 1.5,
        period: const Duration(milliseconds: 1100),
      );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.mode) {
      ShimmerMode.grid => _buildGrid(),
      ShimmerMode.list => _buildList(),
      ShimmerMode.row  => _buildRow(),
    };
  }

  // ── Grid ──────────────────────────────────────────────────
  Widget _buildGrid() {
    return GridView.builder(
      padding: widget.padding ??
          const EdgeInsets.fromLTRB(16, 8, 16, 80),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        childAspectRatio: widget.childAspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: widget.itemCount,
      itemBuilder: (_, index) => _ProfileCardSkeleton(
        controller: _controller,
        delay: index * 0.08,
      ),
    );
  }

  // ── List ──────────────────────────────────────────────────
  Widget _buildList() {
    return ListView.builder(
      padding: widget.padding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.itemCount,
      itemBuilder: (_, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _ListTileSkeleton(
          controller: _controller,
          delay: index * 0.10,
        ),
      ),
    );
  }

  // ── Horizontal row ────────────────────────────────────────
  Widget _buildRow() {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: widget.padding ??
            const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.itemCount,
        itemBuilder: (_, index) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _RowCardSkeleton(
            controller: _controller,
            delay: index * 0.08,
          ),
        ),
      ),
    );
  }
}


// ══════════════════════════════════════════════════════════
// SKELETON SHAPES
// ══════════════════════════════════════════════════════════

// ── Profile card skeleton (grid mode) ────────────────────────
class _ProfileCardSkeleton extends StatelessWidget {
  const _ProfileCardSkeleton({
    required this.controller,
    this.delay = 0,
  });

  final AnimationController controller;
  final double delay;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photo area
        Expanded(
          child: _ShimmerBox(
            controller: controller,
            delay: delay,
            borderRadius: 20,
          ),
        ),
        const SizedBox(height: 8),
        // Name line
        _ShimmerBox(
          controller: controller,
          delay: delay + 0.04,
          height: 12,
          width: double.infinity,
          borderRadius: 6,
        ),
        const SizedBox(height: 5),
        // City line — shorter
        _ShimmerBox(
          controller: controller,
          delay: delay + 0.08,
          height: 10,
          widthFactor: 0.6,
          borderRadius: 5,
        ),
      ],
    );
  }
}


// ── List tile skeleton (list mode) ───────────────────────────
class _ListTileSkeleton extends StatelessWidget {
  const _ListTileSkeleton({
    required this.controller,
    this.delay = 0,
  });

  final AnimationController controller;
  final double delay;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        _ShimmerBox(
          controller: controller,
          delay: delay,
          width: 52, height: 52,
          borderRadius: 26,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              _ShimmerBox(
                controller: controller,
                delay: delay + 0.04,
                height: 12,
                widthFactor: 0.55,
                borderRadius: 6,
              ),
              const SizedBox(height: 7),
              // Message preview
              _ShimmerBox(
                controller: controller,
                delay: delay + 0.08,
                height: 10,
                width: double.infinity,
                borderRadius: 5,
              ),
              const SizedBox(height: 5),
              _ShimmerBox(
                controller: controller,
                delay: delay + 0.12,
                height: 10,
                widthFactor: 0.40,
                borderRadius: 5,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Time + unread
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _ShimmerBox(
              controller: controller,
              delay: delay + 0.04,
              height: 10, width: 36,
              borderRadius: 5,
            ),
            const SizedBox(height: 8),
            _ShimmerBox(
              controller: controller,
              delay: delay + 0.08,
              height: 18, width: 18,
              borderRadius: 9,
            ),
          ],
        ),
      ],
    );
  }
}


// ── Row card skeleton (horizontal row mode) ───────────────────
class _RowCardSkeleton extends StatelessWidget {
  const _RowCardSkeleton({
    required this.controller,
    this.delay = 0,
  });

  final AnimationController controller;
  final double delay;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ShimmerBox(
          controller: controller,
          delay: delay,
          width: 80, height: 90,
          borderRadius: 18,
        ),
        const SizedBox(height: 6),
        _ShimmerBox(
          controller: controller,
          delay: delay + 0.05,
          height: 9, width: 60,
          borderRadius: 5,
        ),
      ],
    );
  }
}


// ══════════════════════════════════════════════════════════
// CORE SHIMMER BOX
// Single animated shimmer rectangle
// ══════════════════════════════════════════════════════════
class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.controller,
    this.delay = 0,
    this.width,
    this.widthFactor,
    this.height,
    this.borderRadius = 12,
  });

  final AnimationController controller;
  final double delay;
  final double? width;

  /// Width as fraction of parent — use instead of width when dynamic
  final double? widthFactor;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        // Offset shimmer per item for stagger feel
        final value = (controller.value - delay).clamp(-0.5, 1.5);
        return LayoutBuilder(
          builder: (context, constraints) {
            final resolvedWidth = width ??
                (widthFactor != null
                    ? constraints.maxWidth * widthFactor!
                    : constraints.maxWidth);
            return Container(
              width: resolvedWidth,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.grey.shade200,
                    Colors.grey.shade50,
                    Colors.grey.shade200,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  transform: _SlideTransform(value),
                ),
              ),
            );
          },
        );
      },
    );
  }
}


// ── Gradient slide transform ──────────────────────────────────
class _SlideTransform extends GradientTransform {
  const _SlideTransform(this.slidePercent);
  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * slidePercent,
      0.0,
      0.0,
    );
  }
}