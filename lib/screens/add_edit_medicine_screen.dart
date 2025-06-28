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
  late String _type;
  late int _stock;
  late String _scheduleType;
  List<String> _days = [];
  List<TimeOfDay> _times = [];

  final List<String> _medicineTypes = ['حبة', 'شراب', 'حقنة', 'أخرى'];
  final List<String> _weekDays = ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];

  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _type = _medicineTypes[0];
    _scheduleType = 'daily';
    if (widget.medicine != null) {
      _name = widget.medicine!.name;
      _dosage = widget.medicine!.dosage;
      _type = widget.medicine!.type;
      _stock = widget.medicine!.stock;
      _scheduleType = widget.medicine!.scheduleType;
      _days = widget.medicine!.days ?? [];
      _times = widget.medicine!.times.map((timeStr) {
        final parts = timeStr.split(':');
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }).toList();
    } else {
      _name = '';
      _dosage = '';
      _stock = 0;
      _times = [const TimeOfDay(hour: 8, minute: 0)];
    }
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newMedicine = Medicine(
        id: widget.medicine?.id,
        name: _name,
        dosage: _dosage,
        type: _type,
        stock: _stock,
        scheduleType: _scheduleType,
        days: _scheduleType == 'specific_days' ? _days : null,
        times: _times.map((time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}').toList(),
      );

      if (widget.medicine == null) {
        final id = await _dbHelper.insertMedicine(newMedicine);
        newMedicine.id = id;
      } else {
        await _dbHelper.updateMedicine(newMedicine);
      }

      // Schedule notifications
      await NotificationService().cancelNotification(newMedicine.id!);
      for (var timeStr in newMedicine.times) {
        final timeParts = timeStr.split(':');
        final time = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
        await NotificationService().scheduleDailyNotification(
          id: newMedicine.id!,
          title: 'تذكير بجرعة الدواء',
          body: 'حان الآن موعد تناول دواء ${newMedicine.name}',
          time: time,
        );
      }

      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicine == null ? 'إضافة دواء جديد' : 'تعديل الدواء'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            TextFormField(
              initialValue: _name,
              decoration: inputDecoration.copyWith(labelText: 'اسم الدواء'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال اسم الدواء';
                }
                return null;
              },
              onSaved: (value) => _name = value!,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _dosage,
              decoration: inputDecoration.copyWith(labelText: 'الجرعة (مثال: حبة واحدة)'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال الجرعة';
                }
                return null;
              },
              onSaved: (value) => _dosage = value!,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _type,
                    decoration: inputDecoration.copyWith(labelText: 'النوع'),
                    items: _medicineTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: textTheme.bodyMedium),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _type = newValue!;
                      });
                    },
                    style: textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: _stock.toString(),
                    decoration: inputDecoration.copyWith(labelText: 'المخزون'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || int.tryParse(value) == null) {
                        return 'رقم';
                      }
                      return null;
                    },
                    onSaved: (value) => _stock = int.parse(value!),
                    style: textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('مواعيد الدواء', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ..._buildTimePickers(),
                    TextButton.icon(
                      icon: const Icon(Icons.add_alarm_outlined),
                      label: const Text('إضافة موعد آخر'),
                      onPressed: () {
                        setState(() {
                          _times.add(const TimeOfDay(hour: 20, minute: 0));
                        });
                      },
                      style: TextButton.styleFrom(
                        primary: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saveForm,
              icon: const Icon(Icons.save_alt_outlined),
              label: const Text('حفظ'),
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTimePickers() {
    return _times.asMap().entries.map((entry) {
      int idx = entry.key;
      TimeOfDay time = entry.value;
      return ListTile(
        leading: const Icon(Icons.access_time),
        title: Text('الوقت ${idx + 1}: ${time.format(context)}', style: Theme.of(context).textTheme.bodyMedium),
        trailing: _times.length > 1
            ? IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                onPressed: () {
                  setState(() {
                    _times.removeAt(idx);
                  });
                },
              )
            : null,
        onTap: () async {
          final newTime = await showTimePicker(
            context: context,
            initialTime: time,
          );
          if (newTime != null) {
            setState(() {
              _times[idx] = newTime;
            });
          }
        },
      );
    }).toList();
  }
}
