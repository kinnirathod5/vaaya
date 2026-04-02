# Banjara Vivah — App Architecture Map
## Complete File Reference (48 Dart Files)
### Last Updated: 2026-04-02 (shared widget audit — all screens verified against actual imports; settings_screen inline header → CustomAppBar; dependency tables corrected)

---

## HOW TO READ THIS DOCUMENT

Each file entry shows:
- **Purpose** — one-line description of what the file does
- **Uses Core** — imports from `lib/core/` (theme, router, constants, utils)
- **Uses Shared** — imports from `lib/shared/` (widgets, animations, painters)
- **Uses Features** — imports from other `lib/features/` screens

"(none)" means no internal project imports in that category.

---

# ENTRY POINT

---

## lib/main.dart
**Purpose:** App entry point — initializes Flutter, sets status bar style, mounts MaterialApp with GoRouter + AppTheme
**Uses Core:** `AppTheme`, `AppRouter`
**Uses Shared:** (none)
**Uses Features:** (none)

---

# CORE FILES

---

## lib/core/theme/app_theme.dart
**Purpose:** Central design system — all colors, gradients, shadows, text styles, spacing tokens, border radii, and ThemeData for the entire app
**Uses Core:** (none — foundation file)
**Uses Shared:** (none)
**Uses Features:** (none)

> Key exports: `brandPrimary`, `brandDark`, `bgScaffold`, `goldPrimary`, `goldLight`, `onlineDot`, `cardRadius` (20), `sheetRadius` (28), `screenPadH` (20), `iconBtnSize` (44), `softShadow`, `primaryGlow`, `goldGlow`, `brandGradient`, `goldGradient`, `goldCardDecoration`, `lightTheme`

---

## lib/core/router/app_router.dart
**Purpose:** GoRouter config — 13 named routes with 3 transition types (fade, slide-right, slide-up)
**Uses Core:** (none)
**Uses Shared:** (none)
**Uses Features:** `SplashScreen`, `LoginScreen`, `OtpVerificationScreen`, `AccountCreationScreen`, `MainScaffold`, `ChatDetailScreen`, `UserDetailScreen`, `MyProfileScreen`, `EditProfileScreen`, `SettingsScreen`, `NotificationsScreen`, `UpgradeScreen`

> Routes: `/` `/login` `/otp` `/onboarding` `/dashboard` `/chat_detail` `/user_detail` `/my_profile` `/edit_profile` `/settings` `/notifications` `/premium` `/upgrade→/premium`

---

## lib/core/constants/app_assets.dart
**Purpose:** Central asset library — all image URLs (Unsplash dummy photos), local asset paths, Lottie animation paths, font names, and external URLs
**Uses Core:** (none — pure constants)
**Uses Shared:** (none)
**Uses Features:** (none)

> Key constants: `dummyFemale1-9`, `dummyMale1-4`, `successStory1-3`, `appLogo`, Lottie paths, privacy/terms URLs

---

## lib/core/constants/auth_constants.dart
**Purpose:** Single source of truth for all auth-screen design tokens — card radius, button height, animation durations, orb sizes, dot-grid config, shadow values
**Uses Core:** (none — pure constants)
**Uses Shared:** (none)
**Uses Features:** (none)

> Key constants: `cardRadius` (32), `buttonRadius` (16), `buttonHeight` (54), `entryDuration` (1000ms), `scaffoldBg`, orb sizes + alphas, dot-grid spacing/radius/opacity

---

## lib/core/constants/onboarding_constants.dart
**Purpose:** Single source of truth for 6-step onboarding wizard — animation durations, progress header sizes, picker dimensions, photo card size, step radii
**Uses Core:** (none — pure constants)
**Uses Shared:** (none)
**Uses Features:** (none)

> Key constants: `pageTransition` (480ms), `emojiBubbleSize` (28/22), `pickerHeight` (210/230), `photoCardWidth` (180), `genderCardRadius` (22)

---

## lib/core/utils/custom_toast.dart
**Purpose:** Toast notification system — 7 variants (success, error, info, warning, premium, match, interestSent) with haptic feedback and SnackBar.floating
**Uses Core:** `AppTheme`
**Uses Shared:** (none)
**Uses Features:** (none)

---

## lib/core/utils/haptic_utils.dart
**Purpose:** Centralized haptic feedback — standard impacts + 6 semantic patterns (errorVibrate, successPattern, matchPattern, notificationPattern, deletePattern, premiumPattern)
**Uses Core:** (none — wraps `flutter/services.dart`)
**Uses Shared:** (none)
**Uses Features:** (none)

---

# SHARED — ANIMATIONS

---

## lib/shared/animations/fade_animation.dart
**Purpose:** Reusable fade + slide entry animation with stagger delay support — used on every list/grid/card reveal across the entire app
**Uses Core:** (none)
**Uses Shared:** (none)
**Uses Features:** (none)

> Parameters: `delayInMs`, `durationInMs` (500), `slideDistance` (18), `FadeDirection` enum (up/down/left/right/none)

---

# SHARED — PAINTERS

---

## lib/shared/painters/dot_grid_painter.dart
**Purpose:** Custom painter for honeycomb dot-grid texture used on auth backgrounds
**Uses Core:** `AuthConstants`, `AppTheme`
**Uses Shared:** (none)
**Uses Features:** (none)

---

# SHARED — WIDGETS

---

## lib/shared/widgets/auth_background.dart
**Purpose:** Warm-white auth screen background with 5 soft colored orbs (blooms) and dot-grid texture — used on every auth screen
**Uses Core:** `AuthConstants`, `AppTheme`
**Uses Shared:** `DotGridPainter`
**Uses Features:** (none)

---

## lib/shared/widgets/auth_bottom_text.dart
**Purpose:** "By continuing you agree to Terms & Privacy" footer with rich-text highlighted links — shared across all auth screens
**Uses Core:** `AppTheme`
**Uses Shared:** (none)
**Uses Features:** (none)

---

## lib/shared/widgets/auth_snackbar.dart
**Purpose:** Centralized auth-screen error/success snackbar — pill-shaped floating bar with icon, `showError()` and `showSuccess()` static methods
**Uses Core:** `AuthConstants`, `AppTheme`
**Uses Shared:** (none)
**Uses Features:** (none)

---

## lib/shared/widgets/custom_app_bar.dart
**Purpose:** Standard top app bar with title (Cormorant 26px), optional subtitle, back button (Material+InkWell), and actions — implements PreferredSizeWidget
**Uses Core:** `AppTheme`, `HapticUtils`
**Uses Shared:** (none)
**Uses Features:** (none)

