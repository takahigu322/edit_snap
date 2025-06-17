import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'screens/start_screen.dart';
import 'package:edit_snap/start_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ← 追加
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations and system UI
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const EditSnapApp());
}

class EditSnapApp extends StatelessWidget {
  const EditSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edit Snap',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark, // Optimized for photo editing
      // home: const StartScreen(),
      // localizationsDelegates: AppLocalizations.localizationsDelegates, // ← 追加
      // supportedLocales: AppLocalizations.supportedLocales,             // ← 追加
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      home: const StartScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}