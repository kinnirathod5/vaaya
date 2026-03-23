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
│   │   └── app_assets.dart               ⏳ Image/icon paths
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
│   │   └── guest_lock_widget.dart        ✅ NEW — Freemium lock (3 free profiles, then blur + login nudge)
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
    │   ├── screens/
    │   │   ├── login_screen.dart         ✅ DONE — Single phone field, no signup button,
    │   │   │                                      guest mode (3 free profiles), bottom sheet
    │   │   └── otp_verification_screen   ✅ DONE — Phone number passed via GoRouter extra,
    │   │       .dart                              6-box OTP, shake animation, auto-submit,
    │   │                                          resend timer, new/existing user routing
    │   └── widgets/
    │       ├── auth_background.dart      ✅ Dark cinematic bg + diamond pattern painter
    │       ├── phone_input_field.dart    ✅ +91 flag prefix, live validation, green tick
    │       ├── otp_input_row.dart        ✅ 6 individual boxes, focus auto-advance
    │       └── auth_bottom_text.dart     ✅ Terms & Privacy shared widget
    │
    ├── onboarding/
    │   ├── screens/
    │   │   └── account_creation_screen   ✅ DONE — 6-step flow, new order, ambient glow,
    │   │       .dart                              motivational hint text, celebration overlay
    │   └── widgets/
    │       ├── onboarding_step_header    ✅ Emoji progress bar — active emoji scales up,
    │       │   .dart                              completed steps show checkmark
    │       ├── onboarding_next_button    ✅ Gradient CTA, disabled state, VIP Lounge label
    │       │   .dart                              on last step
    │       ├── onboarding_helpers.dart   ✅ StepTitle + FieldLabel (public, no underscore)
    │       ├── step1_name.dart           ✅ Profile for chips + first/last name fields
    │       ├── step2_gender.dart         ✅ Large gender cards with animated selected badge
    │       ├── step3_birthday.dart       ✅ Cupertino date picker + age badge, gender-aware
    │       │                                      language
    │       ├── step4_height.dart         ✅ Cupertino ft/in pickers, gender-aware title,
    │       │                                      large display number
    │       ├── step5_community.dart      ✅ Samaj locked to Banjara + gotra chip selection
    │       ├── step6_photo_location.dart ✅ Photo upload + AI scan simulation + city field
    │       └── celebration_overlay.dart  ✅ Confetti (60 particles, CustomPainter) +
    │                                              welcome card + linear progress
    │
    ├── navigation/
    │   └── screens/
    │       └── main_scaffold.dart        ✅ 5-tab bottom nav — Home, Matches, Interests,
    │                                              Chat, Premium — frosted glass bar with badges
    │
    ├── home/
    │   ├── screens/
    │   │   └── home_screen.dart          ✅ DONE — CustomScrollView, time-based greeting,
    │   │                                          spotlight carousel, daily matches row,
    │   │                                          VIP banner, premium matches, success stories
    │   └── widgets/
    │       ├── home_header.dart          ✅
    │       ├── active_now_section.dart   ✅
    │       ├── spotlight_carousel.dart   ✅
    │       ├── daily_matches_row.dart    ✅
    │       ├── vip_banner_card.dart      ✅
    │       ├── premium_matches_row.dart  ✅
    │       ├── activity_update_card.dart ✅
    │       ├── success_stories_row.dart  ✅
    │       └── thought_of_the_day.dart   ✅
    │
    ├── matches/
    │   ├── screens/
    │   │   └── matches_screen.dart       ✅ DONE — Live search, animated filter chips,
    │   │                                          2-col grid, guest lock (index >= 3),
    │   │                                          GuestFreeCountBadge, empty state
    │   └── widgets/
    │       ├── matches_search_bar.dart   ✅
    │       ├── matches_filter_chips.dart ✅
    │       ├── matches_grid.dart         ✅ buildCard() static method added for guest lock
    │       └── search_filter_bottom_sheet.dart ✅ Age, height, city, education filters
    │
    ├── interests/
    │   ├── screens/
    │   │   └── interests_screen.dart     ✅ DONE — Received / Sent / Mutual Match tabs,
    │   │                                          accept moves to mutual, glassmorphism badges
    │   └── widgets/
    │       ├── interests_header.dart     ✅
    │       ├── interests_tab_bar.dart    ✅
    │       ├── received_request_card.dart ✅
    │       ├── sent_request_card.dart    ✅
    │       ├── mutual_match_card.dart    ✅
    │       ├── section_divider_label.dart ✅
    │       └── interests_empty_state.dart ✅
    │
    ├── chat/
    │   ├── screens/
    │   │   ├── chat_list_screen.dart     ✅ DONE — Match stories row, live search,
    │   │   │                                      unread badge, long press options
    │   │   └── chat_detail_screen.dart   ✅ DONE — Message list, date dividers,
    │   │                                          scroll to bottom, send handler
    │   └── widgets/
    │       ├── chat_list_header.dart     ✅
    │       ├── chat_search_bar.dart      ✅
    │       ├── match_stories_row.dart    ✅
    │       ├── chat_list_tile.dart       ✅ Unread tint, premium badge, status ticks
    │       ├── chat_empty_state.dart     ✅
    │       ├── chat_detail_header.dart   ✅
    │       ├── message_bubble.dart       ✅ Smart corner radius, sent/delivered/read ticks
    │       └── chat_input_bar.dart       ✅ Animated send button (grey→brand on typing)
    │
    ├── premium/
    │   ├── screens/
    │   │   └── upgrade_screen.dart       ✅ DONE — 3 plans (1/3/6 month), 8 perks,
    │   │                                          testimonials, trust badges, sticky gold CTA
    │   └── widgets/
    │       ├── upgrade_header.dart       ✅ Member count live badge
    │       ├── plan_card.dart            ✅ Selected state with gold border + glow
    │       ├── perk_item.dart            ✅ Highlighted perks in gold
    │       └── testimonial_card.dart     ✅ Star rating + avatar initials
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
            ├── settings_screen.dart      ✅ DONE — 6 groups (Account/Privacy/Notifications/
            │                                      App/Support/Danger), toggle tiles with
            │                                      subtitles, nav tiles with values, sign out +
            │                                      delete account with confirm dialogs
            └── [profile widgets/]
                ├── profile_header_card.dart    ✅
                ├── profile_completion_bar.dart ✅
                ├── profile_stats_row.dart      ✅
                ├── profile_info_section.dart   ✅
                └── profile_action_tile.dart    ✅
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

## 🔑 Key Design Decisions

### Auth Flow
- **Single phone field** — no separate signup. New user → OTP → Onboarding. Existing user → OTP → Dashboard.
- **Guest mode** — 3 profiles free, then `GuestLockedCard` blur + login nudge.
- Phone number passed via `GoRouter extra` from login → OTP screen.

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
| 2 | Login | `login_screen.dart` | ✅ |
| 3 | OTP | `otp_verification_screen.dart` | ✅ |
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