---

## lib/shared/widgets/custom_chip.dart
**Purpose:** Selection chip/tag widget — 3 variants (filled, outlined, subtle), optional icon + count badge, Material+InkWell ripple
**Uses Core:** `AppTheme`
**Uses Shared:** (none)
**Uses Features:** (none)

---

## lib/shared/widgets/custom_network_image.dart
**Purpose:** Cached network image with shimmer loading skeleton, retry on error, optional bottom gradient overlay
**Uses Core:** (none — uses `cached_network_image` + `shimmer` packages)
**Uses Shared:** (none)
**Uses Features:** (none)

---

## lib/shared/widgets/custom_textfield.dart
**Purpose:** Premium text input field — focus animation, prefix/suffix icons, validation, character counter, clear button; all 5 memory-leak and border-flicker bugs fixed
**Uses Core:** `AppTheme`
**Uses Shared:** (none)
**Uses Features:** (none)

---

## lib/shared/widgets/empty_state_widget.dart
**Purpose:** Empty state display with icon/emoji, title, message, action buttons — 5 named presets (noMatches, noChats, noInterests, noNotifications, noMutualMatches)
**Uses Core:** `AppTheme`, `HapticUtils`
**Uses Shared:** (none)
**Uses Features:** (none)

---

## lib/shared/widgets/glass_container.dart
**Purpose:** Frosted glass container — 5 variants (light, dark, brand, gold, success), configurable blur/opacity/border
**Uses Core:** `AppTheme`
**Uses Shared:** (none)
**Uses Features:** (none)

---

## lib/shared/widgets/guest_lock_widget.dart
**Purpose:** Freemium gate system — `GuestLockedCard` (blur on individual cards) and `GuestLockOverlay` (full-screen gate after 3 free views)
**Uses Core:** `AppTheme`, `HapticUtils`
**Uses Shared:** (none)
**Uses Features:** (none)

---

## lib/shared/widgets/handle_bar.dart
**Purpose:** Small rounded pill at the top of every bottom-sheet-style form card in the auth flow
**Uses Core:** `AuthConstants`, `AppTheme`
**Uses Shared:** (none)
**Uses Features:** (none)

---

## lib/shared/widgets/match_badge.dart
**Purpose:** Glowing pill showing compatibility % — 4 color tiers (90%+ purple-pink, 75%+ brand, 60%+ amber, <60 grey), optional flame icon
**Uses Core:** `AppTheme`
**Uses Shared:** (none)
**Uses Features:** (none)

---

## lib/shared/widgets/premium_avatar.dart
**Purpose:** Avatar system — `PremiumAvatar` (online dot + premium badge), `StoryAvatar` (ring + name), `ConversationAvatar` (chat list avatar with badge)
**Uses Core:** `AppTheme`
**Uses Shared:** `CustomNetworkImage`
**Uses Features:** (none)

---

## lib/shared/widgets/premium_glass_app_bar.dart
**Purpose:** Frosted glass top bar (24 blur) that floats over scrollable content — implements PreferredSizeWidget
**Uses Core:** `AppTheme`
**Uses Shared:** (none)
**Uses Features:** (none)

---

## lib/shared/widgets/premium_icon_button.dart
**Purpose:** Circular/rounded icon button — press scale animation (0.92), optional badge count (9+ cap), shadow, border
**Uses Core:** `AppTheme`, `HapticUtils`
**Uses Shared:** (none)
**Uses Features:** (none)

---

## lib/shared/widgets/premium_list_tile.dart
**Purpose:** Card-style list tile — 4 variants (nav/toggle/info/danger), leading icon bg, scale animation, haptic feedback; used in Settings + Profile
**Uses Core:** `AppTheme`, `HapticUtils`
**Uses Shared:** (none)
**Uses Features:** (none)

---

## lib/shared/widgets/premium_lock_overlay.dart
**Purpose:** Frosted glass overlay for locked premium content — 3 lock types (premium/contact/photo), gradient badge, blur effect, unlock button
**Uses Core:** `AppTheme`, `HapticUtils`
**Uses Shared:** (none)
**Uses Features:** (none)

---

## lib/shared/widgets/premium_match_card.dart
**Purpose:** Full-bleed profile card — match% badge, online/new/premium badges, name+age, like/skip buttons with spring animation; used in Matches grid
**Uses Core:** `AppTheme`, `HapticUtils`
**Uses Shared:** `CustomNetworkImage`, `GlassContainer`
**Uses Features:** (none)

---

## lib/shared/widgets/primary_button.dart
**Purpose:** Main CTA button — 6 variants (filled/outlined/ghost/dark/gold/success), scale animation, loading spinner, icon support
**Uses Core:** `AppTheme`, `HapticUtils`
**Uses Shared:** (none)
**Uses Features:** (none)

---

## lib/shared/widgets/section_header.dart
**Purpose:** Reusable section title row — title (Cormorant 22px), optional subtitle, action button with arrow, count badge, leading icon
**Uses Core:** `AppTheme`, `HapticUtils`
**Uses Shared:** (none)
**Uses Features:** (none)

---

## lib/shared/widgets/shimmer_loading_grid.dart
**Purpose:** Custom skeleton loader — 3 modes (grid / list / row), no external shimmer package, custom gradient animation with stagger
**Uses Core:** (none)
**Uses Shared:** (none)
**Uses Features:** (none)

---

## lib/shared/widgets/step_progress_header.dart
**Purpose:** Multi-step wizard header for onboarding — back button, step label, emoji bubble row (scales on active, checkmark when done), animated progress bar
**Uses Core:** `OnboardingConstants`, `AppTheme`
**Uses Shared:** (none)
**Uses Features:** (none)

---

# FEATURE SCREENS

---

## lib/features/splash/screens/splash_screen.dart
**Purpose:** Animated 3.4s splash sequence — rings → logo → app name → tagline → ornaments → dots; tap-to-skip (after 1.5s); custom internal `_ConstellationRingPainter` + `_DotGridPainter`; RepaintBoundary-wrapped ambient blobs; auto-navigates to `/login`
**Uses Core:** `AppTheme`, `CustomToast`
**Uses Shared:** (none)
**Uses Features:** (none)

> 8 animation controllers with staggered intervals; double-navigation guard via `_skipped` flag; RepaintBoundary on blob layer prevents full-tree repaints

---

