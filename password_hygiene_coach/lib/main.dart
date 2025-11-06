import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Only keep platform-specific SQLite imports necessary for main initialization
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; 

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
        useMaterial3: true // Enables the latest Material Design 3 features and styling.
      ),
      home: const LessonCoachScreen(), // The starting screen of the application.
    );
  }
}

void main() {
  // 1. MUST BE FIRST: Initialize the Flutter binding
  // This ensures the necessary engine components are initialized before running the app or other async calls.
  WidgetsFlutterBinding.ensureInitialized(); 

  // 2. MUST BE SECOND: Set the database factory for desktop platforms
  // Checks if the app is NOT running on the web, AND if the platform is a recognized desktop OS.
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    
    // The sequence that triggers the sqflite warning but enables desktop support
    // Initializes the FFI (Foreign Function Interface) component of sqflite_common_ffi.
    sqfliteFfiInit(); 
    // Overrides the default database factory (which is often null or mobile-specific) 
    // with the FFI-based factory for desktop support.
    databaseFactory = databaseFactoryFfi; 
  }

  // 3. ONLY THEN: Run the app
  // Once platform bindings and database initialization are complete, start the Flutter UI.
  runApp(const PasswordHygieneCoachApp());
}