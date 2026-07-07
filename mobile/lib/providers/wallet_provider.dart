import 'package:get/get.dart';
import '../services/api_service.dart';

class WalletProvider extends GetxController {
  final api = Get.find<ApiService>();

  final balance = 0.0.obs;
  final totalRecharged = 0.0.obs;
  final transactions = <dynamic>[].obs;
  final isLoading = false.obs;
  final error = Rx<String?>(null);

  Future<void> fetchBalance() async {
    try {
      final response = await api.get('wallet/balance');
      balance.value = (response['balance'] ?? 0).toDouble();
      totalRecharged.value = (response['totalRecharged'] ?? 0).toDouble();
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> fetchTransactions({int page = 1}) async {
    try {
      isLoading.value = true;
      final response = await api.get('wallet/transactions', query: {
        'page': page.toString(),
        'limit': '20',
      });
      transactions.value = response['transactions'] as List;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> recharge(double amount, String paymentMethod, String phoneNumber) async {
    try {
      isLoading.value = true;
      await api.post('wallet/recharge', body: {
        'amount': amount,
        'paymentMethod': paymentMethod,
        'phoneNumber': phoneNumber,
      });
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