## lib/features/auth/screens/login_screen.dart
**Purpose:** Phone number login — single field, stats strip ("50K+ Families / 4.8★ / Pan India"), guest mode bottom sheet (3 free profiles), entry animations, dashed ring painter around brand icon, double-shadow form card
**Uses Core:** `AuthConstants`, `AppTheme`, `CustomToast`, `HapticUtils`
**Uses Shared:** `FadeAnimation`, `AuthBackground`, `AuthBottomText`, `HandleBar`, `CustomTextField`, `PrimaryButton`
**Uses Features:** (none)

> ListenableBuilder replaces AnimatedBuilder; Material+InkWell on guest button (ripple); gradient-masked divider line under app name

---

## lib/features/auth/screens/otp_verification_screen.dart
**Purpose:** 6-digit OTP verification — auto-submit, shake on error (TweenSequence 5-keyframe), resend timer (30s), PopScope blocks back during verification; compact boxes (h:52, r:10); cursor fully hidden
**Uses Core:** `AuthConstants`, `AppTheme`, `CustomToast`, `HapticUtils`
**Uses Shared:** `FadeAnimation`, `AuthBackground`, `AuthBottomText`, `HandleBar`, `PrimaryButton`
**Uses Features:** (none)

> OTP box double-border system (no TextField borders); phone number chip with change button; heading fontSize 30, verify button w800

---

## lib/features/onboarding/screens/account_creation_screen.dart
**Purpose:** 6-step account creation wizard — name, gender, birthday, height, community/gotra, photo+city; celebration overlay on completion; CustomChip pill radius:10; field labels sentence-case; `_dobTouched=true` default; InkWell on photo upload (disabled when uploaded)
**Uses Core:** `AppAssets`, `AuthConstants`, `OnboardingConstants`, `AppTheme`, `CustomToast`, `HapticUtils`
**Uses Shared:** `FadeAnimation`, `CustomChip`, `CustomTextField`, `GlassContainer`, `HandleBar`, `PrimaryButton`, `StepProgressHeader`
**Uses Features:** (none)

> Memory leak fixed: removeListener in dispose(); welcome card fontSize 22 (handles long names); height display w800 44px

---

## lib/features/navigation/screens/main_scaffold.dart
**Purpose:** Root 5-tab shell — IndexedStack preserves scroll state; frosted glass nav bar (`BackdropFilter sigmaX/Y:28`) with badge counts; gold Premium tab; AnimatedSize sliding label (appears only on selected tab); AnimatedScale badge (shrinks when active)
**Uses Core:** `AppTheme`, `HapticUtils`, `dart:ui`
**Uses Shared:** (none)
**Uses Features:** `HomeScreen`, `MatchesScreen`, `InterestsScreen`, `ChatListScreen`, `UpgradeScreen`

> Premium tab: dark gradient bg + heavier haptic; ping-dot badges with white border

---

## lib/features/home/screens/home_screen.dart
**Purpose:** Home feed — sticky mini header (scroll-listener controlled), active-now story strip, spotlight carousel (spring like-button animation), daily matches grid, liked-you banner, VIP banner, premium matches, success stories; RepaintBoundary on ambient blobs
**Uses Core:** `AppTheme`, `CustomToast`, `HapticUtils`, `AppAssets`, `dart:math`, `dart:ui`
**Uses Shared:** `FadeAnimation`, `CustomNetworkImage`, `EmptyStateWidget`, `GuestLockWidget`, `MatchBadge`, `PremiumAvatar`, `PremiumGlassAppBar`, `PremiumIconButton`, `PremiumMatchCard`, `SectionHeader`, `ShimmerLoadingGrid`
**Uses Features:** (none)

> Memory leak fixed: `_pageController` listener stored as named callback; AnimatedBuilder param `(_, __)` (no duplicate name); all GestureDetectors → Material+InkWell

---

## lib/features/matches/screens/matches_screen.dart
**Purpose:** Matches grid — inline animated search (SizeTransition + FadeTransition), filter chips with glow shadow on selection, shimmer loading skeleton (800ms simulated delay), guest lock after index 3, filter bottom sheet (age/height sliders + city/education chips + toggles); staggered FadeAnimation on grid items (index×50ms)
**Uses Core:** `AppTheme`, `CustomToast`, `HapticUtils`, `AppAssets`, `dart:ui`
**Uses Shared:** `CustomChip`, `FadeAnimation`, `GuestLockWidget`, `EmptyStateWidget`, `PremiumMatchCard`, `PremiumIconButton`, `PrimaryButton`, `SectionHeader`, `ShimmerLoadingGrid`
**Uses Features:** (none)

> Filter reset clears search state; match% displayed as animated arc ring on card; ambient RepaintBoundary blobs

---

## lib/features/interests/screens/interests_screen.dart
**Purpose:** Interests screen — 3 tabs (Received/Mutual/Sent) with animated glow pill indicator; Received: cinematic full-bleed cards with glass badges; Mutual: dark premium styling + brand ring on avatar; Sent: color-coded status pill (Pending grey / Viewed green); gradient fade section dividers
**Uses Core:** `AppTheme`, `HapticUtils`, `AppAssets`, `CustomToast`, `dart:ui`
**Uses Shared:** `FadeAnimation`, `CustomNetworkImage`, `EmptyStateWidget`, `GlassContainer`, `MatchBadge`, `PremiumAvatar`, `PremiumIconButton`, `PrimaryButton`, `SectionHeader`, `ShimmerLoadingGrid`
**Uses Features:** (none)

> Accept action moves card to Mutual with toast feedback; all text constrained (maxLines + overflow); empty state with brand circle bg

---

## lib/features/chat/screens/chat_list_screen.dart
**Purpose:** Chat list — new matches story row (gradient ring for new / grey for seen), unread-tinted conversation tiles (bg tint + left border), online dot, status ticks (sent/delivered/read icons), long-press bottom-sheet options (mute/block/delete), collapsible search bar
**Uses Core:** `AppTheme`, `HapticUtils`, `AppAssets`, `CustomToast`
**Uses Shared:** `FadeAnimation`, `StoryAvatar`, `ConversationAvatar`, `EmptyStateWidget`, `ShimmerLoadingGrid`, `SectionHeader`, `PremiumIconButton`
**Uses Features:** (none)

> Staggered FadeAnimation on conversation tiles; section headers with unread badge count

---

