import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: const Center(
        child: Text('شاشة الملف الشخصي - سيتم بناؤها قريباً'),
      ),
    );
  }
}
