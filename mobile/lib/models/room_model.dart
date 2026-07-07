class RoomModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final String type;
  final String category;
  final String password;
  final String createdBy;
  final String? createdByName;
  final String? createdByAvatar;
  final List<dynamic> admins;
  final List<dynamic> members;
  final List<dynamic> bannedMembers;
  final int maxMembers;
  final bool isActive;
  final String? lastMessage;
  final String country;
  final String countryCode;
  final List<String> tags;
  final int memberCount;
  final String? createdAt;

  RoomModel({
    required this.id,
    required this.name,
    this.description = '',
    this.image = '',
    this.type = 'public',
    this.category = 'general',
    this.password = '',
    required this.createdBy,
    this.createdByName,
    this.createdByAvatar,
    this.admins = const [],
    this.members = const [],
    this.bannedMembers = const [],
    this.maxMembers = 500,
    this.isActive = true,
    this.lastMessage,
    this.country = 'all',
    this.countryCode = '+964',
    this.tags = const [],
    this.memberCount = 0,
    this.createdAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    final creator = json['createdBy'];
    String creatorId = '';
    String? creatorName;
    String? creatorAvatar;

    if (creator is Map<String, dynamic>) {
      creatorId = creator['_id'] ?? '';
      creatorName = creator['displayName'] ?? creator['username'] ?? '';
      creatorAvatar = creator['avatar'];
    } else {
      creatorId = creator?.toString() ?? '';
    }

    return RoomModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      type: json['type'] ?? 'public',
      category: json['category'] ?? 'general',
      password: json['password'] ?? '',
      createdBy: creatorId,
      createdByName: creatorName,
      createdByAvatar: creatorAvatar,
      admins: json['admins'] ?? [],
      members: json['members'] ?? [],
      bannedMembers: json['bannedMembers'] ?? [],
      maxMembers: json['maxMembers'] ?? 500,
      isActive: json['isActive'] ?? true,
      lastMessage: json['lastMessage']?.toString(),
      country: json['country'] ?? 'all',
      countryCode: json['countryCode'] ?? '+964',
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      memberCount: (json['members'] as List?)?.length ?? 0,
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'image': image,
      'type': type,
      'category': category,
      'password': password,
      'createdBy': createdBy,
      'admins': admins,
      'members': members,
      'bannedMembers': bannedMembers,
      'maxMembers': maxMembers,
      'isActive': isActive,
      'lastMessage': lastMessage,
      'country': country,
      'countryCode': countryCode,
      'tags': tags,
    };
  }
}
