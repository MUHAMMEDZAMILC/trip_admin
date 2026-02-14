import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:trip_admin/auth/splashpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // In release mode, send to crash reporting service
      debugPrint('Flutter Error: ${details.exception}');
    }
  };

  // Handle async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Platform Error: $error');
    return true;
  };

  // Run in zone to catch async errors
  runZonedGuarded(() async {
    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      
      try {
        await Firebase.initializeApp();
      } catch (e) {
        debugPrint('Firebase initialization error: $e');
        // Continue with app launch even if Firebase fails
      }

      runApp(const MyApp());
    } catch (e, stackTrace) {
      debugPrint('Error in main: $e');
      debugPrint('Stack trace: $stackTrace');
      // Still run the app even if there's an error
      runApp(const MyApp());
    }
  }, (error, stackTrace) {
    debugPrint('Uncaught error: $error');
    debugPrint('Stack trace: $stackTrace');
  });
}
class MyApp extends StatelessWidget { 
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
    );
  }
}


