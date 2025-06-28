import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:medication_reminder/helpers/database_helper.dart';
import 'package:medication_reminder/providers/theme_provider.dart';
import 'package:medication_reminder/screens/main_navigation_screen.dart';
import 'package:medication_reminder/services/notification_service.dart';
import 'package:medication_reminder/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure that plugin services are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize notification service
  await NotificationService().init();
  await DatabaseHelper().database; // Ensure database is initialized
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'تذكير الدواء',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', 'EG'), // Arabic, Egypt
            ],
            locale: const Locale('ar', 'EG'), // Set the default locale to Arabic
            home: const MainNavigationScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
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
