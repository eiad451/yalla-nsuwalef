import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/sodfa_styles.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final auth = Get.find<AuthProvider>();
  final api = Get.find<ApiService>();

  final profiles = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final currentIndex = 0.obs;
  final ageRange = Rx<RangeValues>(RangeValues(18, 50));
  final selectedGender = 'all'.obs;

  @override
  void initState() {
    super.initState();
    fetchProfiles();
  }

  Future<void> fetchProfiles() async {
    try {
      isLoading.value = true;
      final response = await api.get('discover/profiles', query: {
        'minAge': ageRange.value.start.round().toString(),
        'maxAge': ageRange.value.end.round().toString(),
        if (selectedGender.value != 'all') 'gender': selectedGender.value,
      });
      profiles.value = (response['profiles'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      profiles.value = _generateMockProfiles();
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> _generateMockProfiles() {
    return List.generate(10, (i) {
      final names = ['سارة', 'نور', 'مريم', 'آية', 'رنا', 'ليان', 'جنى', 'تالا', 'حلا', 'شهد'];
      final bios = [
        'أحب السفر والموسيقى',
        'طالبة جامعية 🎓',
        'مهندسة معمارية',
        'أبحث عن أصدقاء جدد',
        'عاشقة للكتب والقهوة ☕',
      ];
      return {
        'id': 'mock_$i',
        'displayName': names[i % names.length],
        'avatar': '',
        'bio': bios[i % bios.length],
        'age': 20 + i * 2,
        'country': 'العراق',
        'isOnline': i % 3 == 0,
        'tags': ['صداقة', 'تعارف'].take(i % 2 + 1).toList(),
      };
    });
  }

  void _likeProfile(Map<String, dynamic> profile) {
    if (currentIndex.value < profiles.length - 1) {
      currentIndex.value++;
    } else {
      Get.snackbar(
        'انتهى التصفح',
        'لا يوجد المزيد من الملفات الشخصية',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _passProfile(Map<String, dynamic> profile) {
    if (currentIndex.value < profiles.length - 1) {
      currentIndex.value++;
    } else {
      Get.snackbar(
        'انتهى التصفح',
        'لا يوجد المزيد من الملفات الشخصية',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showFilterDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text('فلترة البحث',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('الفئة العمرية',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            Obx(() => RangeSlider(
                  values: ageRange.value,
                  min: 16,
                  max: 70,
                  divisions: 54,
                  labels: RangeLabels(
                    '${ageRange.value.start.round()}',
                    '${ageRange.value.end.round()}',
                  ),
                  activeColor: SodfaStyles.primaryPurple,
                  onChanged: (v) => ageRange.value = v,
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${ageRange.value.start.round()} سنة',
                    style: const TextStyle(color: SodfaStyles.textHint)),
                Text('${ageRange.value.end.round()} سنة',
                    style: const TextStyle(color: SodfaStyles.textHint)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('الجنس',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Obx(() => Row(
                  children: [
                    _buildGenderChip('الكل', 'all'),
                    const SizedBox(width: 8),
                    _buildGenderChip('ذكر', 'male'),
                    const SizedBox(width: 8),
                    _buildGenderChip('أنثى', 'female'),
                  ],
                )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  fetchProfiles();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: SodfaStyles.primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('تطبيق الفلتر',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderChip(String label, String value) {
    final isSelected = selectedGender.value == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        selectedGender.value = value;
      },
      selectedColor: SodfaStyles.primaryPurple,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : SodfaStyles.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SodfaStyles.backgroundLight,
      appBar: AppBar(
        title: const Text('تعارف'),
        backgroundColor: SodfaStyles.primaryPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              Get.snackbar(
                'الإعجابات',
                'قريباً',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (isLoading.value && profiles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (profiles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline,
                    size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text(
                  'لا توجد ملفات شخصية',
                  style: TextStyle(
                      fontSize: 18, color: SodfaStyles.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  'حاول تغيير الفلتر',
                  style: TextStyle(
                      fontSize: 14, color: SodfaStyles.textHint),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: fetchProfiles,
                  icon: const Icon(Icons.refresh),
                  label: const Text('تحديث'),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    onPageChanged: (i) => currentIndex.value = i,
                    itemCount: profiles.length,
                    itemBuilder: (context, index) {
                      return _buildProfileCard(profiles[index]);
                    },
                  ),
                  Positioned(
                    bottom: 24,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionButton(
                          icon: Icons.close,
                          color: SodfaStyles.errorRed,
                          onTap: () => _passProfile(profiles[currentIndex.value]),
                        ),
                        const SizedBox(width: 24),
                        _buildActionButton(
                          icon: Icons.favorite,
                          color: SodfaStyles.accentPink,
                          onTap: () => _likeProfile(profiles[currentIndex.value]),
                          isBig: true,
                        ),
                        const SizedBox(width: 24),
                        _buildActionButton(
                          icon: Icons.star,
                          color: SodfaStyles.goldColor,
                          onTap: () {
                            Get.snackbar(
                              'نجمة ذهبية',
                              'قريباً',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> profile) {
    final name = profile['displayName'] ?? profile['username'] ?? 'مستخدم';
    final bio = profile['bio'] ?? '';
    final avatar = profile['avatar'] ?? '';
    final age = profile['age'];
    final country = profile['country'];
    final tags = (profile['tags'] as List?)?.cast<String>() ?? [];
    final isOnline = profile['isOnline'] ?? false;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: SodfaStyles.primaryPurple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(
                  colors: [
                    SodfaStyles.primaryPurple.withOpacity(0.1),
                    SodfaStyles.accentPink.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: SodfaStyles.primaryPurple.withOpacity(0.1),
                  backgroundImage:
                      avatar.isNotEmpty ? NetworkImage(avatar) : null,
                  child: avatar.isEmpty
                      ? Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 48,
                            color: SodfaStyles.primaryPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: SodfaStyles.textPrimary,
                          ),
                        ),
                      ),
                      if (isOnline)
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: SodfaStyles.successGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (age != null) ...[
                        Icon(Icons.cake,
                            size: 16,
                            color: SodfaStyles.textHint),
                        const SizedBox(width: 4),
                        Text('$age سنة',
                            style: const TextStyle(
                                color: SodfaStyles.textSecondary)),
                        const SizedBox(width: 12),
                      ],
                      Icon(Icons.location_on,
                          size: 16,
                          color: SodfaStyles.textHint),
                      const SizedBox(width: 4),
                      Text(country ?? 'العراق',
                          style: const TextStyle(
                              color: SodfaStyles.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (bio.isNotEmpty)
                    Text(
                      bio,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: SodfaStyles.textSecondary, fontSize: 14),
                    ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: tags.map((tag) => Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: SodfaStyles.primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 11,
                            color: SodfaStyles.primaryPurple,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isBig = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isBig ? 64 : 52,
        height: isBig ? 64 : 52,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: isBig ? 28 : 22),
      ),
    );
  }
}