## lib/features/chat/screens/chat_detail_screen.dart
**Purpose:** Chat conversation — smart-radius message bubbles (brand gradient sent / white received), avatar grouping (shows only on last consecutive message), date dividers (gradient side-lines + pill label), multiline input bar (max 110px), animated send button (grey→gradient, active only when typing), more-options sheet
**Uses Core:** `AppTheme`, `HapticUtils`, `AppAssets`, `CustomToast`
**Uses Shared:** `FadeAnimation`, `PremiumAvatar`, `PremiumIconButton`, `PremiumLockOverlay`, `EmptyStateWidget`
**Uses Features:** (none)

> Asymmetric corner radius on bubbles based on tail position; send button animated color change on text input

---

## lib/features/profile/screens/my_profile_screen.dart
**Purpose:** Own profile view — hero photo, pull-to-refresh (RefreshIndicator), completion % indicator, stats row (tappable individual cards), about section, edit shortcut, sign-out; AnimatedOpacity properly animates 0.0→1.0 on scroll; all tap areas use InkWell
**Uses Core:** `AppAssets`, `AppTheme`, `CustomToast`, `HapticUtils`
**Uses Shared:** `FadeAnimation`, `CustomNetworkImage`, `GlassContainer`, `PremiumListTile`, `PrimaryButton`, `SectionHeader`, `ShimmerLoadingGrid`
**Uses Features:** (none)

> Menu section headers: sentence case; profession text w700 + darker color for visual hierarchy

---

## lib/features/profile/screens/user_detail_screen.dart
**Purpose:** Other user's profile — photo gallery with tap zones (prev/next) + visible dots, animated compatibility progress bars (color-coded per metric), about section with read-more toggle, details grid (color-coded icon bg per category), heart like animation (TweenSequence scale spring), bottom CTA bar (interest/message/share), report/block sheet
**Uses Core:** `AppTheme`, `HapticUtils`, `CustomToast`, `AppAssets`, `dart:ui`
**Uses Shared:** `FadeAnimation`, `CustomChip`, `CustomNetworkImage`, `GlassContainer`, `GuestLockWidget`, `MatchBadge`, `PremiumIconButton`, `PremiumLockOverlay`, `PrimaryButton`, `SectionHeader`
**Uses Features:** (none)

> Drag handle on bottom content card; marital status + gotra pills in name row; drag-handle visible

---

## lib/features/profile/screens/edit_profile_screen.dart
**Purpose:** Profile editor — 6 icon+label tab bar (Personal/Career/Location/Family/Lifestyle/Partner Pref), floating animated Save button (position animation + loading spinner), pulsing unsaved badge, card-based section grouping, chip selectors with check icon on selected, partner pref sliders with color-coded ranges + info banner
**Uses Core:** `AppTheme`, `AppAssets`, `CustomToast`, `HapticUtils`, `dart:ui` (CupertinoPicker)
**Uses Shared:** `CustomAppBar`, `CustomChip`, `CustomNetworkImage`, `CustomTextField`, `FadeAnimation`, `PrimaryButton`, `SectionHeader`
**Uses Features:** (none)

> Each section wrapped in white card for visual grouping; section spacing + border radius consistency enforced

---

## lib/features/profile/screens/settings_screen.dart
**Purpose:** Settings screen — 6 sections (Account/Privacy/Notifications/App/Support/Danger Zone); all tiles refactored to PremiumListTile (nav/toggle/danger variants); master notification toggle cascades to all sub-toggles; toggle feedback via CustomToast; danger zone in red-bordered card; confirm dialogs with icon + color
**Uses Core:** `AppTheme`, `HapticUtils`, `CustomToast`
**Uses Shared:** `CustomAppBar`, `FadeAnimation`, `CustomNetworkImage`, `PremiumListTile`, `SectionHeader`
**Uses Features:** (none)

> ~150 lines of custom tile code deleted; section headers with icons (SectionHeader widget); mini profile card at top with premium/free badge

---

## lib/features/notifications/screens/notifications_screen.dart
**Purpose:** Notifications list — grouped Today/Earlier; 5 type-specific styles (interest=pink, match=purple, view=blue, message=green, system=amber); Dismissible swipe-to-delete (red bg); type icon badge positioned bottom-right on avatar; unread animated pill badge; mark-all-read in header; AnimatedContainer for read/unread transitions
**Uses Core:** `AppTheme`, `CustomToast`, `HapticUtils`
**Uses Shared:** `CustomAppBar`, `EmptyStateWidget`, `FadeAnimation`, `PremiumAvatar`, `SectionHeader`, `ShimmerLoadingGrid`
**Uses Features:** (none)

> Type config map: hardcoded icon/color per type; section headers with optional badge count

---

## lib/features/premium/screens/upgrade_screen.dart
**Purpose:** Premium upgrade — dark theme with gold accents; gold shimmer animation (ShaderMask on hero title + perk icons); 4 plan cards with animated scale + glow on selection; glassmorphism cards (GlassContainer gold/dark variant); testimonials with quote-mark decoration + star rating; trust badges grid; sticky frosted bottom CTA (BackdropFilter blur + semi-transparent); ambient gold/brand orbs on dark gradient bg
**Uses Core:** `AppTheme`, `CustomToast`, `HapticUtils`, `AppAssets`, `dart:ui`
**Uses Shared:** `CustomNetworkImage`, `FadeAnimation`, `GlassContainer`, `PrimaryButton`
**Uses Features:** (none)

> Live member count badge with green online dot; per-month price breakdown in CTA; shimmer on select perks only (not all)

---

---

# DEPENDENCY MAP

---

## Top Shared Widgets by Usage

| Rank | Widget | Used By (count) | Which Files |
|------|--------|-----------------|-------------|
| 1 | `FadeAnimation` | **14 screens** | All feature screens except splash + main_scaffold |
| 2 | `SectionHeader` | **9 screens** | home, matches, interests, chat_list, my_profile, user_detail, edit_profile, settings, notifications |
| 2 | `PrimaryButton` | **9 screens** | login, otp, account_creation, matches, interests, user_detail, my_profile, edit_profile, upgrade |
| 4 | `CustomNetworkImage` | **9 files** | home, interests, my_profile, user_detail, edit_profile, settings, upgrade (direct) + `PremiumAvatar`, `PremiumMatchCard` (internal) |
| 5 | `EmptyStateWidget` | **6 screens** | home, matches, interests, chat_list, chat_detail, notifications |
| 5 | `PremiumIconButton` | **6 screens** | home, matches, chat_list, chat_detail, user_detail, interests |
| 5 | `ShimmerLoadingGrid` | **6 screens** | home, matches, interests, chat_list, my_profile, notifications |
| 8 | `CustomAppBar` | **3 screens** | edit_profile, notifications, settings |
| 8 | `GuestLockWidget` | **3 screens** | home, matches, user_detail |

