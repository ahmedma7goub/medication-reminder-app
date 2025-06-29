import 'package:flutter/material.dart';
import 'package:medication_reminder/helpers/database_helper.dart';
import 'package:medication_reminder/models/dose_history.dart';
import 'package:medication_reminder/models/medicine.dart';
import 'package:medication_reminder/screens/add_edit_medicine_screen.dart';
import 'package:intl/intl.dart' as intl;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medication_reminder/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Medicine> _todaysMedicines = [];
  Map<int, int> _takenDosesCount = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final allMedicines = await DatabaseHelper().getMedicines();
    final today = DateTime.now();
    final todaysMeds = allMedicines.where((med) {
      // This logic can be expanded to handle 'specific_days'
      return med.scheduleType == 'daily';
    }).toList();

    final takenCounts = <int, int>{};
    for (var med in todaysMeds) {
      final doses = await DatabaseHelper().getDosesForDay(med.id!, today);
      takenCounts[med.id!] = doses.length;
    }

    if (mounted) {
      setState(() {
        _todaysMedicines = todaysMeds;
        _takenDosesCount = takenCounts;
        _isLoading = false;
      });
    }
  }

  int get _totalDosesToday {
    return _todaysMedicines.fold(0, (sum, med) => sum + med.times.length);
  }

  int get _totalDosesTaken {
    return _takenDosesCount.values.fold(0, (sum, count) => sum + count);
  }

  double get _progress {
    if (_totalDosesToday == 0) return 0.0;
    return _totalDosesTaken / _totalDosesToday;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildProgressCard(context),
                  const SizedBox(height: 24),
                  _buildActionButtons(context),
                  const SizedBox(height: 24),
                  _buildTodaysMedicinesList(context),
                ],
              ),
            ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    return Card(
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('مرحباً أحمد', style: TextStyle(color: onPrimaryColor, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('اليوم لديك $_totalDosesToday أدوية', style: TextStyle(color: onPrimaryColor.withOpacity(0.9), fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Text('تقدم اليوم', style: TextStyle(color: onPrimaryColor.withOpacity(0.9)))),
                Text('${(_progress * 100).toInt()}%', style: TextStyle(color: onPrimaryColor, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: onPrimaryColor.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(onPrimaryColor),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text('تم تناول $_totalDosesTaken من $_totalDosesToday أدوية', style: TextStyle(color: onPrimaryColor.withOpacity(0.9))),
          ],
        ),
      ),
    );
  }

  // Build action buttons including test notification
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          child: const Text('اختبار 30 ثانية'),
          onPressed: () async {
            final now = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 30));
            await NotificationService().flutterLocalNotificationsPlugin.zonedSchedule(
              9999,
              'تنبيه اختبار',
              'يفترض أن يظهر بعد ٣٠ ثانية',
              now,
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'medicine_channel_id',
                  'Medicine Reminders',
                  importance: Importance.max,
                  priority: Priority.high,
                ),
              ),
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              androidAllowWhileIdle: true,
            );
            // Show a confirmation message to the user
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم جدولة إشعار اختباري. سيظهر خلال 30 ثانية.'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: const Text('التقويم'),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('إضافة دواء'),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AddEditMedicineScreen()),
                  );
                  _refreshData();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodaysMedicinesList(BuildContext context) {
    final String today = intl.DateFormat('EEEE, d MMMM', 'ar').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('أدوية اليوم', style: Theme.of(context).textTheme.headlineSmall),
        Text(today, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)),
        const SizedBox(height: 16),
        if (_todaysMedicines.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('لا توجد أدوية مجدولة لليوم.', textAlign: TextAlign.center),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _todaysMedicines.length,
            itemBuilder: (context, index) {
              final medicine = _todaysMedicines[index];
              final takenCount = _takenDosesCount[medicine.id!] ?? 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(medicine.name, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text('${medicine.dosage} - ${medicine.type}', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      ...medicine.times.map((time) {
                        final isTimeSlotTaken = medicine.times.indexOf(time) < takenCount;
                        return ListTile(
                          leading: Icon(
                            isTimeSlotTaken ? Icons.check_circle : Icons.alarm,
                            color: isTimeSlotTaken ? Colors.green : Colors.orange,
                          ),
                          title: Text('الوقت: $time'),
                          trailing: ElevatedButton(
                            onPressed: isTimeSlotTaken
                                ? null
                                : () async {
                                    await DatabaseHelper().addDoseRecord(
                                      DoseHistory(medicineId: medicine.id!, takenAt: DateTime.now()),
                                    );
                                    _refreshData();
                                  },
                            child: const Text('تناول'),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
