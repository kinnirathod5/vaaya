# 🏗️ Banjara Vivah — Complete App Architecture
## Final Merged Structure (Updated)

---

## 📂 Directory Map

```
lib/
│
├── main.dart                              ✅ Entry point
│
├── core/
│   ├── theme/
│   │   └── app_theme.dart                ✅ Colors, fonts, shadows, gradients
│   ├── router/
│   │   └── app_router.dart               ✅ GoRouter — all 13 routes defined
│   ├── constants/
│   │   ├── app_assets.dart               ⏳ Image/icon paths
│   │   └── auth_constants.dart           ✅ NEW — Auth design tokens (card radius, button
│   │                                              height, animation durations, orb sizes,
│   │                                              dot grid config, shadow values — single
│   │                                              source of truth for entire auth flow)
│   └── utils/
│       ├── haptic_utils.dart             ✅ lightImpact, mediumImpact, heavyImpact, selectionClick, errorVibrate
│       └── custom_toast.dart             ✅ Premium slide-down alerts
│
├── shared/
│   ├── widgets/
│   │   ├── primary_button.dart           ✅ Standard animated action button
│   │   ├── custom_textfield.dart         ✅ Premium form input with prefix icon
│   │   ├── custom_chip.dart              ✅ Selection pills — Gotra, interests, filters
│   │   ├── custom_network_image.dart     ✅ Shimmer loading image wrapper
│   │   ├── glass_container.dart          ✅ Glassmorphism blur container
│   │   ├── premium_avatar.dart           ✅ DP with online status ring
│   │   ├── section_header.dart           ✅ Reusable section heading + View All
│   │   ├── empty_state_widget.dart       ✅ Empty list UI
│   │   ├── premium_icon_button.dart      ✅ Circular icon buttons with shadow
│   │   ├── premium_list_tile.dart        ✅ Modern menu tiles
│   │   ├── match_badge.dart              ✅ Glowing match % pill
│   │   ├── premium_match_card.dart       ✅ Profile card with quick actions
│   │   ├── premium_lock_overlay.dart     ✅ Blurred VIP lock overlay
│   │   ├── shimmer_loading_grid.dart     ✅ Skeleton loader for grids
│   │   ├── guest_lock_widget.dart        ✅ Freemium lock (3 free profiles, then blur + login nudge)
│   │   ├── auth_background.dart          ✅ NEW — Shared warm-white bg with 5 soft orbs +
│   │   │                                          dot grid texture (used on login + OTP +
│   │   │                                          any future auth screen). Driven by
│   │   │                                          AuthConstants for pixel-perfect consistency.
│   │   ├── auth_bottom_text.dart         ✅ NEW — "By continuing you agree to Terms & Privacy"
│   │   │                                          shared across all auth screens
│   │   ├── auth_snackbar.dart            ✅ NEW — Centralised error/success floating snackbar
│   │   │                                          with icon + pill shape. showError() and
│   │   │                                          showSuccess() static methods.
│   │   └── handle_bar.dart               ✅ NEW — Small rounded pill at top of every
│   │                                              bottom-sheet-style form card in auth flow
│   ├── painters/
│   │   └── dot_grid_painter.dart         ✅ NEW — Honeycomb-style dot grid CustomPainter,
│   │                                              reads spacing/radius/opacity from
│   │                                              AuthConstants. Used by AuthBackground.
│   └── animations/
│       └── fade_animation.dart           ✅ Smooth staggered entry transitions
│
└── features/
    │
    ├── splash/
    │   └── screens/
    │       └── splash_screen.dart        ✅ DONE — Animated logo reveal, dashed rotating ring,
    │                                              bouncing dots, 3.2s sequence, auth check TODO
    │
    ├── auth/
    │   └── screens/
    │       ├── login_screen.dart         ✅ DONE v4 — Uses shared AuthBackground, AuthBottomText,
    │       │                                      HandleBar, AuthSnackbar, AuthConstants.
    │       │                                      Fixed: FocusNode listener leak, AnimatedBuilder
    │       │                                      → ListenableBuilder, duplicate _ params,
    │       │                                      removed unused _TrustPill.
    │       │                                      Single phone field, guest mode (3 free profiles),
    │       │                                      bottom sheet, breathing glow OTP button.
    │       └── otp_verification_screen   ✅ DONE v3 — Uses shared AuthBackground, AuthBottomText,
    │           .dart                              HandleBar, AuthSnackbar, AuthConstants.
    │                                              Fixed: FocusNode listener leak in _OtpBoxState,
    │                                              AnimatedBuilder → ListenableBuilder, duplicate _
    │                                              params, added PopScope (blocks back during
    │                                              verification), back button disabled during load.
    │                                              6-box OTP, shake animation, auto-submit,
    │                                              resend timer, new/existing user routing.
    │
    ├── onboarding/
    │   └── screens/
    │       └── account_creation_screen   ✅ DONE — 6-step flow, new order, ambient glow,
    │           .dart                              motivational hint text, celebration overlay
    │
    ├── navigation/
    │   └── screens/
    │       └── main_scaffold.dart        ✅ 5-tab bottom nav — Home, Matches, Interests,
    │                                              Chat, Premium — frosted glass bar with badges
    │
    ├── home/
    │   └── screens/
    │       └── home_screen.dart          ✅ DONE — CustomScrollView, time-based greeting,
    │                                              spotlight carousel, daily matches row,
    │                                              VIP banner, premium matches, success stories
    │
    ├── matches/
    │   └── screens/
    │       └── matches_screen.dart       ✅ DONE — Live search, animated filter chips,
    │                                              2-col grid, guest lock (index >= 3),
    │                                              GuestFreeCountBadge, empty state
    │
    ├── interests/
    │   └── screens/
    │       └── interests_screen.dart     ✅ DONE — Received / Sent / Mutual Match tabs,
    │                                              accept moves to mutual, glassmorphism badges
    │
    ├── chat/
    │   └── screens/
    │       ├── chat_list_screen.dart     ✅ DONE — Match stories row, live search,
    │       │                                      unread badge, long press options
    │       └── chat_detail_screen.dart   ✅ DONE — Message list, date dividers,
    │                                              scroll to bottom, send handler
    │
    ├── premium/
    │   └── screens/
    │       └── upgrade_screen.dart       ✅ DONE — 3 plans (1/3/6 month), 8 perks,
    │                                              testimonials, trust badges, sticky gold CTA
    │
    ├── notifications/
    │   └── screens/
    │       └── notifications_screen.dart ✅ DONE — 5 notification types (interest/match/
    │                                              view/message/system), grouped Today/Earlier,
    │                                              swipe to delete (Dismissible), mark all read,
    │                                              unread dot + pink tint, tap to navigate
    │
    └── profile/
        └── screens/
            ├── my_profile_screen.dart    ✅ DONE — SliverAppBar hero photo, completion bar,
            │                                      4-stat row, about, details grid, photos row,
            │                                      account quick actions
            ├── edit_profile_screen.dart  ✅ DONE — 3 tabs (Basic Info / About / Preferences),
            │                                      custom tab bar, photo manager, height picker,
            │                                      gotra chips, age/height range sliders,
            │                                      city preference chips, unsaved badge,
            │                                      discard dialog
            ├── user_detail_screen.dart   ✅ DONE — Swipeable photo gallery (PageView),
            │                                      dot indicators, online badge, match % badge,
            │                                      quick info pills, compatibility bars (Kundali/
            │                                      Lifestyle/Values/Location), about, details
            │                                      grid, interests chips, frosted CTA bar
            │                                      (message + send interest)
            └── settings_screen.dart      ✅ DONE — 6 groups (Account/Privacy/Notifications/
                                                   App/Support/Danger), toggle tiles with
                                                   subtitles, nav tiles with values, sign out +
                                                   delete account with confirm dialogs
```