> Note: `AuthSnackbar` (lib/shared/widgets/auth_snackbar.dart) exists but is **not imported by any screen** — auth screens use `CustomToast` instead.

---

## Top 5 Most-Used Core Files

| Rank | Core File | Used By (count) | Notes |
|------|-----------|-----------------|-------|
| 1 | `AppTheme` | **~35 files** | Every screen + nearly every shared widget imports this |
| 2 | `HapticUtils` | **~22 files** | All feature screens + most interactive shared widgets |
| 3 | `AppAssets` | **8 files** | account_creation, home, matches, interests, chat_list, chat_detail, user_detail, upgrade |
| 4 | `AuthConstants` | **7 files** | dot_grid_painter, auth_background, auth_snackbar, handle_bar, login, otp, account_creation |
| 5 | `OnboardingConstants` | **2 files** | step_progress_header, account_creation |

---

## Screens Ranked by Total Internal Import Count

| Rank | Screen | Core Imports | Shared Imports | Feature Imports | Total |
|------|--------|-------------|----------------|-----------------|-------|
| 1 | `home_screen.dart` | 4 | 11 | 0 | **15** |
| 2 | `interests_screen.dart` | 4 | 10 | 0 | **14** |
| 2 | `user_detail_screen.dart` | 4 | 10 | 0 | **14** |
| 4 | `account_creation_screen.dart` | 6 | 7 | 0 | **13** |
| 4 | `matches_screen.dart` | 4 | 9 | 0 | **13** |
| 6 | `edit_profile_screen.dart` | 4 | 7 | 0 | **11** |
| 6 | `my_profile_screen.dart` | 4 | 7 | 0 | **11** |
| 8 | `chat_list_screen.dart` | 4 | 6 | 0 | **10** |
| 8 | `login_screen.dart` | 4 | 6 | 0 | **10** |
| 10 | `notifications_screen.dart` | 3 | 6 | 0 | **9** |
| 10 | `chat_detail_screen.dart` | 4 | 5 | 0 | **9** |
| 10 | `otp_verification_screen.dart` | 4 | 5 | 0 | **9** |
| 13 | `settings_screen.dart` | 3 | 5 | 0 | **8** |
| 14 | `upgrade_screen.dart` | 4 | 4 | 0 | **8** |
| 15 | `main_scaffold.dart` | 2 | 0 | 5 | **7** |
| 16 | `splash_screen.dart` | 2 | 0 | 0 | **2** |

---

## Shared Widgets That Use Other Shared Widgets

| Widget | Depends On |
|--------|-----------|
| `AuthBackground` | `DotGridPainter` |
| `PremiumAvatar` | `CustomNetworkImage` |
| `PremiumMatchCard` | `CustomNetworkImage`, `GlassContainer` |

All other shared widgets are leaf nodes (no shared widget dependencies).

---

## Core Files That Have No Dependencies (Foundation Layer)

These files can always be safely imported without circular-dependency risk:

- `AppTheme` — imports only `google_fonts` (external)
- `AppAssets` — no imports
- `AuthConstants` — no imports
- `OnboardingConstants` — no imports
- `HapticUtils` — imports only `flutter/services.dart`

---

---

# ROUTES REFERENCE

| Route | Screen | Transition |
|-------|--------|-----------|
| `/` | `SplashScreen` | fade |
| `/login` | `LoginScreen` | fade |
| `/otp` | `OtpVerificationScreen` | slide-up |
| `/onboarding` | `AccountCreationScreen` | fade |
| `/dashboard` | `MainScaffold` | fade |
| `/chat_detail` | `ChatDetailScreen` | slide-right |
| `/user_detail` | `UserDetailScreen` | slide-right |
| `/my_profile` | `MyProfileScreen` | slide-right |
| `/edit_profile` | `EditProfileScreen` | slide-up |
| `/settings` | `SettingsScreen` | slide-right |
| `/notifications` | `NotificationsScreen` | slide-right |
| `/premium` | `UpgradeScreen` | slide-up |
| `/upgrade` | redirect → `/premium` | — |

---

# FILE COUNT SUMMARY

| Category | Count |
|----------|-------|
| Entry point (`main.dart`) | 1 |
| Core files | 7 |
| Shared animations | 1 |
| Shared painters | 1 |
| Shared widgets | 22 |
| Feature screens | 16 |
| **Total Dart files** | **48** |

---

# PENDING TODO

Items carried forward from architecture history + current codebase state:

## Backend / Firebase

| Item | Status | Notes |
|------|--------|-------|
| Firebase Auth (Phone OTP) | ⏳ Pending | Replace dummy OTP flow in `otp_verification_screen.dart` |
| Firestore profile read/write | ⏳ Pending | All screens use local dummy data models |
| Firebase Storage (photo upload) | ⏳ Pending | `edit_profile_screen.dart` photo picker is placeholder |
| FCM push notifications | ⏳ Pending | `notifications_screen.dart` uses static dummy list |
| Firebase App Check | ⏳ Pending | — |

## State Management

| Item | Status | Notes |
|------|--------|-------|
| Riverpod providers | ⏳ Pending | No state management layer yet; all data is local dummy const |
| Auth state provider | ⏳ Pending | Needed for guest vs logged-in routing logic |
| User profile provider | ⏳ Pending | Currently `_dummyUser` const in home/profile screens |
| Matches provider | ⏳ Pending | `_dummyDaily`, `_dummyPremium` etc. |
| Chat provider (real-time) | ⏳ Pending | Messages are static dummy list |
| Interests provider | ⏳ Pending | Accept/decline are local setState only |
| Notifications provider | ⏳ Pending | — |
| Premium/subscription status | ⏳ Pending | `_isPremium` is hardcoded false everywhere |

## Payments

| Item | Status | Notes |
|------|--------|-------|
| Razorpay / Stripe integration | ⏳ Pending | Plan cards in `upgrade_screen.dart` have no payment handler |
| `payment_screen.dart` | ⏳ Not built | Post-selection flow after plan card tap |
| Receipt / confirmation screen | ⏳ Not built | — |

## Missing Screens

