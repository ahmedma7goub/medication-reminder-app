import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:medication_reminder/screens/main_navigation_screen.dart';
import 'package:medication_reminder/services/notification_service.dart';

void main() async {
  // Ensure that plugin services are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize notification service
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تذكير الدواء',
      debugShowCheckedModeBanner: false,
      // --- Add Arabic Support ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'EG'), // Arabic, Egypt
      ],
      locale: const Locale('ar', 'EG'), // Set the default locale to Arabic
      // -------------------------
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Cairo', // A good, readable Arabic font (you might need to add it to assets)
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.teal,
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}
