import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../services/socket_service.dart';
import '../../models/message_model.dart';
import '../../models/room_model.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final chatProvider = Get.find<ChatProvider>();
  final socketService = Get.find<SocketService>();
  final auth = Get.find<AuthProvider>();
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  late RoomModel room;

  @override
  void initState() {
    super.initState();
    room = Get.arguments as RoomModel;
    chatProvider.fetchMessages(room.id, refresh: true);
    socketService.joinRoom(room.id);
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    ever(socketService.onNewMessage, (data) {
      if (data != null && data['room']?.toString() == room.id) {
        final msg = MessageModel.fromJson(data);
        chatProvider.addMessage(msg);
        _scrollToBottom();
      }
    });

    ever(socketService.onMessageDeleted, (data) {
      if (data != null) {
        chatProvider.removeMessage(data['messageId']);
      }
    });
  }

  void _sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    socketService.sendMessage(roomId: room.id, content: text);
    messageController.clear();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    socketService.leaveRoom(room.id);
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(room.name, style: const TextStyle(fontSize: 16)),
            Text('${room.memberCount} عضو', style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () => _showRoomOptions()),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessagesList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return Obx(() {
      if (chatProvider.isLoading.value && chatProvider.messages.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      return ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: chatProvider.messages.length,
        itemBuilder: (context, index) {
          return _buildMessageBubble(chatProvider.messages[index]);
        },
      );
    });
  }

  Widget _buildMessageBubble(MessageModel message) {
    final isMe = message.sender == auth.user.value?.id;
    final isSystem = message.messageType == 'system';

    if (isSystem) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            message.content,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ),
      );
    }

    if (message.gift != null) {
      return _buildGiftMessage(message, isMe);
    }

    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(4) : const Radius.circular(16),
            bottomRight: isMe ? const Radius.circular(16) : const Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe && message.senderName != null)
              Text(
                message.senderName!,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : AppTheme.textColor,
                fontSize: 14,
              ),
            ),
            if (message.createdAt != null)
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  _formatTime(message.createdAt!),
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.grey.shade500,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGiftMessage(MessageModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.amber, Colors.orange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              message.gift!['icon'] ?? '🎁',
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 4),
            Text(
              message.gift!['name'] ?? 'هدية',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              '${message.gift!['price']} نقطة',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.emoji_emotions),
              onPressed: () {},
              color: AppTheme.primaryColor,
            ),
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: () {},
              color: AppTheme.primaryColor,
            ),
            Expanded(
              child: TextField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: 'اكتب رسالة...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 22,
              backgroundColor: AppTheme.primaryColor,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRoomOptions() {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('معلومات الغرفة'),
            onTap: () => Get.back(),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('الأعضاء'),
            onTap: () => Get.back(),
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('مشاركة'),
            onTap: () => Get.back(),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('مغادرة الغرفة', style: TextStyle(color: Colors.red)),
            onTap: () {
              Get.back();
              Get.find<RoomProvider>().leaveRoom(room.id);
              Get.back();
            },
          ),
        ],
      ),
    ));
  }

  String _formatTime(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}
