🏗️ Banjara Vivah - Complete App Architecture (Merged Structure)

This document outlines the final, merged folder structure for the Banjara Vivah application. It combines the best of both worlds: a detailed feature-driven module breakdown (ready for GoRouter and State Management) and a premium UI/UX component organization.

📂 The Directory Map

lib/
│
├── main.dart                          <-- 🏁 Entry Point (Kitchen ka darwaza)
│
├── core/                              <-- 🛠️ App-wide Utilities & Shared Items
│   ├── theme/                         <-- 🎨 "White Lotus" Palette (#F23B5F)
│   │   └── app_theme.dart             <-- Centralized Colors, Fonts, and Decorations
│   ├── router/                        <-- 🛣️ GoRouter setup (Saare raaste yahan define honge)
│   │   └── app_router.dart
│   ├── constants/                     <-- 📌 App Constants
│   │   └── app_assets.dart            <-- Image and Icon paths
│   └── utils/                         <-- ⚙️ Helper Functions
│       ├── haptic_utils.dart          <-- Centralized vibration logic
│       └── custom_toast.dart          <-- Premium slide-down alerts
│
├── shared/                            <-- 🧩 Reusable "Lego Blocks" (Used across multiple features)
│   ├── widgets/
│   │   ├── primary_button.dart        <-- Standard animated action button
│   │   ├── custom_textfield.dart      <-- Standard premium form input
│   │   ├── glass_container.dart       <-- For premium blur/glassmorphism effects
│   │   ├── custom_app_bar.dart        <-- Standard top header
│   │   ├── premium_glass_app_bar.dart <-- ✨ NEW: Frosted glass floating app bar
│   │   ├── custom_network_image.dart  <-- Shimmer loading wrapper for images
│   │   ├── custom_chip.dart           <-- Premium pills for Gotra/Interests
│   │   ├── premium_avatar.dart        <-- DP with online status indicator
│   │   ├── empty_state_widget.dart    <-- UI for empty lists (No chats, etc.)
│   │   ├── section_header.dart        <-- Reusable headings with "View All" actions
│   │   ├── premium_icon_button.dart   <-- Circular buttons with soft shadow
│   │   ├── premium_list_tile.dart     <-- Modern menu items for Settings/Profile
│   │   ├── match_badge.dart           <-- Glowing match percentage pill
│   │   ├── premium_match_card.dart    <-- ✨ NEW: Reusable Profile Card with Quick Actions
│   │   ├── premium_lock_overlay.dart  <-- ✨ NEW: Blurred VIP lock for hidden profiles
│   │   └── shimmer_loading_grid.dart  <-- ✨ NEW: Skeleton loader for grids
│   └── animations/
│       └── fade_animation.dart        <-- Smooth entry transitions
│
└── features/                          <-- 🚀 App ke alag-alag hisse (Modules)
│
├── splash/                        <-- 1. Splash Screen
│   └── screens/
│       └── splash_screen.dart
│
├── auth/                          <-- 2. Login/Signup & 3. OTP
│   └── screens/
│       ├── login_screen.dart      <-- (Cleaned transparent UI)
│       ├── signup_screen.dart
│       └── otp_verification_screen.dart <-- (Fixed invisible border boxes)
│
├── onboarding/                    <-- 4. Account Creation Flow (Multi-step)
│   └── screens/
│       ├── account_creation_screen.dart <-- ✨ UPDATED: The 6-step animated flow
│       ├── basic_details_screen.dart
│       ├── upload_photos_screen.dart
│       └── preferences_screen.dart
│
├── navigation/                    <-- 🌟 BOTTOM TAB NAVIGATION WRAPPER
│   └── screens/
│       └── main_scaffold.dart     <-- ✨ UPDATED: Frosted Glass Nav Bar with Badges
│
├── home/                          <-- 5. Home Dashboard
│   ├── screens/
│   │   └── home_screen.dart       <-- ✨ UPDATED: Premium Scrollable UI with Radar
│
├── matches/                       <-- 6. Match Discovery & Advanced Filters
│   ├── screens/
│   │   └── matches_screen.dart    <-- Uses PremiumCards, LockOverlays & Shimmers
│   └── widgets/
│       └── search_filter_bottom_sheet.dart <-- Shifted here for logical grouping
│
├── interests/                     <-- 8. Likes / Interests
│   └── screens/
│       └── interests_screen.dart  
│
├── chat/                          <-- 9. Chat / Messaging
│   └── screens/
│       ├── chat_list_screen.dart  
│       └── chat_detail_screen.dart<-- Personal chat screen
│
├── premium/                       <-- 12. Premium Upgrade
│   └── screens/
│       ├── upgrade_screen.dart    
│       └── payment_screen.dart
│
├── notifications/                 <-- 11. Notifications
│   └── screens/
│       └── notifications_screen.dart
│
└── profile/                       <-- 7. Profile Detail, 13. Edit, 14. Settings
└── screens/
├── my_profile_screen.dart
├── edit_profile_screen.dart
├── user_detail_screen.dart<-- Kisi aur ki profile dekhna
└── settings_screen.dart


📱 Bottom Tab Navigation (5 Tabs via main_scaffold.dart)

The features/navigation/screens/main_scaffold.dart acts as the master container. It will manage the state and display these 5 primary tabs:

Home (features/home/screens/home_screen.dart)

Matches (features/matches/screens/matches_screen.dart)

Interest (features/interests/screens/interests_screen.dart)

Chat (features/chat/screens/chat_list_screen.dart)

VIP/Upgrade (features/premium/screens/upgrade_screen.dart)

💡 Key Improvements & Philosophy:

Separation of Concerns: core/ handles the foundation, shared/ holds reusable UI components, and features/ isolates business logic.

Scalability: New features get their own folder under features/ without cluttering existing code.

Routing Ready: Fully integrated with GoRouter for deep linking and declarative navigation.

Premium UX Default: Base widgets like CustomToast, GlassContainer, and PremiumListTile ensure high-end visuals across the entire app.