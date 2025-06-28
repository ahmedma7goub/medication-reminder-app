import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dummy data for demonstration
    final double overallAdherence = 0.85; // 85%
    final List<Map<String, String>> history = [
      {'medicine': 'بانادول', 'time': '8:00 ص', 'status': 'taken'},
      {'medicine': 'فيتامين د', 'time': '1:00 م', 'status': 'missed'},
      {'medicine': 'مضاد حيوي', 'time': '8:00 م', 'status': 'taken'},
      {'medicine': 'بانادول', 'time': 'أمس، 8:00 ص', 'status': 'taken'},
      {'medicine': 'فيتامين د', 'time': 'أمس، 1:00 م', 'status': 'taken'},
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('التقارير', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _buildAdherenceCard(theme, overallAdherence),
          const SizedBox(height: 24),
          _buildHistoryList(theme, history),
        ],
      ),
    );
  }

  Widget _buildAdherenceCard(ThemeData theme, double adherence) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الالتزام الإجمالي',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: adherence,
                      minHeight: 12,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${(adherence * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'معدل رائع! استمر في الالتزام بمواعيد دوائك.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(ThemeData theme, List<Map<String, String>> history) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'سجل الأدوية',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: theme.cardTheme.color,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              final isTaken = item['status'] == 'taken';
              return ListTile(
                leading: Icon(
                  isTaken ? Icons.check_circle_outline : Icons.highlight_off_outlined,
                  color: isTaken ? Colors.green.shade400 : Colors.red.shade400,
                  size: 28,
                ),
                title: Text(item['medicine']!, style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(item['time']!),
                trailing: Text(
                  isTaken ? 'تم أخذها' : 'تم تفويتها',
                  style: TextStyle(
                    color: isTaken ? Colors.green.shade400 : Colors.red.shade400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 20, endIndent: 20),
          ),
        ),
      ],
    );
  }
}