---

## 📱 GoRouter — All Routes

```dart
/             → SplashScreen
/login        → LoginScreen          (fade transition)
/otp          → OtpVerificationScreen (slide-up)
/onboarding   → AccountCreationScreen (fade)
/dashboard    → MainScaffold          (fade)
/chat_detail  → ChatDetailScreen      (slide right)
/user_detail  → UserDetailScreen      (slide right)
/my_profile   → MyProfileScreen       (slide right)
/edit_profile → EditProfileScreen     (slide-up)
/settings     → SettingsScreen        (slide right)
/notifications→ NotificationsScreen   (slide right)
/premium      → UpgradeScreen         (slide-up)
/upgrade      → redirect → /premium
```

---

## 📱 Bottom Tab Navigation — 5 Tabs

| Tab | Screen | Route |
|-----|--------|-------|
| 🏠 Home | `home_screen.dart` | `/dashboard` |
| 🔍 Matches | `matches_screen.dart` | `/dashboard` |
| 🌸 Interests | `interests_screen.dart` | `/dashboard` |
| 💬 Chat | `chat_list_screen.dart` | `/dashboard` |
| 💎 Premium | `upgrade_screen.dart` | `/dashboard` |

---

## 🧩 Shared Auth Widgets — Consistency Layer

These shared widgets were extracted from duplicated code across login and OTP screens.
Every auth screen **must** use these instead of inlining its own version.

