import 'package:flutter/material.dart';
import 'package:medication_reminder/helpers/database_helper.dart';
import 'package:medication_reminder/models/medicine.dart';
import 'package:medication_reminder/screens/add_edit_medicine_screen.dart';
import 'package:medication_reminder/services/notification_service.dart';

class AllMedicinesScreen extends StatefulWidget {
  const AllMedicinesScreen({Key? key}) : super(key: key);

  @override
  _AllMedicinesScreenState createState() => _AllMedicinesScreenState();
}

class _AllMedicinesScreenState extends State<AllMedicinesScreen> {
  late Future<List<Medicine>> _medicinesFuture;

  @override
  void initState() {
    super.initState();
    _refreshMedicines();
  }

  void _refreshMedicines() {
    if (!mounted) return;
    setState(() {
      _medicinesFuture = DatabaseHelper().getMedicines();
    });
  }

  void _deleteMedicine(int id) async {
    await DatabaseHelper().deleteMedicine(id);
    await NotificationService().cancelNotification(id);
    _refreshMedicines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('كل الأدوية'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<Medicine>>(
        future: _medicinesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'لا توجد أدوية. قم بإضافة دواء جديد.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final medicine = snapshot.data![index];
              final stockColor = _getStockColor(context, medicine.stock);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  leading: CircleAvatar(
                    backgroundColor: stockColor.withOpacity(0.2),
                    child: Text(medicine.stock.toString(), style: TextStyle(color: stockColor, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(medicine.name, style: Theme.of(context).textTheme.titleLarge),
                  subtitle: Text('${medicine.type} - ${medicine.dosage}', style: Theme.of(context).textTheme.bodyMedium),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.redAccent.withOpacity(0.8)),
                    onPressed: () => _showDeleteConfirmation(context, medicine),
                  ),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddEditMedicineScreen(medicine: medicine),
                      ),
                    );
                    _refreshMedicines();
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditMedicineScreen(),
            ),
          );
          _refreshMedicines();
        },
        label: const Text('إضافة دواء'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Color _getStockColor(BuildContext context, int stock) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (stock == 0) {
      return isDarkMode ? Colors.redAccent[100]! : Colors.red;
    } else if (stock <= 10) {
      return isDarkMode ? Colors.orangeAccent[100]! : Colors.orange;
    } else {
      return isDarkMode ? Colors.greenAccent[400]! : Colors.green;
    }
  }

  void _showDeleteConfirmation(BuildContext context, Medicine medicine) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من رغبتك في حذف دواء ${medicine.name}؟'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('حذف', style: TextStyle(color: Colors.red[400])),
              onPressed: () {
                _deleteMedicine(medicine.id!);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