| Screen | Status |
|--------|--------|
| Search / advanced filter screen | ⏳ Not built (currently filter is a bottom sheet) |
| Block list screen | ⏳ Not built (linked from settings) |
| Help center / FAQ screen | ⏳ Not built (linked from settings) |
| Contact us screen | ⏳ Not built (linked from settings) |
| Privacy policy webview | ⏳ Not built (linked from settings + auth) |
| Photo viewer / full-screen gallery | ⏳ Not built |
| Kundali match detail screen | ⏳ Not built |

## Infrastructure / Config

| Item | Status |
|------|--------|
| Real image picker (step 6 onboarding + edit profile) | ⏳ Plugin needed (`image_picker`) |
| Deep link handling in GoRouter | ⏳ Pending |
| Native app icon (`flutter_launcher_icons`) | ⏳ Pending |
| Native splash screen (`flutter_native_splash`) | ⏳ Pending |
| App Store / Play Store listing assets | ⏳ Pending |
| Analytics (Firebase Analytics / Mixpanel) | ⏳ Pending |
| Crash reporting (Firebase Crashlytics) | ⏳ Pending |
| Performance monitoring | ⏳ Pending |

## UI / Polish

| Item | Status |
|------|--------|
| Dark mode | ⏳ Placeholder in settings (shows "Coming soon" snackbar) |
| Language / localization | ⏳ Not implemented (English only for now) |
| `ShimmerLoadingGrid` integration | ✅ Wired to `_isInitialLoading` in matches_screen, home_screen, my_profile_screen, notifications_screen, chat_list_screen |
| `PremiumMatchCard` integration | ✅ Wired in home_screen (daily matches row) + matches_screen (grid) |
| `SectionHeader` integration | ✅ Wired in 7 screens — home, matches, interests, chat_list, my_profile, edit_profile, notifications |
| `MatchBadge` integration | ✅ Wired in home_screen `_SpotlightCard` + interests_screen + user_detail_screen |
| `PremiumGlassAppBar` integration | ⏳ Built but screens use inline headers |
| `PremiumIconButton` integration | ✅ Wired in home_screen, matches_screen, chat_list_screen, user_detail_screen — inline `_HeaderBtn`/`_IconBtn` deleted |
| `EmptyStateWidget` integration | ✅ Wired in home, matches, interests, chat_list, chat_detail, notifications |
| `GlassContainer` integration | ✅ Wired in account_creation, my_profile, upgrade screens |
| Memory leak fixes | ✅ Named callbacks in dispose(), AnimatedBuilder param deduplication, InkWell replacing GestureDetector across all screens |
| RepaintBoundary on ambient blobs | ✅ Applied in splash, home, matches (prevents full-tree repaints) |
| Message status ticks | ✅ Sent / delivered / read icons wired in chat_list_screen |
| Swipe-to-dismiss notifications | ✅ Dismissible widget + red bg wired in notifications_screen |
| Pull-to-refresh (my profile) | ✅ RefreshIndicator wired in my_profile_screen |
| Frosted glass nav bar | ✅ BackdropFilter sigmaX/Y:28 in main_scaffold |

## Firebase Collections (Planned Schema)

```
users/{uid}
  └── name, age, city, profession, education, height,
      gotra, gender, about, photos[], isPremium,
      isVerified, completionPct, createdAt, lastActive

matches/{id}
  └── uid1, uid2, status, matchPct, timestamp

chats/{id}
  └── participants[], lastMessage, lastMessageTime
  └── messages/{msgId}
        └── senderId, text, timestamp, status (sent/delivered/read)

interests/{id}
  └── senderUid, receiverUid, status (pending/accepted/declined), timestamp

notifications/{uid}/items/{id}
  └── type, title, body, isRead, timestamp, actionRoute, senderUid

subscriptions/{uid}
  └── plan (1m/3m/6m/1y), startDate, endDate, isPremium, orderId
```

---

---

# WIDGET USAGE AUDIT — CURRENTLY USING vs. SHOULD ALSO BE USING

> **How to read this section:**
> - "Currently Using" lists every shared widget and core file actually imported (from `import` statements).
> - "Should Also Be Using" lists existing shared/core files that are NOT imported but would directly improve that screen.
> - Core file `AppRouter` is intentionally excluded — screens navigate via `go_router` directly, not by importing the router config.
> - `DotGridPainter` is excluded — it is an internal dependency of `AuthBackground`, not used directly by screens.

---

## lib/features/splash/screens/splash_screen.dart

### ✅ Currently Using
**Core:** `AppTheme`, `CustomToast`
**Shared:** _(none — uses internal private painters)_

### 💡 Should Also Be Using
- `AppAssets` — logo path is hardcoded inline; should reference `AppAssets.appLogo` for single-source-of-truth

---

## lib/features/auth/screens/login_screen.dart

### ✅ Currently Using
**Core:** `AuthConstants`, `AppTheme`, `HapticUtils`
**Shared:** `FadeAnimation`, `AuthBackground`, `AuthBottomText`, `AuthSnackbar`, `HandleBar`, `CustomTextField`, `PrimaryButton`

### 💡 Should Also Be Using
- `CustomToast` _(core/utils)_ — error feedback goes through `AuthSnackbar`; once real Firebase errors arrive, `CustomToast.showError()` alongside gives richer in-app feedback

---

## lib/features/auth/screens/otp_verification_screen.dart

### ✅ Currently Using
**Core:** `AuthConstants`, `AppTheme`, `HapticUtils`
**Shared:** `FadeAnimation`, `AuthBackground`, `AuthBottomText`, `AuthSnackbar`, `HandleBar`, `PrimaryButton`

### 💡 Should Also Be Using
- `CustomToast` _(core/utils)_ — complement `AuthSnackbar` shake-on-error with `CustomToast.showError()` for non-blocking feedback on resend success

---

## lib/features/onboarding/screens/account_creation_screen.dart

### ✅ Currently Using
**Core:** `AppAssets`, `AuthConstants`, `OnboardingConstants`, `AppTheme`, `HapticUtils`
**Shared:** `FadeAnimation`, `AuthSnackbar`, `CustomChip`, `CustomTextField`, `GlassContainer`, `PrimaryButton`, `StepProgressHeader`

### 💡 Should Also Be Using
- `HandleBar` — step cards slide up from the bottom but do not show the pill handle that `HandleBar` provides; auth screens already use it, onboarding should too for visual consistency
- `CustomToast` _(core/utils)_ — `CustomToast.showSuccess()` on final completion would provide a satisfying celebration toast before navigation

---

## lib/features/navigation/screens/main_scaffold.dart

