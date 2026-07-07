class GiftModel {
  final String id;
  final String name;
  final String icon;
  final String? lottieAsset;
  final int priceCoins;
  final String category;
  final bool isAnimated;
  final int? animationDurationMs;

  GiftModel({
    required this.id,
    required this.name,
    required this.icon,
    this.lottieAsset,
    required this.priceCoins,
    this.category = 'general',
    this.isAnimated = false,
    this.animationDurationMs,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '🎁',
      lottieAsset: json['lottieAsset'],
      priceCoins: (json['priceCoins'] ?? json['price'] ?? 0).toInt(),
      category: json['category'] ?? 'general',
      isAnimated: json['isAnimated'] ?? false,
      animationDurationMs: json['animationDurationMs'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'lottieAsset': lottieAsset,
      'priceCoins': priceCoins,
      'category': category,
      'isAnimated': isAnimated,
      'animationDurationMs': animationDurationMs,
    };
  }

  static const List<GiftModel> defaultGifts = [
    GiftModel(id: 'rose', name: 'وردة', icon: '🌹', priceCoins: 100, category: 'flowers'),
    GiftModel(id: 'heart', name: 'قلب', icon: '❤️', priceCoins: 200, category: 'romantic'),
    GiftModel(id: 'kiss', name: 'بوسة', icon: '💋', priceCoins: 300, category: 'romantic'),
    GiftModel(id: 'star', name: 'نجمة', icon: '⭐', priceCoins: 500, category: 'general'),
    GiftModel(id: 'cake', name: 'كعكة', icon: '🎂', priceCoins: 800, category: 'celebrations'),
    GiftModel(id: 'crown', name: 'تاج', icon: '👑', priceCoins: 1000, category: 'premium'),
    GiftModel(id: 'diamond', name: 'ألماسة', icon: '💎', priceCoins: 1500, category: 'premium'),
    GiftModel(id: 'car', name: 'سيارة', icon: '🚗', priceCoins: 2000, category: 'luxury', isAnimated: true),
    GiftModel(id: 'yacht', name: 'يخت', icon: '🛥️', priceCoins: 5000, category: 'luxury', isAnimated: true),
    GiftModel(
      id: 'castle',
      name: 'قصر',
      icon: '🏰',
      priceCoins: 10000,
      category: 'luxury',
      isAnimated: true,
      animationDurationMs: 3000,
    ),
    GiftModel(
      id: 'airplane',
      name: 'طائرة',
      icon: '✈️',
      priceCoins: 20000,
      category: 'luxury',
      isAnimated: true,
      animationDurationMs: 4000,
    ),
    GiftModel(
      id: 'fireworks',
      name: 'ألعاب نارية',
      icon: '🎆',
      priceCoins: 50000,
      category: 'limited',
      isAnimated: true,
      animationDurationMs: 5000,
    ),
  ];

  static GiftModel findById(String id) {
    return defaultGifts.firstWhere(
      (g) => g.id == id,
      orElse: () => defaultGifts.first,
    );
  }

  static List<GiftModel> getByCategory(String category) {
    return defaultGifts.where((g) => g.category == category).toList();
  }
}