| Widget | File | Purpose |
|--------|------|---------|
| `AuthBackground` | `shared/widgets/auth_background.dart` | 5 orbs + dot grid on warm-white bg |
| `DotGridPainter` | `shared/painters/dot_grid_painter.dart` | Honeycomb dot texture (used by AuthBackground) |
| `AuthBottomText` | `shared/widgets/auth_bottom_text.dart` | Terms + Privacy footer |
| `AuthSnackbar` | `shared/widgets/auth_snackbar.dart` | `.showError()` / `.showSuccess()` floating pills |
| `HandleBar` | `shared/widgets/handle_bar.dart` | Pill at top of bottom-sheet cards |
| `AuthConstants` | `core/constants/auth_constants.dart` | All design tokens — radius, heights, durations, orb sizes, shadows |

### Design tokens controlled by `AuthConstants`:
- Card radius: **32** (both screens)
- Button radius: **16** / Button height: **54** (both screens)
- Entry animation: **1000ms** (both screens)
- Scaffold bg: `0xFFFDF8F9` (both screens)
- Dot grid: spacing 24, radius 1.2, alpha 0.055, vertical factor 0.86
- Card shadows: blur 32, brand alpha 0.10, black alpha 0.04
- All orb sizes and opacities

---

## 🐛 Bug Fixes Applied (v4 Login / v3 OTP)

| Bug | Where | Fix |
|-----|-------|-----|
| FocusNode listener memory leak | Login `_PhoneInputFieldState` + OTP `_OtpBoxState` | Store listener as `late final VoidCallback`, remove in `dispose()` |
| `AnimatedBuilder` not available | Both screens, multiple usages | Replaced with `ListenableBuilder` |
| `builder: (_, _)` duplicate params | Both screens | Changed to `(context, child)` |
| Back press during OTP verification | OTP screen | Added `PopScope(canPop: !_isLoading)` |
| Back button tappable during loading | OTP header back button | Added `if (_isLoading) return;` guard |
| Unused `_TrustPill` widget | Login screen | Removed dead code |
| Inconsistent card radius (36 vs 32) | Login vs OTP | Unified to 32 via `AuthConstants.cardRadius` |
| Inconsistent button height (52 vs 54) | Login vs OTP | Unified to 54 via `AuthConstants.buttonHeight` |
| Inconsistent button radius (18 vs 16) | Login vs OTP | Unified to 16 via `AuthConstants.buttonRadius` |
| Inconsistent animation duration (1000 vs 900) | Login vs OTP | Unified to 1000ms via `AuthConstants.entryDuration` |
| Duplicate `_AuthBackground` with different values | Both screens | Extracted to shared `AuthBackground` widget |
| Duplicate `_AuthBottomText` with different styles | Both screens | Extracted to shared `AuthBottomText` widget |
| Inline snackbar code, inconsistent look | Both screens | Extracted to shared `AuthSnackbar` utility |

---

## 🔑 Key Design Decisions

### Auth Flow
- **Single phone field** — no separate signup. New user → OTP → Onboarding. Existing user → OTP → Dashboard.
- **Guest mode** — 3 profiles free, then `GuestLockedCard` blur + login nudge.
- Phone number passed via `GoRouter extra` from login → OTP screen.
- **Shared visual layer** — `AuthBackground`, `AuthBottomText`, `HandleBar`, `AuthSnackbar` ensure pixel-perfect consistency across login, OTP, and any future auth screen.

### Onboarding Step Order (UX optimized)
```
1. Name + Profile for   → Identity first
2. Gender               → Fast win, enables personalized language
3. Birthday             → Personal moment
4. Height               → Quick and fun
5. Community + Gotra    → Cultural roots
6. Photo + City         → Final investment (momentum built)
```

### Guest Freemium Lock
- `GuestLockedCard` — wraps any profile card, blurs it, shows lock icon
- `GuestLockOverlay` — full screen lock after 3 profiles
- Located: `lib/shared/widgets/guest_lock_widget.dart`
- Usage in matches grid: `if (isGuest && index >= 3) return GuestLockedCard(...)`

### Language & Design Principles
- **English only** — no Hinglish in UI text
- **Minimal text** — every word earns its place
- **Cormorant Garamond** for titles, **Poppins** for body
- `withValues(alpha:)` everywhere — `withOpacity()` deprecated in Flutter 3.x
- `MediaQuery.of(context).padding.bottom` — never hardcoded bottom padding
- **`ListenableBuilder`** over `AnimatedBuilder` — Flutter 3.10+ best practice
- **Named parameters in builder callbacks** — `(context, child)` not `(_, _)` for Dart compatibility
- **FocusNode listeners always cleaned up** — stored as `late final VoidCallback`, removed in `dispose()`

---

## ⏳ Pending / TODO