### ✅ Currently Using
**Core:** `AppTheme`, `HapticUtils`, `dart:ui`
**Shared:** _(none — shell only)_
**Features:** `HomeScreen`, `MatchesScreen`, `InterestsScreen`, `ChatListScreen`, `UpgradeScreen`

### 💡 Should Also Be Using
- `CustomToast` _(core/utils)_ — the scaffold is the ideal mount point for app-wide toast notifications (match alerts, interest received)

---

## lib/features/home/screens/home_screen.dart

### ✅ Currently Using
**Core:** `AppTheme`, `HapticUtils`, `AppAssets`, `dart:math`, `dart:ui`
**Shared:** `FadeAnimation`, `CustomNetworkImage`, `PremiumAvatar`, `SectionHeader`, `PremiumIconButton`, `PremiumMatchCard`, `MatchBadge`, `EmptyStateWidget`, `ShimmerLoadingGrid`

### 💡 Should Also Be Using
- `GuestLockWidget` — guest users see the full home feed unrestricted; `GuestLockedCard` should blur cards beyond index 2 and `GuestLockOverlay` should gate the "Liked You" banner
- `PremiumGlassAppBar` — the sticky mini-header is built inline; `PremiumGlassAppBar` (24-blur, PreferredSizeWidget) would replace it
- `CustomToast` _(core/utils)_ — no toast feedback when a user likes a card from the daily-matches row; `CustomToast.showMatch()` or `.showSuccess()` should fire on like action

---

## lib/features/matches/screens/matches_screen.dart

### ✅ Currently Using
**Core:** `AppTheme`, `HapticUtils`, `AppAssets`, `CustomToast`, `dart:ui`
**Shared:** `FadeAnimation`, `CustomChip`, `GuestLockWidget`, `EmptyStateWidget`, `PremiumMatchCard`, `PremiumIconButton`, `PrimaryButton`, `SectionHeader`, `ShimmerLoadingGrid`

### 💡 Should Also Be Using
- `PremiumGlassAppBar` — the search bar + filter icon row is a custom `SliverPersistentHeader`; `PremiumGlassAppBar` with an integrated search field would clean this up

---

## lib/features/interests/screens/interests_screen.dart

### ✅ Currently Using
**Core:** `AppTheme`, `HapticUtils`, `AppAssets`, `CustomToast`, `dart:ui`
**Shared:** `FadeAnimation`, `CustomNetworkImage`, `PremiumAvatar`, `EmptyStateWidget`, `MatchBadge`, `SectionHeader`

### 💡 Should Also Be Using
- `ShimmerLoadingGrid` — no loading skeleton while interests are fetching; `ShimmerLoadingGrid.list` mode matches the card layout
- `PrimaryButton` — Accept / Decline buttons may still be inline; `PrimaryButton.filled` (Accept) and `.outlined` (Decline) handle scale animation and haptic
- `GlassContainer` — the glass name/age badge overlaid on the photo uses a plain `Container` with manual blur; `GlassContainer.dark` with its blur/border config covers this
- `CustomAppBar` — the top bar ("Interests") is built inline; `CustomAppBar` with optional subtitle gives the standard back-button and title treatment
- `CustomToast` _(core/utils)_ — accept/decline actions give no toast confirmation; `CustomToast.showSuccess()` on accept and `.showInfo()` on decline closes the feedback loop
- `GuestLockWidget` — guest users can freely browse all received interests; `GuestLockedCard` should gate interest details after the first 3

---

## lib/features/chat/screens/chat_list_screen.dart

### ✅ Currently Using
**Core:** `AppTheme`, `HapticUtils`, `AppAssets`, `CustomToast`
**Shared:** `FadeAnimation`, `StoryAvatar`, `ConversationAvatar`, `EmptyStateWidget`, `ShimmerLoadingGrid`, `SectionHeader`, `PremiumIconButton`

### 💡 Should Also Be Using
- `PremiumGlassAppBar` — the "Messages" title + search icon bar is built inline; `PremiumGlassAppBar` with a floating blur effect fits the chat aesthetic

---

## lib/features/chat/screens/chat_detail_screen.dart

### ✅ Currently Using
**Core:** `AppTheme`, `HapticUtils`, `AppAssets`, `CustomToast`
**Shared:** `FadeAnimation`, `CustomNetworkImage`, `PremiumAvatar`, `PremiumIconButton`, `EmptyStateWidget`

### 💡 Should Also Be Using
- `CustomAppBar` — the chat header (avatar + name + online status + back + call icons) is entirely inline; `CustomAppBar` with `actions:` + `subtitle:` handles the standard structure
- `PremiumLockOverlay` — free-tier users should have messages beyond a threshold blurred; `PremiumLockOverlay.contact` type is designed for exactly this gate

---

## lib/features/profile/screens/my_profile_screen.dart

### ✅ Currently Using
**Core:** `AppAssets`, `AppTheme`, `HapticUtils`, `CustomToast`
**Shared:** `FadeAnimation`, `CustomNetworkImage`, `GlassContainer`, `PremiumListTile`, `PrimaryButton`, `SectionHeader`, `ShimmerLoadingGrid`

### 💡 Should Also Be Using
- (no major gaps — all primary shared widgets now wired)

---

## lib/features/profile/screens/user_detail_screen.dart

### ✅ Currently Using
**Core:** `AppTheme`, `HapticUtils`, `CustomToast`, `dart:ui`
**Shared:** `FadeAnimation`, `CustomNetworkImage`, `MatchBadge`, `SectionHeader`, `PremiumIconButton`, `PrimaryButton`

### 💡 Should Also Be Using
- `PremiumLockOverlay` — contact details and extra photos should be gated for free users; `PremiumLockOverlay.contact` and `.photo` types handle both cases
- `GlassContainer` — name/age overlay on photo gallery uses plain `Container`; `GlassContainer.dark` with blur is the correct component
- `CustomChip` — hobbies/lifestyle tags are plain `Container` text pills; `CustomChip.subtle` handles them properly
- `GuestLockWidget` — guest users see full profile; `GuestLockOverlay` should block detail sections after preview
- `AppAssets` — photo gallery uses hardcoded Unsplash URLs inline; should reference `AppAssets` constants

---

## lib/features/profile/screens/edit_profile_screen.dart

### ✅ Currently Using
**Core:** `AppTheme`, `AppAssets`, `HapticUtils`, `CustomToast`
**Shared:** `CustomAppBar`, `CustomChip`, `CustomNetworkImage`, `CustomTextField`, `FadeAnimation`, `PrimaryButton`, `SectionHeader`

