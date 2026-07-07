import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../providers/auth_provider.dart';
import '../../providers/room_provider.dart';
import '../../models/room_model.dart';
import '../../services/socket_service.dart';
import '../../utils/sodfa_styles.dart';

class VoiceRoomScreen extends StatefulWidget {
  const VoiceRoomScreen({super.key});

  @override
  State<VoiceRoomScreen> createState() => _VoiceRoomScreenState();
}

class _VoiceRoomScreenState extends State<VoiceRoomScreen>
    with SingleTickerProviderStateMixin {
  final roomProvider = Get.find<RoomProvider>();
  final auth = Get.find<AuthProvider>();
  final socketService = Get.find<SocketService>();
  late TabController _tabController;

  final activeVoiceRooms = <RoomModel>[].obs;
  final isMicOn = false.obs;
  final isSpeakerOn = true.obs;
  final isInVoiceRoom = false.obs;
  Rx<RoomModel?> currentVoiceRoom = Rx<RoomModel?>(null);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadVoiceRooms();
  }

  void _loadVoiceRooms() {
    final allRooms = roomProvider.rooms;
    activeVoiceRooms.value = allRooms
        .where((r) => r.type == 'voice' || r.category == 'voice')
        .toList();
  }

  void _joinVoiceRoom(RoomModel room) {
    currentVoiceRoom.value = room;
    isInVoiceRoom.value = true;
    socketService.joinRoom(room.id);
    Get.snackbar(
      'انضممت إلى الغرفة الصوتية',
      room.name,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: SodfaStyles.successGreen.withOpacity(0.9),
      colorText: Colors.white,
    );
  }

  void _leaveVoiceRoom() {
    if (currentVoiceRoom.value != null) {
      socketService.leaveRoom(currentVoiceRoom.value!.id);
    }
    isInVoiceRoom.value = false;
    currentVoiceRoom.value = null;
    isMicOn.value = false;
  }

  void _toggleMic() {
    isMicOn.value = !isMicOn.value;
  }

  void _toggleSpeaker() {
    isSpeakerOn.value = !isSpeakerOn.value;
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (isInVoiceRoom.value) _leaveVoiceRoom();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SodfaStyles.backgroundLight,
      appBar: AppBar(
        title: const Text('الغرف الصوتية'),
        elevation: 0,
        backgroundColor: SodfaStyles.primaryPurple,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'الغرف النشطة', icon: Icon(Icons.wifi_tethering)),
            Tab(text: 'المتحدثون', icon: Icon(Icons.record_voice_over)),
          ],
        ),
      ),
      body: Obx(() {
        if (isInVoiceRoom.value && currentVoiceRoom.value != null) {
          return _buildActiveVoiceCall();
        }
        return TabBarView(
          controller: _tabController,
          children: [
            _buildVoiceRoomsList(),
            _buildSpeakersList(),
          ],
        );
      }),
    );
  }

  Widget _buildVoiceRoomsList() {
    return Obx(() {
      if (activeVoiceRooms.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_tethering,
                  size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'لا توجد غرف صوتية نشطة',
                style: TextStyle(
                    color: SodfaStyles.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'أنشئ غرفة صوتية أو انتظر دعوة',
                style: TextStyle(
                    color: SodfaStyles.textHint, fontSize: 13),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => _loadVoiceRooms(),
        child: ListView.builder(
          padding: SodfaStyles.listPadding.copyWith(top: 12),
          itemCount: activeVoiceRooms.length,
          itemBuilder: (context, index) {
            return _buildVoiceRoomCard(activeVoiceRooms[index]);
          },
        ),
      );
    });
  }

  Widget _buildVoiceRoomCard(RoomModel room) {
    final memberAvatars = <String>[];
    if (room.createdByAvatar != null && room.createdByAvatar!.isNotEmpty) {
      memberAvatars.add(room.createdByAvatar!);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: SodfaStyles.voiceRoomDecoration,
      child: InkWell(
        borderRadius: BorderRadius.circular(SodfaStyles.cardBorderRadius),
        onTap: () => _joinVoiceRoom(room),
        child: Padding(
          padding: SodfaStyles.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: SodfaStyles.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.wifi_tethering,
                      color: SodfaStyles.primaryPurple,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: SodfaStyles.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.people,
                                size: 14, color: SodfaStyles.textHint),
                            const SizedBox(width: 4),
                            Text(
                              '${room.memberCount} مستمع',
                              style: const TextStyle(
                                  fontSize: 12, color: SodfaStyles.textHint),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: SodfaStyles.successGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'مباشر',
                              style: TextStyle(
                                  fontSize: 11, color: SodfaStyles.successGreen),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: SodfaStyles.primaryPurple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'انضمام',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
              if (memberAvatars.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 32,
                  child: Stack(
                    children: List.generate(
                      memberAvatars.take(5).length,
                      (i) => Positioned(
                        left: i * 24.0,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(memberAvatars[i]),
                          backgroundColor: SodfaStyles.primaryPurple.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeakersList() {
    final speakers = <Map<String, dynamic>>[
      {
        'name': 'المتحدث 1',
        'avatar': null,
        'isSpeaking': true,
        'room': 'غرفة السوالف',
      },
      {
        'name': 'المتحدث 2',
        'avatar': null,
        'isSpeaking': false,
        'room': 'غرفة الأصدقاء',
      },
    ];

    return ListView.builder(
      padding: SodfaStyles.listPadding.copyWith(top: 12),
      itemCount: speakers.length,
      itemBuilder: (context, index) {
        final speaker = speakers[index];
        final isSpeaking = speaker['isSpeaking'] as bool;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: SodfaStyles.glassCardDecoration,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 4),
            leading: Container(
              decoration: isSpeaking
                  ? SodfaStyles.activeSpeakerDecoration
                  : null,
              child: CircleAvatar(
                radius: SodfaStyles.avatarRadius,
                backgroundColor: SodfaStyles.primaryPurple.withOpacity(0.1),
                child: Text(
                  (speaker['name'] as String)[0],
                  style: const TextStyle(
                      color: SodfaStyles.primaryPurple,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            title: Text(
              speaker['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Row(
              children: [
                Icon(
                  isSpeaking ? Icons.wifi_tethering : Icons.mic_off,
                  size: 14,
                  color: isSpeaking
                      ? SodfaStyles.successGreen
                      : SodfaStyles.textHint,
                ),
                const SizedBox(width: 4),
                Text(
                  isSpeaking ? 'يتحدث الآن' : 'صامت',
                  style: TextStyle(
                    fontSize: 12,
                    color: isSpeaking
                        ? SodfaStyles.successGreen
                        : SodfaStyles.textHint,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  speaker['room'] as String,
                  style: const TextStyle(
                      fontSize: 12, color: SodfaStyles.textHint),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveVoiceCall() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [SodfaStyles.primaryPurple, SodfaStyles.primaryDark],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(
                  Icons.wifi_tethering,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                currentVoiceRoom.value?.name ?? 'الغرفة الصوتية',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${roomProvider.currentRoom.value?.memberCount ?? 0} مستمع',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7), fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCallControl(
                    icon: isMicOn.value ? Icons.mic : Icons.mic_off,
                    label: isMicOn.value ? 'كتم' : 'ميك',
                    color: isMicOn.value
                        ? SodfaStyles.primaryPurple
                        : SodfaStyles.errorRed,
                    onTap: _toggleMic,
                  ),
                  const SizedBox(width: 24),
                  _buildCallControl(
                    icon: Icons.call_end,
                    label: 'مغادرة',
                    color: SodfaStyles.errorRed,
                    onTap: _leaveVoiceRoom,
                    isBig: true,
                  ),
                  const SizedBox(width: 24),
                  _buildCallControl(
                    icon: isSpeakerOn.value
                        ? Icons.volume_up
                        : Icons.volume_off,
                    label: isSpeakerOn.value ? 'صوت' : 'كاتم',
                    color: isSpeakerOn.value
                        ? SodfaStyles.primaryPurple
                        : SodfaStyles.textHint,
                    onTap: _toggleSpeaker,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        Expanded(
          child: _buildParticipantsList(),
        ),
      ],
    );
  }

  Widget _buildCallControl({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isBig = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isBig ? 64 : 52,
            height: isBig ? 64 : 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: isBig ? 28 : 22),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildParticipantsList() {
    return Obx(() {
      final members = currentVoiceRoom.value?.members ?? [];
      if (members.isEmpty) {
        return Center(
          child: Text(
            'لا يوجد مشاركون',
            style: TextStyle(color: SodfaStyles.textHint),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          final name = member is Map
              ? (member['displayName'] ?? member['username'] ?? 'مستخدم')
              : 'مستخدم';
          final avatar = member is Map ? member['avatar'] : null;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              decoration: SodfaStyles.glassCardDecoration,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: SodfaStyles.primaryPurple.withOpacity(0.1),
                  backgroundImage:
                      avatar != null ? NetworkImage(avatar.toString()) : null,
                  child: avatar == null
                      ? Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(
                            color: SodfaStyles.primaryPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                title: Text(name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: SodfaStyles.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_tethering,
                          size: 12, color: SodfaStyles.successGreen),
                      SizedBox(width: 4),
                      Text('متصل',
                          style: TextStyle(
                              fontSize: 11, color: SodfaStyles.successGreen)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