| Item | Status |
|------|--------|
| Firebase Auth (Phone OTP) | ⏳ Backend pending |
| Firestore profile read/write | ⏳ Backend pending |
| Firebase Storage (photo upload) | ⏳ Backend pending |
| FCM push notifications | ⏳ Backend pending |
| Riverpod providers (auth, user, matches, chat, interests) | ⏳ State mgmt pending |
| Real image picker (step 6 + edit profile) | ⏳ Plugin pending |
| Payment gateway (Razorpay/Stripe) | ⏳ Backend pending |
| `payment_screen.dart` | ⏳ Not built |
| `dashboard_screen.dart` (separate from main_scaffold) | ⏳ Not needed — merged into main_scaffold |
| Deep link handling in GoRouter | ⏳ Pending |
| App icon + splash native config | ⏳ Pending |

---

## 🔥 Firebase Collections (Planned)

```
users/{uid}
  └── name, age, city, profession, education, height,
      gotra, gender, about, photos[], isPremium,
      isVerified, completionPct, createdAt

matches/{id}
  └── uid1, uid2, status, matchPct, timestamp

chats/{id}
  └── participants[], lastMessage, lastMessageTime
  └── messages/{msgId}
        └── senderId, text, timestamp, status

interests/{id}
  └── senderUid, receiverUid, status, timestamp

notifications/{uid}/items/{id}
  └── type, title, body, isRead, timestamp, actionRoute
```

---

## ✅ Screens Complete — 16 of 16 Core UI Screens

| # | Screen | File | Status |
|---|--------|------|--------|
| 1 | Splash | `splash_screen.dart` | ✅ |
| 2 | Login | `login_screen.dart` | ✅ v4 |
| 3 | OTP | `otp_verification_screen.dart` | ✅ v3 |
| 4 | Account Creation | `account_creation_screen.dart` | ✅ |
| 5 | Main Nav Shell | `main_scaffold.dart` | ✅ |
| 6 | Home | `home_screen.dart` | ✅ |
| 7 | Matches | `matches_screen.dart` | ✅ |
| 8 | Interests | `interests_screen.dart` | ✅ |
| 9 | Chat List | `chat_list_screen.dart` | ✅ |
| 10 | Chat Detail | `chat_detail_screen.dart` | ✅ |
| 11 | Upgrade / Premium | `upgrade_screen.dart` | ✅ |
| 12 | Notifications | `notifications_screen.dart` | ✅ |
| 13 | My Profile | `my_profile_screen.dart` | ✅ |
| 14 | Edit Profile | `edit_profile_screen.dart` | ✅ |
| 15 | User Detail | `user_detail_screen.dart` | ✅ |
| 16 | Settings | `settings_screen.dart` | ✅ |

---

## 🧱 Shared Widgets Summary — 21 Total

| # | Widget | File |
|---|--------|------|
| 1 | `PrimaryButton` | `shared/widgets/primary_button.dart` |
| 2 | `CustomTextField` | `shared/widgets/custom_textfield.dart` |
| 3 | `CustomChip` | `shared/widgets/custom_chip.dart` |
| 4 | `CustomNetworkImage` | `shared/widgets/custom_network_image.dart` |
| 5 | `GlassContainer` | `shared/widgets/glass_container.dart` |
| 6 | `PremiumAvatar` | `shared/widgets/premium_avatar.dart` |
| 7 | `SectionHeader` | `shared/widgets/section_header.dart` |
| 8 | `EmptyStateWidget` | `shared/widgets/empty_state_widget.dart` |
| 9 | `PremiumIconButton` | `shared/widgets/premium_icon_button.dart` |
| 10 | `PremiumListTile` | `shared/widgets/premium_list_tile.dart` |
| 11 | `MatchBadge` | `shared/widgets/match_badge.dart` |
| 12 | `PremiumMatchCard` | `shared/widgets/premium_match_card.dart` |
| 13 | `PremiumLockOverlay` | `shared/widgets/premium_lock_overlay.dart` |
| 14 | `ShimmerLoadingGrid` | `shared/widgets/shimmer_loading_grid.dart` |
| 15 | `GuestLockWidget` | `shared/widgets/guest_lock_widget.dart` |
| 16 | `AuthBackground` | `shared/widgets/auth_background.dart` |
| 17 | `AuthBottomText` | `shared/widgets/auth_bottom_text.dart` |
| 18 | `AuthSnackbar` | `shared/widgets/auth_snackbar.dart` |
| 19 | `HandleBar` | `shared/widgets/handle_bar.dart` |
| 20 | `DotGridPainter` | `shared/painters/dot_grid_painter.dart` |
| 21 | `FadeAnimation` | `shared/animations/fade_animation.dart` |