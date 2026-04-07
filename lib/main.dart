import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool firebaseReady = false;

  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (error) {
    debugPrint('Firebase init failed: $error');
  }

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Something went wrong while rendering the app.',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  };

  runApp(MyApp(firebaseReady: firebaseReady));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.firebaseReady});

  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Tank App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Dashboard(firebaseReady: firebaseReady),
    );
  }
}

