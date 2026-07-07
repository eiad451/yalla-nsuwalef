import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';
import '../utils/constants.dart';

class SocketService extends GetxService {
  IO.Socket? socket;
  final isConnected = false.obs;
  final onNewMessage = Rx<Map<String, dynamic>?>(null);
  final onUserStatus = Rx<Map<String, dynamic>?>(null);
  final onTyping = Rx<Map<String, dynamic>?>(null);
  final onMessageDeleted = Rx<Map<String, dynamic>?>(null);
  final onUserJoined = Rx<Map<String, dynamic>?>(null);
  final onUserLeft = Rx<Map<String, dynamic>?>(null);

  void connect(String token) {
    socket = IO.io(AppConstants.socketUrl, {
      'transports': ['websocket'],
      'auth': {'token': token},
      'autoConnect': true,
    });

    socket!.onConnect((_) {
      isConnected.value = true;
      print('Socket connected');
    });

    socket!.onDisconnect((_) {
      isConnected.value = false;
      print('Socket disconnected');
    });

    socket!.on('new-message', (data) {
      onNewMessage.value = data;
    });

    socket!.on('user-status', (data) {
      onUserStatus.value = data;
    });

    socket!.on('user-typing', (data) {
      onTyping.value = data;
    });

    socket!.on('message-deleted', (data) {
      onMessageDeleted.value = data;
    });

    socket!.on('user-joined', (data) {
      onUserJoined.value = data;
    });

    socket!.on('user-left', (data) {
      onUserLeft.value = data;
    });

    socket!.on('error', (data) {
      print('Socket error: $data');
    });

    socket!.connect();
  }

  void joinRoom(String roomId, {String? password}) {
    socket?.emit('join-room', {
      'roomId': roomId,
      'password': password ?? '',
    });
  }

  void leaveRoom(String roomId) {
    socket?.emit('leave-room', {'roomId': roomId});
  }

  void sendMessage({
    required String roomId,
    String content = '',
    String messageType = 'text',
    String mediaUrl = '',
    Map<String, dynamic>? gift,
  }) {
    socket?.emit('send-message', {
      'roomId': roomId,
      'content': content,
      'messageType': messageType,
      'mediaUrl': mediaUrl,
      'gift': gift,
    });
  }

  void sendTyping(String roomId, bool isTyping) {
    socket?.emit('typing', {
      'roomId': roomId,
      'isTyping': isTyping,
    });
  }

  void deleteMessage(String roomId, String messageId) {
    socket?.emit('delete-message', {
      'roomId': roomId,
      'messageId': messageId,
    });
  }

  void disconnect() {
    socket?.disconnect();
    socket?.clearListeners();
  }
}
