import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('الملف الشخصي')),
      body: Obx(() {
        final user = auth.user.value;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        backgroundImage: user.avatar.isNotEmpty
                            ? NetworkImage(user.avatar)
                            : null,
                        child: user.avatar.isEmpty
                            ? Text(
                                user.displayName.isNotEmpty
                                    ? user.displayName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 32,
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.displayName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${user.username}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      if (user.bio.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(user.bio, style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    _buildProfileTile(Icons.wallet, 'الرصيد', '${user.balance.toStringAsFixed(0)} نقطة'),
                    const Divider(height: 1),
                    _buildProfileTile(Icons.phone, 'رقم الهاتف', user.phone ?? 'غير مسجل'),
                    const Divider(height: 1),
                    _buildProfileTile(Icons.email, 'البريد الإلكتروني', user.email ?? 'غير مسجل'),
                    const Divider(height: 1),
                    _buildProfileTile(Icons.public, 'الدولة', user.country),
                    const Divider(height: 1),
                    _buildProfileTile(Icons.admin_panel_settings, 'الدور', user.role),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    if (user.role == 'admin' || user.role == 'dev')
                      ListTile(
                        leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
                        title: const Text('لوحة التحكم'),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () => Get.toNamed('/admin'),
                      ),
                    ListTile(
                      leading: const Icon(Icons.dark_mode),
                      title: const Text('الوضع الليلي'),
                      trailing: Switch(
                        value: false,
                        onChanged: (v) {},
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('الإصدار'),
                      trailing: const Text('1.0.0'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => auth.logout(),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'رقم المطور: 07744572152',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      trailing: Text(value, style: TextStyle(color: Colors.grey.shade600)),
    );
  }
}
