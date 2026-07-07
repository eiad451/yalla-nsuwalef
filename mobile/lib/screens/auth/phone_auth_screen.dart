import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final usernameController = TextEditingController();
  final auth = Get.find<AuthProvider>();
  bool showOtpField = false;

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال رقم الهاتف', backgroundColor: Colors.red.shade100);
      return;
    }
    final success = await auth.sendOtp(phone);
    if (success) {
      setState(() => showOtpField = true);
      Get.snackbar('تم', 'تم إرسال رمز التحقق', backgroundColor: Colors.green.shade100);
    } else {
      Get.snackbar('خطأ', auth.error.value ?? 'حدث خطأ', backgroundColor: Colors.red.shade100);
    }
  }

  Future<void> _verifyOtp() async {
    final phone = phoneController.text.trim();
    final otp = otpController.text.trim();
    if (otp.isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال رمز التحقق', backgroundColor: Colors.red.shade100);
      return;
    }
    final success = await auth.verifyOtp(phone, otp, username: usernameController.text.trim());
    if (success) {
      Get.offAllNamed('/home');
    } else {
      Get.snackbar('خطأ', auth.error.value ?? 'رمز التحقق غير صحيح', backgroundColor: Colors.red.shade100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أدخل رقم هاتفك',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'سيتم إرسال رمز تحقق إلى رقمك',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف',
                hintText: '07701234567',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            if (showOtpField) ...[
              const SizedBox(height: 16),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المستخدم (اختياري)',
                  hintText: 'اسمك في التطبيق',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'رمز التحقق',
                  hintText: '123456',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: auth.isLoading.value ? null : (showOtpField ? _verifyOtp : _sendOtp),
                child: auth.isLoading.value
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(showOtpField ? 'تأكيد' : 'إرسال رمز التحقق'),
              )),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'رقم المطور: ${AppConstants.devPhone}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
