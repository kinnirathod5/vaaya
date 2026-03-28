import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'custom_network_image.dart';

// ============================================================
// 👤 PREMIUM AVATAR — v3.0
//
// WHAT CHANGED vs v2:
//   ✅ FIX 1 — Online dot: dynamic size* removed
//              Now FIXED 10px always, 2px white border always
//              Was: size*0.27 → 50px avatar = 13.5px dot (too big!)
//              Now: always 10px — same on every screen
//   ✅ FIX 2 — Story ring: dynamic size* padding removed
//              Was: ringWidth=size*0.06, ringGap=size*0.04
//              Now: FIXED 3px ring + 2px gap (token-based)
//   ✅ FIX 3 — showRing: false (seen) state added
//              isNew param controls gradient vs grey ring
//              Chat stories and Active Now both use same ring
//   ✅ FIX 4 — NEW: StoryAvatar widget (replaces ALL inline story
//              implementations in Home + Chat List)
//   ✅ FIX 5 — NEW: ConversationAvatar widget (replaces inline
//              avatar+badge+dot in Chat List tiles)
//
// ── DESIGN TOKENS (single source of truth) ────────────────
//   Online dot size   : 10px fixed
//   Online dot border : 2px white
//   Story ring width  : 3px
//   Story ring gap    : 2px (white gap between ring & photo)
//   Story size        : 56px (standard across app)
//   Convo avatar size : 54px (chat list tiles)
//
// ── USAGE ─────────────────────────────────────────────────
//
//   // Basic avatar (no ring, no dot)
//   PremiumAvatar(imageUrl: url, size: 44)
//
//   // With online dot
//   PremiumAvatar(imageUrl: url, size: 44, isOnline: true)
//
//   // With premium badge
//   PremiumAvatar(imageUrl: url, size: 44, isPremium: true)
//
//   // Story ring (Active Now + Chat Stories)
//   StoryAvatar(
//     imageUrl: url,
//     name: 'Priya',
//     isNew: true,          // gradient ring
//     onTap: () => ...,
//   )
//
//   // Chat list conversation tile avatar
//   ConversationAvatar(
//     imageUrl: url,
//     isOnline: true,
//     isPremium: false,
//   )
// ============================================================

// ── Fixed design tokens ───────────────────────────────────────
class _AvatarTokens {
  _AvatarTokens._();

  // Online dot
  static const double dotSize   = 10.0;
  static const double dotBorder = 2.0;
  static const Color  dotColor  = Color(0xFF4ADE80);

  // Story ring
  static const double storyRingWidth = 3.0;
  static const double storyRingGap   = 2.0;
  static const double storySize      = 56.0;  // standard story avatar size
  static const double storyNameFontSize = 10.0;

  // Conversation tile avatar
  static const double convoSize   = 54.0;
  static const double convoBadge  = 18.0;
  static const double convoRadius = 18.0;
}

// ═════════════════════════════════════════════════════════════
// PREMIUM AVATAR — core widget
// ═════════════════════════════════════════════════════════════
class PremiumAvatar extends StatelessWidget {
  const PremiumAvatar({
    super.key,
    required this.imageUrl,
    this.size      = 50,
    this.isOnline  = false,
    this.isPremium = false,
    this.showRing  = false,
    this.isNew     = true,   // ring state: true=gradient, false=grey
    this.initials,
    this.ringColor,
  });

  final String  imageUrl;
  final double  size;
  final bool    isOnline;
  final bool    isPremium;

  /// Show story-style ring around avatar
  final bool showRing;

  /// When showRing=true: true=brand gradient ring, false=grey ring (seen)
  final bool isNew;

  final String? initials;

  /// Custom ring color (overrides brand gradient)
  final Color? ringColor;

  // ── Ring calculations ──────────────────────────────────────
  // FIXED tokens — not dynamic percentages
  double get _totalRingPad => showRing
      ? _AvatarTokens.storyRingWidth + _AvatarTokens.storyRingGap
      : 0.0;

