import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final api = Get.find<ApiService>();
  final auth = Get.find<AuthProvider>();
  Map<String, dynamic>? stats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final response = await api.get('admin/stats');
      setState(() {
        stats = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('لوحة التحكم')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('إحصائيات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard('المستخدمين', '${stats?['totalUsers'] ?? 0}', Icons.people, Colors.blue),
                        _buildStatCard('الغرف', '${stats?['totalRooms'] ?? 0}', Icons.chat, Colors.green),
                        _buildStatCard('الرسائل', '${stats?['totalMessages'] ?? 0}', Icons.message, Colors.orange),
                        _buildStatCard('نشطون', '${stats?['activeUsers'] ?? 0}', Icons.online_prediction, Colors.purple),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('إجراءات سريعة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.people, color: Colors.blue),
                            title: const Text('إدارة المستخدمين'),
                            trailing: const Icon(Icons.chevron_left),
                            onTap: () {},
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.chat, color: Colors.green),
                            title: const Text('إدارة الغرف'),
                            trailing: const Icon(Icons.chevron_left),
                            onTap: () {},
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.account_balance_wallet, color: Colors.orange),
                            title: const Text('إدارة المعاملات'),
                            trailing: const Icon(Icons.chevron_left),
                            onTap: () {},
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.add_circle, color: Colors.purple),
                            title: const Text('إضافة رصيد لمستخدم'),
                            trailing: const Icon(Icons.chevron_left),
                            onTap: () => _showAddBalanceDialog(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _showAddBalanceDialog() {
    final userIdController = TextEditingController();
    final amountController = TextEditingController();

    Get.dialog(AlertDialog(
      title: const Text('إضافة رصيد'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: userIdController,
            decoration: const InputDecoration(labelText: 'معرف المستخدم'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'المبلغ'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: () async {
            try {
              await api.post('wallet/admin/add-balance', body: {
                'userId': userIdController.text,
                'amount': double.parse(amountController.text),
                'description': 'إضافة رصيد من الإدارة',
              });
              Get.back();
              Get.snackbar('تم', 'تم إضافة الرصيد بنجاح', backgroundColor: Colors.green.shade100);
            } catch (e) {
              Get.snackbar('خطأ', e.toString(), backgroundColor: Colors.red.shade100);
            }
          },
          child: const Text('تأكيد'),
        ),
      ],
    ));
  }
}
