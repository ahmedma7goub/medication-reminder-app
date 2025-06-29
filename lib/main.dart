import 'package:flutter/material.dart';
import 'package:medication_reminder/helpers/database_helper.dart'; 
import 'package:provider/provider.dart'; 
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:medication_reminder/providers/theme_provider.dart';
import 'package:medication_reminder/screens/all_medicines_screen.dart';
import 'package:medication_reminder/screens/home_screen.dart';
import 'package:medication_reminder/screens/profile_screen.dart';
import 'package:medication_reminder/screens/reports_screen.dart';
import 'package:medication_reminder/services/notification_service.dart';
import 'package:medication_reminder/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', ''), 
            ],
            locale: const Locale('ar'),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissions();
    });
  }

  Future<void> _checkPermissions() async {
    // Determine Android SDK version
    int sdkInt = 0;
    if (Platform.isAndroid) {
      final match = RegExp(r'SDK (\d+)').firstMatch(Platform.operatingSystemVersion);
      if (match != null) {
        sdkInt = int.parse(match.group(1)!);
      }
    }

    // Collect permissions we need to request
    final List<Permission> toRequest = [];
    if (sdkInt >= 33) {
      final status = await Permission.notification.status;
      if (status.isDenied) permissionsToRequest.add(Permission.notification);
    }

    if (sdkInt >= 31) {
      final status = await Permission.scheduleExactAlarm.status;
      if (status.isDenied) permissionsToRequest.add(Permission.scheduleExactAlarm);
    }

    if (permissionsToRequest.isNotEmpty)
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('إذن مهم مطلوب'),
          content: const Text(
            'يحتاج التطبيق إلى إذن الإشعارات والإنذارات ليرسل لك تذكيرات الأدوية في الوقت المناسب. يرجى تمكين هذه الأذونات.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('طلب الإذن'),
              onPressed: () async {
                Navigator.of(context).pop();
                await permissionsToRequest.request();
              },
            ),
            TextButton(
              child: const Text('فتح الإعدادات'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        ),
      );
        } else {
      // All required permissions already granted
      return;
    }
  }

            context: context,
            builder: (context) => AlertDialog(
                title: const Text("الإذن مطلوب"),
                content: const Text("لقد رفضت الإذن بشكل دائم. يرجى الانتقال إلى إعدادات التطبيق لتمكينه."),
                actions: [TextButton(onPressed: (){ Navigator.of(context).pop(); openAppSettings();}, child: const Text("فتح الإعدادات"))],
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
        type: Theme.of(context).bottomNavigationBarTheme.type,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        showUnselectedLabels: Theme.of(context).bottomNavigationBarTheme.showUnselectedLabels,
      ),
    );
  }
}