### 💡 Should Also Be Using
- `AppAssets` for tab icons — the 6 tab icons use hardcoded values; centralising to `AppAssets` prevents drift

---

## lib/features/profile/screens/settings_screen.dart

### ✅ Currently Using
**Core:** `AppTheme`, `HapticUtils`, `CustomToast`
**Shared:** `FadeAnimation`, `CustomNetworkImage`, `PremiumListTile`, `SectionHeader`

### 💡 Should Also Be Using
- `CustomAppBar` — the "Settings" top bar is built inline; `CustomAppBar` with back button is the shared standard
- `PrimaryButton` — "Sign Out" and "Delete Account" buttons may still be inline; `PrimaryButton.outlined` and `.danger` variants handle them with animation

---

## lib/features/notifications/screens/notifications_screen.dart

### ✅ Currently Using
**Core:** `AppTheme`, `HapticUtils`, `CustomToast`
**Shared:** `CustomAppBar`, `EmptyStateWidget`, `FadeAnimation`, `PremiumAvatar`, `SectionHeader`, `ShimmerLoadingGrid`

### 💡 Should Also Be Using
- (no major gaps — all primary shared widgets now wired)

---

## lib/features/premium/screens/upgrade_screen.dart

### ✅ Currently Using
**Core:** `AppTheme`, `HapticUtils`, `CustomToast`, `dart:ui`
**Shared:** `FadeAnimation`, `GlassContainer`, `PrimaryButton`

### 💡 Should Also Be Using
- `PremiumListTile` — the perk list is an inline `_PerkRow`; `PremiumListTile.info` with leading icon covers the same layout
- `CustomNetworkImage` — testimonial avatars use hardcoded Unsplash URLs in raw `CircleAvatar`; `CustomNetworkImage` adds shimmer loading and error fallback
- `MatchBadge` — "90% match rate" stats shown as plain text; `MatchBadge` pills reuse the glowing visual language

---

---

# MASTER RECOMMENDATIONS TABLE

| Screen | Status | Notes |
|--------|--------|-------|
| `user_detail_screen.dart` | ✅ All gaps closed | Added `PremiumLockOverlay` (contact), `GlassContainer` (name badge), `CustomChip` (interests), `GuestLockOverlay`, `AppAssets` photo URLs |
| `chat_detail_screen.dart` | ✅ All gaps closed | Added `PremiumLockOverlay` (reply gate for free users); `CustomAppBar` not applicable — header needs avatar + profile-tap |
| `interests_screen.dart` | ✅ All gaps closed | Added `ShimmerLoadingGrid`, `PrimaryButton` (accept/decline), `GlassContainer` (badge); `CustomAppBar` not applicable — uses tabbed layout |
| `home_screen.dart` | ✅ All gaps closed | Added `GuestLockedCard` (liked-you banner), `PremiumGlassAppBar` (mini header) |
| `upgrade_screen.dart` | ✅ All gaps closed | Added `CustomNetworkImage` (testimonial avatars); `PremiumListTile` not compatible (dark theme); `MatchBadge` not applicable (stat pills) |
| `settings_screen.dart` | ✅ All gaps closed | Already uses `PremiumListTile` for sign-out/delete; `CustomAppBar` not applicable — uses `SliverAppBar` |
| `edit_profile_screen.dart` | ✅ All gaps closed | `AppAssets` gap N/A — tab icons are Material `Icons.*` |
| `account_creation_screen.dart` | ✅ All gaps closed | `HandleBar` already present at line 561 |
| `chat_list_screen.dart` | ✅ All gaps closed | `PremiumGlassAppBar` not applicable — inline scrollable header, not sticky |
| `matches_screen.dart` | ✅ All gaps closed | `PremiumGlassAppBar` not applicable — inline scrollable header, not sticky |
| `login_screen.dart` | ✅ All gaps closed | — |
| `otp_verification_screen.dart` | ✅ All gaps closed | — |
| `my_profile_screen.dart` | ✅ All gaps closed | — |
| `notifications_screen.dart` | ✅ All gaps closed | — |
| `main_scaffold.dart` | ✅ All gaps closed | — |
| `splash_screen.dart` | ✅ All gaps closed | — |

> **All 16 screens have been audited and all applicable shared-widget gaps have been closed.**

---

## Key Design Rules (Enforced Everywhere)

| Rule | Implementation |
|------|---------------|
| No `withOpacity()` | Always `withValues(alpha: x)` — Flutter 3.x requirement |
| No hardcoded bottom padding | Always `MediaQuery.of(context).padding.bottom` |
| No `GestureDetector` on buttons | Always `Material + InkWell` for proper ripple |
| No `const` with `.withValues()` | `withValues()` is a runtime method, cannot be const |
| Header/nav icon buttons | 44×44px, `BorderRadius.circular(14)`, rounded square |
| Card action buttons (in-card) | `BoxShape.circle`, smaller size (30-36px) |
| All listener callbacks named | Stored as `late final VoidCallback`, removed in `dispose()` |
| All `AnimatedBuilder` params named | `(context, child)` not `(_, __)` — Dart compatibility |
| Screen title (full-page) | `fontSize: 32`, Cormorant Garamond |
| Screen title (modal/sheet) | `fontSize: 26`, Cormorant Garamond |
| Section titles | `fontSize: 22`, Cormorant Garamond, `_AccentSectionLabel` |
| Online dot color | `AppTheme.onlineDot` = `Color(0xFF4ADE80)` — never hardcoded |
| Card border radius | `AppTheme.cardRadius` = 20.0 |
| Sheet border radius | `AppTheme.sheetRadius` = 28.0 |
| Horizontal screen padding | `AppTheme.screenPadH` = 20.0 |
| Branding | "Banjara Vivah" everywhere — never "Vaaya" |
| OTP box dimensions | Height: 52, border-radius: 10, cursor: hidden |
| Auth field labels | Sentence case, letterSpacing: 0.3 — never ALL CAPS |
| ListenableBuilder vs AnimatedBuilder | Prefer `ListenableBuilder` for pure Listenable (no animation value needed) |
| Ambient blobs / background painters | Always wrap in `RepaintBoundary` to isolate repaint layer |
| Stagger delay increment | 50–60ms per item for list/grid FadeAnimation stagger |
| OTP/Auth buttons | fontSize: 16, w800 for primary confirm button |
| Filter chips (selected state) | `BoxShadow` with `blurRadius: 8` + color glow — no border change alone |