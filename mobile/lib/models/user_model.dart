class UserModel {
  final String id;
  final String? phone;
  final String? email;
  final String? googleId;
  final String username;
  final String displayName;
  final String avatar;
  final String bio;
  final String countryCode;
  final String country;
  final double balance;
  final double totalRecharged;
  final String role;
  final bool isVerified;
  final bool isPhoneVerified;
  final bool isOnline;
  final String? lastSeen;
  final String authMethod;
  final String? createdAt;

  UserModel({
    required this.id,
    this.phone,
    this.email,
    this.googleId,
    required this.username,
    this.displayName = '',
    this.avatar = '',
    this.bio = '',
    this.countryCode = '+964',
    this.country = 'IRQ',
    this.balance = 0,
    this.totalRecharged = 0,
    this.role = 'user',
    this.isVerified = false,
    this.isPhoneVerified = false,
    this.isOnline = false,
    this.lastSeen,
    this.authMethod = 'phone',
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      phone: json['phone'],
      email: json['email'],
      googleId: json['googleId'],
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? json['username'] ?? '',
      avatar: json['avatar'] ?? '',
      bio: json['bio'] ?? '',
      countryCode: json['countryCode'] ?? '+964',
      country: json['country'] ?? 'IRQ',
      balance: (json['balance'] ?? 0).toDouble(),
      totalRecharged: (json['totalRecharged'] ?? 0).toDouble(),
      role: json['role'] ?? 'user',
      isVerified: json['isVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'],
      authMethod: json['authMethod'] ?? 'phone',
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'phone': phone,
      'email': email,
      'googleId': googleId,
      'username': username,
      'displayName': displayName,
      'avatar': avatar,
      'bio': bio,
      'countryCode': countryCode,
      'country': country,
      'balance': balance,
      'totalRecharged': totalRecharged,
      'role': role,
      'isVerified': isVerified,
      'isPhoneVerified': isPhoneVerified,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'authMethod': authMethod,
    };
  }
}
