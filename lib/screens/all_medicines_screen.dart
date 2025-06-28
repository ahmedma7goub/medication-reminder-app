import 'package:flutter/material.dart';

class AllMedicinesScreen extends StatelessWidget {
  const AllMedicinesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأدوية'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: const Center(
        child: Text('شاشة جميع الأدوية - سيتم بناؤها قريباً'),
      ),
    );
  }
}
