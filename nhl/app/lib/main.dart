import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/games_list_screen.dart';
import 'theme/nhl_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform-specific options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // If Firebase is not configured, the app will show an error
    debugPrint('Firebase initialization error: $e');
  }

  runApp(const NHLApp());
}

class NHLApp extends StatelessWidget {
  const NHLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NHL Scores',
      theme: NHLTheme.darkTheme,
      home: const GamesListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
