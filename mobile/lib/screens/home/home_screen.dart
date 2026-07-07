import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../providers/auth_provider.dart';
import '../../providers/room_provider.dart';
import '../../models/room_model.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final roomProvider = Get.find<RoomProvider>();
  final auth = Get.find<AuthProvider>();
  final searchController = TextEditingController();
  String selectedCategory = 'all';
  String selectedCountry = 'all';

  @override
  void initState() {
    super.initState();
    roomProvider.fetchRooms();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('يلا نسوالف'),
        actions: [
          Obx(() => GestureDetector(
            onTap: () => Get.toNamed('/profile'),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: auth.user.value?.avatar != null && auth.user.value!.avatar.isNotEmpty
                  ? NetworkImage(auth.user.value!.avatar)
                  : null,
              child: auth.user.value?.avatar == null || auth.user.value!.avatar.isEmpty
                  ? Text(auth.user.value?.displayName.isNotEmpty == true
                      ? auth.user.value!.displayName[0].toUpperCase()
                      : 'U')
                  : null,
            ),
          )),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategories(),
          _buildCountries(),
          Expanded(child: _buildRoomsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/create-room'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'ابحث عن غرفة...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (value) {
          roomProvider.fetchRooms(search: value);
        },
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          'الكل', 'عام', 'أصدقاء', 'دراسة', 'ألعاب', 'رياضة', 'تقنية', 'ترفيه',
        ].map((cat) {
          final isSelected = selectedCategory == cat || (selectedCategory == 'all' && cat == 'الكل');
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (_) {
                setState(() => selectedCategory = cat == 'الكل' ? 'all' : cat);
                roomProvider.fetchRooms(category: selectedCategory);
              },
              selectedColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCountries() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.public, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text('العراق', style: TextStyle(color: Colors.grey.shade600)),
          const Spacer(),
          Obx(() => Text(
            '${roomProvider.rooms.length} غرفة',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          )),
        ],
      ),
    );
  }

  Widget _buildRoomsList() {
    return Obx(() {
      if (roomProvider.isLoading.value && roomProvider.rooms.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (roomProvider.rooms.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text('لا توجد غرف', style: TextStyle(color: Colors.grey.shade500, fontSize: 18)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Get.toNamed('/create-room'),
                child: const Text('إنشاء غرفة جديدة'),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: () => roomProvider.fetchRooms(),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: roomProvider.rooms.length,
          itemBuilder: (context, index) {
            return _buildRoomCard(roomProvider.rooms[index]);
          },
        ),
      );
    });
  }

  Widget _buildRoomCard(RoomModel room) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: Text(
            room.name.isNotEmpty ? room.name[0].toUpperCase() : 'R',
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          room.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (room.description.isNotEmpty)
              Text(room.description, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.people, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text('${room.memberCount}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                const SizedBox(width: 12),
                Icon(Icons.category, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(room.category, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                if (room.type == 'private') ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.lock, size: 14, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text('خاص', style: TextStyle(fontSize: 12, color: Colors.orange.shade700)),
                ],
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_left),
        onTap: () => _joinRoom(room),
      ),
    );
  }

  void _joinRoom(RoomModel room) {
    if (room.type == 'private') {
      final passController = TextEditingController();
      Get.dialog(AlertDialog(
        title: const Text('غرفة خاصة'),
        content: TextField(
          controller: passController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'كلمة المرور',
            hintText: 'أدخل كلمة المرور',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await roomProvider.joinRoom(room.id, password: passController.text);
              Get.toNamed('/room', arguments: room);
            },
            child: const Text('دخول'),
          ),
        ],
      ));
    } else {
      roomProvider.joinRoom(room.id);
      Get.toNamed('/room', arguments: room);
    }
  }

  Widget _buildBottomNav() {
    return Obx(() => BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: AppTheme.primaryColor,
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
        const BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'غرفتي'),
        BottomNavigationBarItem(
          icon: Obx(() => Badge(
            label: Text('${auth.user.value?.balance.toInt() ?? 0}'),
            child: const Icon(Icons.wallet),
          )),
          label: 'المحفظة',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'الملف'),
        if (auth.user.value?.role == 'admin' || auth.user.value?.role == 'dev')
          const BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'الإدارة'),
      ],
      onTap: (index) {
        switch (index) {
          case 0: break;
          case 1: Get.toNamed('/profile'); break;
          case 2: Get.toNamed('/wallet'); break;
          case 3: Get.toNamed('/profile'); break;
          case 4: Get.toNamed('/admin'); break;
        }
      },
    ));
  }
}
