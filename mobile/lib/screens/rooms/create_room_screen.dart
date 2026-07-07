import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../providers/room_provider.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final passwordController = TextEditingController();
  final roomProvider = Get.find<RoomProvider>();

  String selectedCategory = 'عام';
  String selectedType = 'public';
  String selectedCountry = 'العراق';
  int maxMembers = 500;

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال اسم الغرفة', backgroundColor: Colors.red.shade100);
      return;
    }

    final room = await roomProvider.createRoom({
      'name': nameController.text.trim(),
      'description': descController.text.trim(),
      'type': selectedType,
      'category': selectedCategory,
      'password': selectedType == 'private' ? passwordController.text : '',
      'country': selectedCountry,
      'maxMembers': maxMembers,
    });

    if (room != null) {
      Get.snackbar('تم', 'تم إنشاء الغرفة بنجاح', backgroundColor: Colors.green.shade100);
      Get.back();
    } else {
      Get.snackbar('خطأ', roomProvider.error.value ?? 'حدث خطأ', backgroundColor: Colors.red.shade100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء غرفة جديدة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'اسم الغرفة *',
                hintText: 'أدخل اسم الغرفة',
                prefixIcon: Icon(Icons.chat),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'الوصف',
                hintText: 'وصف الغرفة (اختياري)',
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 16),
            const Text('نوع الغرفة', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('عام'),
                    selected: selectedType == 'public',
                    onSelected: (_) => setState(() => selectedType = 'public'),
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: selectedType == 'public' ? Colors.white : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('خاص'),
                    selected: selectedType == 'private',
                    onSelected: (_) => setState(() => selectedType = 'private'),
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: selectedType == 'private' ? Colors.white : null,
                    ),
                  ),
                ),
              ],
            ),
            if (selectedType == 'private') ...[
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  hintText: 'كلمة مرور الغرفة',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text('التصنيف', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField(
              value: selectedCategory,
              items: AppConstants.roomCategories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (value) => setState(() => selectedCategory = value ?? 'عام'),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 16),
            const Text('الحد الأقصى للأعضاء', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Slider(
              value: maxMembers.toDouble(),
              min: 10,
              max: 1000,
              divisions: 99,
              label: maxMembers.toString(),
              onChanged: (value) => setState(() => maxMembers = value.toInt()),
            ),
            Center(child: Text('$maxMembers عضو', style: const TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: roomProvider.isLoading.value ? null : _createRoom,
                child: roomProvider.isLoading.value
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('إنشاء الغرفة'),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
