import 'package:flutter/material.dart';
import 'package:medication_reminder/helpers/database_helper.dart'; 
import 'package:provider/provider.dart'; 
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
    // Use a short delay to ensure the UI is ready before showing dialogs
    await Future.delayed(const Duration(milliseconds: 500));

    // Create a list to track missing permissions
    final List<String> missingPermissions = [];

    // 1. Check Notification Permission (Android 13+)
    final notificationStatus = await Permission.notification.status;
    if (notificationStatus.isDenied || notificationStatus.isPermanentlyDenied) {
      missingPermissions.add('الإشعارات');
      await _showPermissionDialog(
        'إذن الإشعارات',
        'نحتاج إذن الإشعارات لنتمكن من إرسال تذكيرات الأدوية لك.',
        Permission.notification,
      );
    }

    // 2. Check Exact Alarm Permission (Android 12+)
    final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
    if (exactAlarmStatus.isDenied || exactAlarmStatus.isPermanentlyDenied) {
      missingPermissions.add('التنبيهات الدقيقة');
      await _showPermissionDialog(
        'إذن التنبيهات الدقيقة',
        'نحتاج هذا الإذن لضمان وصول تذكيراتك في الوقت المحدد بالضبط، حتى لو كان التطبيق مغلقًا.',
        Permission.scheduleExactAlarm,
      );
    }

    // 3. Check Battery Optimization Permission
    final batteryOptStatus = await Permission.ignoreBatteryOptimizations.status;
    if (!batteryOptStatus.isGranted) {
      missingPermissions.add('تجاوز تحسينات البطارية');
      await _showPermissionDialog(
        'تجاوز تحسينات البطارية',
        'لضمان عدم تأخير أو منع التذكيرات بسبب وضع توفير الطاقة في جهازك، يرجى السماح للتطبيق بالعمل في الخلفية.',
        Permission.ignoreBatteryOptimizations,
      );
    }

    // Show a summary of permission status if any are missing
    if (missingPermissions.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تنبيه: بعض الأذونات غير ممنوحة: ${missingPermissions.join(', ')}. '
            'قد لا تعمل التذكيرات بشكل صحيح.',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: 'الإعدادات',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    }
  }

  Future<void> _showPermissionDialog(String title, String content, Permission permission) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: const Text('لاحقاً'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('منح الإذن'),
            onPressed: () async {
              Navigator.of(context).pop();
              final status = await permission.request();
              if (status.isPermanentlyDenied) {
                await openAppSettings();
              }
            },
          ),
        ],
      ),
    );
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