import 'package:flutter/material.dart';
import 'package:medication_reminder/services/notification_service.dart';
import '../helpers/database_helper.dart';
import '../models/medicine.dart';
import 'add_edit_medicine_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Medicine>> _medicineList;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _updateMedicineList();
  }

  void _updateMedicineList() {
    setState(() {
      _medicineList = _dbHelper.getMedicines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تذكيراتي بالأدوية'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Medicine>>(
        future: _medicineList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'لم تتم إضافة أي أدوية بعد.\nاضغط على زر + للبدء.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Medicine medicine = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(medicine.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('الجرعة: ${medicine.dosage}\nالوقت: ${medicine.times.join(', ')}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Show a confirmation dialog before deleting
                      bool? deleted = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('تأكيد الحذف'),
                            content: const Text('هل أنت متأكد من رغبتك في حذف هذا الدواء؟'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('إلغاء'),
                                onPressed: () => Navigator.of(context).pop(false),
                              ),
                              TextButton(
                                child: const Text('حذف', style: TextStyle(color: Colors.red)),
                                onPressed: () async {
                                  await NotificationService().cancelNotification(medicine.id!); // Cancel notification
                                  Navigator.of(context).pop(true);
                                },
                              ),
                            ],
                          );
                        },
                      );

                      if (deleted == true) {
                        await _dbHelper.deleteMedicine(medicine.id!);
                        _updateMedicineList();
                      }
                    },
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditMedicineScreen(medicine: medicine),
                      ),
                    );
                    _updateMedicineList();
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditMedicineScreen()),
          );
          _updateMedicineList();
        },
        tooltip: 'إضافة دواء جديد',
        child: const Icon(Icons.add),
      ),
    );
  }
}
