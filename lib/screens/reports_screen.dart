import 'package:flutter/material.dart';
import 'package:medication_reminder/helpers/database_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' as intl;

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late Future<Map<DateTime, int>> _adherenceFuture;

  @override
  void initState() {
    super.initState();
    _refreshAdherence();
  }

  void _refreshAdherence() {
    if (!mounted) return;
    setState(() {
      _adherenceFuture = DatabaseHelper().getAdherenceForLastWeek();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<Map<DateTime, int>>(
        future: _adherenceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('لا توجد بيانات لعرضها.', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)));
          }

          final adherenceData = snapshot.data!;
          final overallAdherence = adherenceData.isNotEmpty
              ? (adherenceData.values.reduce((a, b) => a + b) / (adherenceData.length * 100)) * 100
              : 0.0;

          return RefreshIndicator(
            onRefresh: () async => _refreshAdherence(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildOverallAdherenceCard(context, overallAdherence),
                const SizedBox(height: 24),
                _buildWeeklyAdherenceChart(context, adherenceData),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverallAdherenceCard(BuildContext context, double adherence) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.secondary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('معدل الالتزام الكلي', style: TextStyle(color: colorScheme.onSecondary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: adherence / 100,
                    strokeWidth: 10,
                    backgroundColor: colorScheme.onSecondary.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onSecondary),
                  ),
                ),
                Text('${adherence.toStringAsFixed(0)}%', style: TextStyle(color: colorScheme.onSecondary, fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyAdherenceChart(BuildContext context, Map<DateTime, int> data) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'الالتزام الأسبوعي',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBackgroundColor: Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.round()}%',
                          TextStyle(color: colorScheme.onSecondary, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final day = data.keys.elementAt(value.toInt());
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(intl.DateFormat('E', 'ar').format(day), style: textTheme.bodySmall),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text('${value.toInt()}%', style: textTheme.bodySmall),
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: textTheme.bodySmall!.color!.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  barGroups: data.entries.toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final value = entry.value.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: value.toDouble(),
                          color: colorScheme.primary,
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
