import 'package:flutter/material.dart';
import 'package:medication_reminder/database/database_helper.dart';
import 'package.provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:medication_reminder/providers/theme_provider.dart';
import 'package:medication_reminder/screens/all_medicines_screen.dart';
import 'package:medication_reminder/screens/home_screen.dart';
import 'package:medication_reminder/screens/profile_screen.dart';
import 'package:medication_reminder/screens/reports_screen.dart';
import 'package:medication_reminder/services/notification_service.dart';
import 'package:medication_reminder/theme/app_theme.dart';

void main() async {
  // Ensure that plugin services are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize services
  await NotificationService().init();
  await DatabaseHelper().database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider()..initialize(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'تذكير الدواء',
            // --- START RTL and Localization Setup ---
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', ''), // Arabic
            ],
            locale: const Locale('ar'),
            // --- END RTL and Localization Setup ---
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    AllMedicinesScreen(),
    ReportsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // This will run after the first frame is displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissions();
    });
  }

  Future<void> _checkPermissions() async {
    // Check for both notification and exact alarm permissions
    final notificationStatus = await Permission.notification.status;
    final alarmStatus = await Permission.scheduleExactAlarm.status;

    // If either permission is denied or permanently denied, show a dialog
    if (notificationStatus.isDenied || alarmStatus.isDenied || notificationStatus.isPermanentlyDenied || alarmStatus.isPermanentlyDenied) {
      await showDialog(
        context: context,
        barrierDismissible: false, // User must interact with the dialog
        builder: (BuildContext context) => AlertDialog(
          title: const Text('إذن مهم مطلوب'),
          content: const Text(
            'يحتاج التطبيق إلى إذن الإشعارات والإنذارات ليرسل لك تذكيرات الأدوية في الوقت المناسب. يرجى تمكين هذه الأذونات في الإعدادات.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('فتح الإعدادات'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings(); // Opens the app settings page on the phone
              },
            ),
          ],
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // The MaterialApp locale handles the RTL direction automatically.
    // No need for a separate Directionality widget.
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            activeIcon: Icon(Icons.medical_services),
            label: 'الأدوية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'التقارير',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'الملف الشخصي',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // These styles are now correctly inherited from the AppTheme
        type: Theme.of(context).bottomNavigationBarTheme.type,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        showUnselectedLabels: Theme.of(context).bottomNavigationBarTheme.showUnselectedLabels,
      ),
    );
  }
}