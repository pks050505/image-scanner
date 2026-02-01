import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:indian_ocean_scanner/dependency_provider.dart';
import 'package:indian_ocean_scanner/firebase_options.dart';

import 'features/scan/presentation/pages/scan_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DependencyProvider(
      child: MaterialApp(
        title: 'Menu Scanner',
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
        home: const ScanPage(),
      ),
    );
  }
}
