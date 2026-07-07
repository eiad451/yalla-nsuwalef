import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';

class RechargeScreen extends StatefulWidget {
  const RechargeScreen({super.key});

  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  final walletProvider = Get.find<WalletProvider>();
  final phoneController = TextEditingController();
  String selectedAmount = '5000';
  String selectedMethod = 'zain_cash';

  final List<Map<String, dynamic>> amounts = [
    {'label': '1,000', 'value': '1000', 'bonus': '0'},
    {'label': '5,000', 'value': '5000', 'bonus': '500'},
    {'label': '10,000', 'value': '10000', 'bonus': '2,000'},
    {'label': '25,000', 'value': '25000', 'bonus': '5,000'},
    {'label': '50,000', 'value': '50000', 'bonus': '10,000'},
    {'label': '100,000', 'value': '100000', 'bonus': '30,000'},
  ];

  final List<Map<String, String>> methods = [
    {'id': 'zain_cash', 'name': 'زين كاش', 'icon': '💳'},
    {'id': 'asia_cell', 'name': 'آسيا سيل', 'icon': '💳'},
    {'id': 'korek', 'name': 'كورك', 'icon': '💳'},
    {'id': 'mastercard', 'name': 'Mastercard', 'icon': '💳'},
  ];

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _recharge() async {
    final success = await walletProvider.recharge(
      double.parse(selectedAmount),
      selectedMethod,
      phoneController.text.trim(),
    );
    if (success) {
      Get.dialog(AlertDialog(
        title: const Text('تم تقديم طلب الشحن'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text('قم بإرسال $selectedAmount دينار إلى رقم المطور'),
            const SizedBox(height: 8),
            const Text('07744572152', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            const SizedBox(height: 8),
            Text('عبر $selectedMethod', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: const Text('تم'),
          ),
        ],
      ));
    } else {
      Get.snackbar('خطأ', walletProvider.error.value ?? 'حدث خطأ', backgroundColor: Colors.red.shade100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('شحن الرصيد')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('اختر المبلغ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: amounts.length,
              itemBuilder: (context, index) {
                final item = amounts[index];
                final isSelected = selectedAmount == item['value'];
                return GestureDetector(
                  onTap: () => setState(() => selectedAmount = item['value'] as String),
                  child: Card(
                    color: isSelected ? AppTheme.primaryColor : Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${item['label']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isSelected ? Colors.white : AppTheme.textColor,
                          ),
                        ),
                        Text(
                          'دينار',
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white70 : Colors.grey.shade600,
                          ),
                        ),
                        if (item['bonus'] != '0')
                          Text(
                            '+${item['bonus']}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? Colors.amber.shade200 : Colors.orange,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text('طريقة الدفع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...methods.map((method) {
              final isSelected = selectedMethod == method['id'];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: RadioListTile<String>(
                  title: Text('${method['icon']} ${method['name']}'),
                  value: method['id'] as String,
                  groupValue: selectedMethod,
                  onChanged: (v) => setState(() => selectedMethod = v!),
                  activeColor: AppTheme.primaryColor,
                ),
              );
            }),
            const SizedBox(height: 24),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'رقم هاتفك (للتأكيد)',
                hintText: '07701234567',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'بعد الدفع، سيتم إضافة الرصيد تلقائياً. رقم المطور: ${AppConstants.devPhone}',
                        style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: walletProvider.isLoading.value ? null : _recharge,
                child: walletProvider.isLoading.value
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('شحن $selectedAmount دينار'),
              )),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'رقم المطور للشحن: ${AppConstants.devPhone}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
