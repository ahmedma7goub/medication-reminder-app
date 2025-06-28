import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/medicine.dart';
import '../services/notification_service.dart';

class AddEditMedicineScreen extends StatefulWidget {
  final Medicine? medicine;

  const AddEditMedicineScreen({super.key, this.medicine});

  @override
  State<AddEditMedicineScreen> createState() => _AddEditMedicineScreenState();
}

class _AddEditMedicineScreenState extends State<AddEditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _dosage;
  TimeOfDay? _selectedTime;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.medicine != null) {
      _name = widget.medicine!.name;
      _dosage = widget.medicine!.dosage;
      // For simplicity, we'll just handle one time for now
      final timeParts = widget.medicine!.times.first.split(':');
      _selectedTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
    } else {
      _name = '';
      _dosage = '';
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

    void _saveMedicine() async {
    if (_formKey.currentState!.validate() && _selectedTime != null) {
      _formKey.currentState!.save();

      final medicineToSave = Medicine(
        id: widget.medicine?.id,
        name: _name,
        dosage: _dosage,
        scheduleType: 'daily', // Hardcoded for simplicity
        times: ["${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}"],
      );

      int medicineId;
      if (widget.medicine == null) {
        // Insert new medicine and get its ID
        medicineId = await _dbHelper.insertMedicine(medicineToSave);
      } else {
        // Update existing medicine
        medicineId = widget.medicine!.id!;
        await _dbHelper.updateMedicine(medicineToSave);
      }

      // Schedule the notification
      final now = DateTime.now();
      var scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      
      // If the time is in the past for today, schedule it for tomorrow
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await NotificationService().scheduleNotification(
        medicineId, // Use the real ID
        'حان وقت الدواء: $_name',
        'الجرعة: $_dosage',
        scheduledTime,
      );
      
      if (mounted) {
        Navigator.pop(context);
      }

    } else if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار وقت التذكير')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicine == null ? 'إضافة دواء جديد' : 'تعديل الدواء'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'اسم الدواء'),
                validator: (value) => value!.isEmpty ? 'الرجاء إدخال اسم الدواء' : null,
                onSaved: (value) => _name = value!,
                textDirection: TextDirection.rtl,
              ),
              TextFormField(
                initialValue: _dosage,
                decoration: const InputDecoration(labelText: 'الجرعة (مثال: 1 حبة)'),
                validator: (value) => value!.isEmpty ? 'الرجاء إدخال الجرعة' : null,
                onSaved: (value) => _dosage = value!,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedTime == null
                        ? 'لم يتم اختيار وقت'
                        : 'الوقت المحدد: ${_selectedTime!.format(context)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  ElevatedButton(
                    onPressed: _pickTime,
                    child: const Text('اختر الوقت'),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saveMedicine,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text('حفظ', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
