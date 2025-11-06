import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Only keep platform-specific SQLite imports necessary for main initialization
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

// 🆕: imports new home screen
import 'screens/home_screen.dart';
import 'screens/LessonCoachScreen.dart';

// --- MAIN APP ENTRY POINT ---
/// The root widget of the application, defining its structure and theme.
class PasswordHygieneCoachApp extends StatelessWidget {
  const PasswordHygieneCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Hygiene Coach', // Title for the operating system's window/app switcher.
      debugShowCheckedModeBanner: false, // Hides the "DEBUG" banner in the corner.
      theme: ThemeData(
        primarySwatch: Colors.blue, // Sets a primary color swatch.
        useMaterial3: true, // Enables the latest Material Design 3 features and styling.
      ),

      home: const HomeScreen(),

    );
  }
}

void main() {
  // 1. MUST BE FIRST: Initialize the Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // 2. MUST BE SECOND: Set the database factory for desktop platforms
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 3. ONLY THEN: Run the app
  runApp(const PasswordHygieneCoachApp());
}
