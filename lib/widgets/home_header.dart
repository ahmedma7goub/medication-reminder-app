import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medication_reminder/providers/theme_provider.dart';

class HomeHeader extends StatelessWidget {
  final int medicineCount;
  final double progress;
  final int takenDoses;

  const HomeHeader({
    Key? key,
    required this.medicineCount,
    required this.progress,
    required this.takenDoses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.medication_liquid_outlined, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('مرحباً، أحمد', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                      const SizedBox(height: 4),
                      Text('اليوم لديك $medicineCount أدوية', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                    ],
                  ),
                ]
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_outlined, color: Colors.white, size: 28),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(
                      themeProvider.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      themeProvider.toggleTheme();
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          Text('تقدم اليوم', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 12),
              Text('${(progress * 100).toInt()}%', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text('تم تناول $takenDoses من $medicineCount أدوية', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }
}
