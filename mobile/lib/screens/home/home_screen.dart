import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../providers/auth_provider.dart';
import '../../providers/room_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../models/room_model.dart';
import '../../utils/sodfa_styles.dart';
import '../rooms/voice_room_screen.dart';
import '../discover/discover_screen.dart';
import '../wallet/wallet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final roomProvider = Get.find<RoomProvider>();
  final auth = Get.find<AuthProvider>();
  int currentNavIndex = 0;

  final List<Widget> _screens = [
    const _HomeTab(),
    const VoiceRoomScreen(),
    const DiscoverScreen(),
    const WalletScreen(),
  ];

  @override
  void initState() {
    super.initState();
    roomProvider.fetchRooms();
  }

  void switchToTab(int index) {
    setState(() => currentNavIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SodfaStyles.backgroundLight,
      body: IndexedStack(
        index: currentNavIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: SodfaStyles.primaryPurple.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentNavIndex,
        selectedItemColor: SodfaStyles.primaryPurple,
        unselectedItemColor: SodfaStyles.textHint,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.wifi_tethering_outlined),
            activeIcon: Icon(Icons.wifi_tethering),
            label: 'الغرف الصوتية',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'التعارف',
          ),
          BottomNavigationBarItem(
            icon: Obx(() => Badge(
                  isLabelVisible: (auth.user.value?.balance ?? 0) > 0,
                  label: Text(
                    '${auth.user.value?.balance.toInt() ?? 0}',
                    style: SodfaStyles.badgeText,
                  ),
                  child: const Icon(Icons.account_balance_wallet_outlined),
                )),
            activeIcon: Obx(() => Badge(
                  isLabelVisible: (auth.user.value?.balance ?? 0) > 0,
                  label: Text(
                    '${auth.user.value?.balance.toInt() ?? 0}',
                    style: SodfaStyles.badgeText,
                  ),
                  child: const Icon(Icons.account_balance_wallet),
                )),
            label: 'المحفظة',
          ),
        ],
        onTap: (index) {
          if (index == 3) {
            Get.find<WalletProvider>().fetchBalance();
          }
          setState(() => currentNavIndex = index);
        },
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final roomProvider = Get.find<RoomProvider>();
  final auth = Get.find<AuthProvider>();
  final searchController = TextEditingController();
  String selectedCategory = 'all';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SodfaStyles.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.chat, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Text('يلا نسوالف',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        backgroundColor: SodfaStyles.primaryPurple,
        elevation: 0,
        actions: [
          Obx(() => GestureDetector(
                onTap: () => Get.toNamed('/profile'),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage:
                        auth.user.value?.avatar != null &&
                                auth.user.value!.avatar.isNotEmpty
                            ? NetworkImage(auth.user.value!.avatar)
                            : null,
                    child: auth.user.value?.avatar == null ||
                            auth.user.value!.avatar.isEmpty
                        ? Text(
                            auth.user.value?.displayName.isNotEmpty == true
                                ? auth.user.value!.displayName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                ),
              )),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategories(),
          _buildVoiceRoomsSection(),
          _buildSectionHeader(),
          Expanded(child: _buildRoomsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/create-room'),
        backgroundColor: SodfaStyles.primaryPurple,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'ابحث عن غرفة...',
          prefixIcon: const Icon(Icons.search, color: SodfaStyles.textHint),
          suffixIcon: IconButton(
            icon: const Icon(Icons.filter_list, color: SodfaStyles.textHint),
            onPressed: () {},
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onSubmitted: (value) {
          roomProvider.fetchRooms(search: value);
        },
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      'الكل',
      'عام',
      'أصدقاء',
      'دراسة',
      'ألعاب',
      'رياضة',
      'تقنية',
      'ترفيه'
    ];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selectedCategory == cat ||
              (selectedCategory == 'all' && cat == 'الكل');
          return GestureDetector(
            onTap: () {
              setState(() =>
                  selectedCategory = cat == 'الكل' ? 'all' : cat);
              roomProvider.fetchRooms(category: selectedCategory);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? SodfaStyles.primaryPurple
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? SodfaStyles.primaryPurple
                      : SodfaStyles.dividerColor,
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : SodfaStyles.textSecondary,
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVoiceRoomsSection() {
    final voiceRooms = roomProvider.rooms
        .where((r) => r.type == 'voice' || r.category == 'voice')
        .toList();

    if (voiceRooms.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: SodfaStyles.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.wifi_tethering,
                    size: 16, color: SodfaStyles.primaryPurple),
              ),
              const SizedBox(width: 8),
              const Text(
                'الغرف الصوتية',
                style: SodfaStyles.sectionTitle,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  final homeState = context
                      .findAncestorStateOfType<_HomeScreenState>();
                  homeState?.switchToTab(1);
                },
                child: const Text(
                  'عرض الكل',
                  style: TextStyle(
                    color: SodfaStyles.primaryPurple,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: voiceRooms.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return _buildVoiceRoomMiniCard(voiceRooms[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceRoomMiniCard(RoomModel room) {
    return GestureDetector(
      onTap: () => Get.toNamed('/room', arguments: room),
      child: Container(
        width: 140,
        decoration: SodfaStyles.voiceRoomDecoration,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: SodfaStyles.successGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.wifi_tethering,
                        size: 16, color: SodfaStyles.successGreen),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: SodfaStyles.successGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('مباشر',
                        style: TextStyle(
                            fontSize: 9, color: SodfaStyles.successGreen)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                room.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.people,
                      size: 12, color: SodfaStyles.textHint),
                  const SizedBox(width: 4),
                  Text('${room.memberCount}',
                      style: const TextStyle(
                          fontSize: 11, color: SodfaStyles.textHint)),
                  const SizedBox(width: 8),
                  if (room.createdByAvatar != null &&
                      room.createdByAvatar!.isNotEmpty)
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: SodfaStyles.primaryPurple.withOpacity(0.1),
                      backgroundImage: NetworkImage(room.createdByAvatar!),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: SodfaStyles.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.chat_bubble_outline,
                size: 16, color: SodfaStyles.primaryPurple),
          ),
          const SizedBox(width: 8),
          const Text(
            'غرف النقاش',
            style: SodfaStyles.sectionTitle,
          ),
          const Spacer(),
          Obx(() => Text(
                '${roomProvider.rooms.length} غرفة',
                style: SodfaStyles.sectionSubtitle,
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
              Icon(Icons.chat_bubble_outline,
                  size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text('لا توجد غرف',
                  style: TextStyle(
                      color: SodfaStyles.textSecondary, fontSize: 18)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Get.toNamed('/create-room'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SodfaStyles.primaryPurple,
                ),
                child: const Text('إنشاء غرفة جديدة'),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: () => roomProvider.fetchRooms(),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: roomProvider.rooms.length,
          itemBuilder: (context, index) {
            return _buildRoomCard(roomProvider.rooms[index]);
          },
        ),
      );
    });
  }

  Widget _buildRoomCard(RoomModel room) {
    final isVoiceRoom = room.type == 'voice' || room.category == 'voice';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: SodfaStyles.glassCardDecoration,
      child: InkWell(
        borderRadius: BorderRadius.circular(SodfaStyles.cardBorderRadius),
        onTap: () => _joinRoom(room),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: SodfaStyles.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isVoiceRoom ? Icons.wifi_tethering : Icons.chat,
                  color: SodfaStyles.primaryPurple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            room.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: SodfaStyles.textPrimary,
                            ),
                          ),
                        ),
                        if (room.type == 'private')
                          const Icon(Icons.lock,
                              size: 14, color: SodfaStyles.softOrange),
                        if (isVoiceRoom) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: SodfaStyles.successGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('صوتي',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: SodfaStyles.successGreen)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.people,
                            size: 12, color: SodfaStyles.textHint),
                        const SizedBox(width: 4),
                        Text('${room.memberCount}',
                            style: const TextStyle(
                                fontSize: 11, color: SodfaStyles.textHint)),
                        if (room.description.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              room.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 11, color: SodfaStyles.textHint),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, color: SodfaStyles.textHint),
            ],
          ),
        ),
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
          TextButton(
              onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await roomProvider.joinRoom(room.id,
                  password: passController.text);
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
}
