class MessageModel {
  final String id;
  final String room;
  final String sender;
  final String? senderName;
  final String? senderAvatar;
  final String? senderRole;
  final String content;
  final String messageType;
  final String mediaUrl;
  final String mediaUrl2;
  final String? replyTo;
  final bool isDeleted;
  final bool isEdited;
  final List<dynamic> readBy;
  final Map<String, dynamic>? gift;
  final String? createdAt;

  MessageModel({
    required this.id,
    required this.room,
    required this.sender,
    this.senderName,
    this.senderAvatar,
    this.senderRole,
    this.content = '',
    this.messageType = 'text',
    this.mediaUrl = '',
    this.mediaUrl2 = '',
    this.replyTo,
    this.isDeleted = false,
    this.isEdited = false,
    this.readBy = const [],
    this.gift,
    this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final senderData = json['sender'];
    String senderId = '';
    String? senderName;
    String? senderAvatar;
    String? senderRole;

    if (senderData is Map<String, dynamic>) {
      senderId = senderData['_id'] ?? '';
      senderName = senderData['displayName'] ?? senderData['username'] ?? '';
      senderAvatar = senderData['avatar'];
      senderRole = senderData['role'];
    } else {
      senderId = senderData?.toString() ?? '';
    }

    return MessageModel(
      id: json['_id'] ?? '',
      room: json['room']?.toString() ?? '',
      sender: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      senderRole: senderRole,
      content: json['content'] ?? '',
      messageType: json['messageType'] ?? 'text',
      mediaUrl: json['mediaUrl'] ?? '',
      mediaUrl2: json['mediaUrl2'] ?? '',
      replyTo: json['replyTo']?.toString(),
      isDeleted: json['isDeleted'] ?? false,
      isEdited: json['isEdited'] ?? false,
      readBy: json['readBy'] ?? [],
      gift: json['gift'],
      createdAt: json['createdAt'],
    );
  }
}
