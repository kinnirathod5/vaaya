import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🔥 Humara Theme aur Naya Router Import
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const BanjaraVivahApp());
}

class BanjaraVivahApp extends StatelessWidget {
  const BanjaraVivahApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🚀 DHYAN DEIN: MaterialApp ko badal kar MaterialApp.router kar diya hai
    return MaterialApp.router(
      title: 'Banjara Vivah',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // 🗺️ Yahan humne apne router ko app se jodd diya
      routerConfig: AppRouter.router,
    );
  }
}