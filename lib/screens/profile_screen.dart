import 'package:flutter/material.dart';
import 'package:medication_reminder/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 32),
          _buildOptionList(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return const Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.teal,
          child: Icon(Icons.person, size: 60, color: Colors.white),
        ),
        SizedBox(height: 16),
        Text(
          'أحمد محمود',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          'ahmed.mahmoud@email.com',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildOptionList(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('الوضع الداكن'),
            secondary: Icon(isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
            value: isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),
          _buildOptionTile(context, icon: Icons.settings_outlined, title: 'الإعدادات', onTap: () {}),
          _buildOptionTile(context, icon: Icons.notifications_outlined, title: 'إدارة التنبيهات', onTap: () {}),
          _buildOptionTile(context, icon: Icons.download_outlined, title: 'تصدير البيانات', onTap: () {}),
          _buildOptionTile(context, icon: Icons.help_outline, title: 'المساعدة والدعم', onTap: () {}),
          _buildOptionTile(context, icon: Icons.info_outline, title: 'عن التطبيق', onTap: () {}),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildOptionTile(context, icon: Icons.logout, title: 'تسجيل الخروج', isDestructive: true, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, {required IconData icon, required String title, bool isDestructive = false, required VoidCallback onTap}) {
    final color = isDestructive ? Colors.redAccent : Theme.of(context).textTheme.bodyText1?.color;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