  double get _photoSize => size - (_totalRingPad * 2);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  size,
      height: size,
      child: Stack(
        alignment:   Alignment.center,
        clipBehavior: Clip.none,
        children: [

          // ── Story ring ──────────────────────────────────
          if (showRing)
            Container(
              width:  size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // isNew → brand gradient, !isNew → grey
                gradient: isNew
                    ? LinearGradient(
                  begin: Alignment.topLeft,
                  end:   Alignment.bottomRight,
                  colors: [
                    ringColor ?? AppTheme.brandPrimary,
                    ringColor?.withValues(alpha: 0.60) ??
                        AppTheme.brandPrimary.withValues(alpha: 0.60),
                  ],
                )
                    : null,
                color: isNew ? null : const Color(0xFFCBCBCB),
              ),
            ),

          // ── White gap ring ──────────────────────────────
          if (showRing)
            Container(
              width:  size - (_AvatarTokens.storyRingWidth * 2),
              height: size - (_AvatarTokens.storyRingWidth * 2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),

          // ── Photo or initials ───────────────────────────
          imageUrl.isNotEmpty
              ? ClipOval(
            child: SizedBox(
              width:  _photoSize,
              height: _photoSize,
              child: CustomNetworkImage(
                imageUrl:     imageUrl,
                width:        _photoSize,
                height:       _photoSize,
                borderRadius: _photoSize / 2,
              ),
            ),
          )
              : _InitialsFallback(size: _photoSize, initials: initials),

          // ── Premium badge (priority over online dot) ────
          if (isPremium)
            Positioned(
              bottom: showRing ? _AvatarTokens.storyRingWidth : 0,
              right:  showRing ? _AvatarTokens.storyRingWidth : 0,
              child:  const _PremiumBadge(),
            )

          // ── Online dot ──────────────────────────────────
          else if (isOnline)
            Positioned(
              bottom: showRing ? _AvatarTokens.storyRingWidth : 0,
              right:  showRing ? _AvatarTokens.storyRingWidth : 0,
              child:  const _OnlineDot(),
            ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// STORY AVATAR
// Complete story-style component with ring + name below.
// Use in: Home Active Now, Chat List Stories row
//
// Replaces:
//   home_screen.dart     → _buildActiveAvatar()
//   chat_list_screen.dart → inline story builder
//
// Usage:
//   StoryAvatar(
//     imageUrl: user.image,
//     name: user.name,
//     isNew: user.isNew,
//     isOnline: user.isOnline,
//     onTap: () => context.push('/user_detail'),
//   )
// ═════════════════════════════════════════════════════════════
class StoryAvatar extends StatelessWidget {
  const StoryAvatar({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.onTap,
    this.isNew     = true,
    this.isOnline  = false,
    this.isPremium = false,
    this.size      = _AvatarTokens.storySize,
    this.margin    = const EdgeInsets.only(right: 16),
  });

  final String       imageUrl;
  final String       name;
  final VoidCallback onTap;
  final bool         isNew;
  final bool         isOnline;
  final bool         isPremium;
  final double       size;
  final EdgeInsets   margin;

  @override
  Widget build(BuildContext context) {
    // Truncate long names
    final displayName = name.split(' ').first;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PremiumAvatar(
              imageUrl:  imageUrl,
              size:      size,
              showRing:  true,
              isNew:     isNew,
              isOnline:  isOnline,
              isPremium: isPremium,
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: size + 8,
              child: Text(
                displayName,
                textAlign: TextAlign.center,
                maxLines:  1,
                overflow:  TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize:   _AvatarTokens.storyNameFontSize,
                  fontWeight: FontWeight.w600,
                  color:      AppTheme.brandDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// CONVERSATION AVATAR
// Avatar for chat list tiles — photo + online dot + premium badge.
// Replaces the inline Stack in _ConvoTile inside chat_list_screen.
//
// Usage:
//   ConversationAvatar(
//     imageUrl: convo['image'],
//     isOnline: convo['isOnline'],
//     isPremium: convo['isPremium'],
//   )
// ═════════════════════════════════════════════════════════════
class ConversationAvatar extends StatelessWidget {
  const ConversationAvatar({
    super.key,
    required this.imageUrl,
    this.isOnline  = false,
    this.isPremium = false,
    this.size      = _AvatarTokens.convoSize,
    this.radius    = _AvatarTokens.convoRadius,
  });

  final String imageUrl;
  final bool   isOnline;
  final bool   isPremium;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Photo ─────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: CustomNetworkImage(
            imageUrl:     imageUrl,
            width:        size,
            height:       size,
            borderRadius: radius,
          ),
        ),

        // ── Premium badge (top-right) ────────────────────
        if (isPremium)
          const Positioned(
            top:   -2,
            right: -2,
            child: _ConvoPremiumBadge(),
          ),

        // ── Online dot (bottom-right) ────────────────────
        if (isOnline && !isPremium)
          const Positioned(
            bottom: 1,
            right:  1,
            child:  _OnlineDot(),
          ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════
// PRIVATE COMPONENTS
// ═════════════════════════════════════════════════════════════

// ── Online dot — FIXED 10px always ────────────────────────────
class _OnlineDot extends StatelessWidget {
  const _OnlineDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  _AvatarTokens.dotSize,
      height: _AvatarTokens.dotSize,
      decoration: BoxDecoration(
        color: _AvatarTokens.dotColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: _AvatarTokens.dotBorder,
        ),
        boxShadow: [
          BoxShadow(
            color:      _AvatarTokens.dotColor.withValues(alpha: 0.45),
            blurRadius: 4,
            offset:     const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}

// ── Premium gold badge — PremiumAvatar ───────────────────────
class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  16,
      height: 16,
      decoration: BoxDecoration(
        shape:    BoxShape.circle,
        gradient: AppTheme.goldGradient,
        border:   Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color:      AppTheme.goldPrimary.withValues(alpha: 0.40),
            blurRadius: 4,
            offset:     const Offset(0, 1),
          ),
        ],
      ),
      child: const Icon(
        Icons.diamond_rounded,
        color: Colors.white,
        size:  8,
      ),
    );
  }
}

// ── Premium badge for ConversationAvatar (slightly larger) ────
class _ConvoPremiumBadge extends StatelessWidget {
  const _ConvoPremiumBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  _AvatarTokens.convoBadge,
      height: _AvatarTokens.convoBadge,
      decoration: BoxDecoration(
        gradient: AppTheme.goldGradient,
        shape:    BoxShape.circle,
        border:   Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color:      AppTheme.goldPrimary.withValues(alpha: 0.35),
            blurRadius: 4,
            offset:     const Offset(0, 1),
          ),
        ],
      ),
      child: const Icon(
        Icons.diamond_rounded,
        size:  9,
        color: Colors.white,
      ),
    );
  }
}

// ── Initials fallback ─────────────────────────────────────────
class _InitialsFallback extends StatelessWidget {
  const _InitialsFallback({required this.size, this.initials});
  final double  size;
  final String? initials;

  @override
  Widget build(BuildContext context) {
    final text = initials?.isNotEmpty == true
        ? initials!.substring(0, initials!.length.clamp(0, 2)).toUpperCase()
        : '?';

    return Container(
      width:  size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
          colors: [
            AppTheme.brandPrimary.withValues(alpha: 0.80),
            AppTheme.brandPrimary,
          ],
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize:   size * 0.32,
            fontWeight: FontWeight.w700,
            color:      Colors.white,
            height:     1,
          ),
        ),
      ),
    );
  }
}