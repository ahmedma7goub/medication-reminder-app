import 'package:flutter/material.dart';
import 'package:medication_reminder/providers/theme_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('الملف الشخصي', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _buildProfileHeader(context),
          const SizedBox(height: 30),
          Text('الإعدادات', style: theme.textTheme.titleLarge?.copyWith(color: theme.textTheme.bodyMedium?.color)),
          const SizedBox(height: 10),
          _buildSettingsCard(context, themeProvider, theme),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'), // Placeholder image
          ),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('أحمد محجوب', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('ahmed.ma7goub@example.com', style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, ThemeProvider themeProvider, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('الوضع الداكن'),
            secondary: Icon(themeProvider.isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('إعدادات الإشعارات'),
            subtitle: const Text('فتح إعدادات النظام لهذا التطبيق'),
            onTap: () {
              openAppSettings(); // This is the key function from permission_handler
            },
          ),
        ],
      ),
    );
  }
}