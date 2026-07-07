import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/theme.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final walletProvider = Get.find<WalletProvider>();
  final auth = Get.find<AuthProvider>();

  @override
  void initState() {
    super.initState();
    walletProvider.fetchBalance();
    walletProvider.fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('المحفظة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => walletProvider.fetchTransactions(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 16),
            _buildQuickActions(),
            const SizedBox(height: 16),
            _buildTransactionHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryColor, Color(0xFF8B83FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Text(
              'الرصيد الحالي',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
              '${walletProvider.balance.value.toStringAsFixed(0)} نقطة',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            )),
            const SizedBox(height: 8),
            Obx(() => Text(
              'إجمالي الشحن: ${walletProvider.totalRecharged.value.toStringAsFixed(0)} نقطة',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed('/recharge'),
                icon: const Icon(Icons.add),
                label: const Text('شحن الرصيد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: InkWell(
              onTap: () => Get.toNamed('/recharge'),
              borderRadius: BorderRadius.circular(16),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.add_circle, color: AppTheme.primaryColor, size: 32),
                    SizedBox(height: 8),
                    Text('شحن', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: InkWell(
              onTap: () {
                Get.snackbar('قريباً', 'قريباً', snackPosition: SnackPosition.BOTTOM);
              },
              borderRadius: BorderRadius.circular(16),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.card_giftcard, color: Colors.orange, size: 32),
                    SizedBox(height: 8),
                    Text('إرسال هدية', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: InkWell(
              onTap: () {
                Get.snackbar('رقم المطور', '07744572152', snackPosition: SnackPosition.BOTTOM);
              },
              borderRadius: BorderRadius.circular(16),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.support_agent, color: Colors.green, size: 32),
                    SizedBox(height: 8),
                    Text('الدعم', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionHistory() {
    return Obx(() {
      if (walletProvider.transactions.isEmpty) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.receipt_long, size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('لا توجد معاملات', style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            ),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('آخر المعاملات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...walletProvider.transactions.map((t) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: t['type'] == 'recharge' ? Colors.green.shade100 : Colors.orange.shade100,
                child: Icon(
                  t['type'] == 'recharge' ? Icons.add : Icons.remove,
                  color: t['type'] == 'recharge' ? Colors.green : Colors.orange,
                ),
              ),
              title: Text(t['description'] ?? t['type'] ?? ''),
              subtitle: Text(t['createdAt']?.toString() ?? ''),
              trailing: Text(
                '${t['amount'] > 0 ? '+' : ''}${t['amount']}',
                style: TextStyle(
                  color: t['amount'] > 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )),
        ],
      );
    });
  }
}
