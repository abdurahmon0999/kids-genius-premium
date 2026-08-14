import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { kid, parent, teacher, admin }

enum Rarity { common, rare, epic, legendary }

class UserProfileModel {
  final String uid;
  final String name;
  final UserRole role;
  final int coins;
  final int xp;
  final int level;
  final int streakDays;
  final String activeAvatarHat;
  final String activeAvatarOutfit;
  final String activePetName;
  final String activePetEmoji;
  final String profilePic; 
  final int totalActions; // Tracking user movements
  final bool isPremium;
  final String language;

  UserProfileModel({
    required this.uid,
    required this.name,
    required this.role,
    required this.coins,
    required this.xp,
    required this.level,
    required this.streakDays,
    required this.activeAvatarHat,
    required this.activeAvatarOutfit,
    required this.activePetName,
    required this.activePetEmoji,
    required this.profilePic,
    this.totalActions = 0,
    required this.isPremium,
    this.language = 'uz',
  });

  UserProfileModel copyWith({
    String? name,
    UserRole? role,
    int? coins,
    int? xp,
    int? level,
    int? streakDays,
    String? activeAvatarHat,
    String? activeAvatarOutfit,
    String? activePetName,
    String? activePetEmoji,
    String? profilePic,
    int? totalActions,
    bool? isPremium,
    String? language,
  }) {
    return UserProfileModel(
      uid: uid,
      name: name ?? this.name,
      role: role ?? this.role,
      coins: coins ?? this.coins,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streakDays: streakDays ?? this.streakDays,
      activeAvatarHat: activeAvatarHat ?? this.activeAvatarHat,
      activeAvatarOutfit: activeAvatarOutfit ?? this.activeAvatarOutfit,
      activePetName: activePetName ?? this.activePetName,
      activePetEmoji: activePetEmoji ?? this.activePetEmoji,
      profilePic: profilePic ?? this.profilePic,
      totalActions: totalActions ?? this.totalActions,
      isPremium: isPremium ?? this.isPremium,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'role': role.index,
    'coins': coins,
    'xp': xp,
    'level': level,
    'streakDays': streakDays,
    'activeAvatarHat': activeAvatarHat,
    'activeAvatarOutfit': activeAvatarOutfit,
    'activePetName': activePetName,
    'activePetEmoji': activePetEmoji,
    'profilePic': profilePic,
    'totalActions': totalActions,
    'isPremium': isPremium,
    'language': language,
  };

  factory UserProfileModel.fromJson(Map<String, dynamic> json) => UserProfileModel(
    uid: json['uid'],
    name: json['name'],
    role: UserRole.values[json['role']],
    coins: json['coins'],
    xp: json['xp'],
    level: json['level'],
    streakDays: json['streakDays'],
    activeAvatarHat: json['activeAvatarHat'],
    activeAvatarOutfit: json['activeAvatarOutfit'],
    activePetName: json['activePetName'],
    activePetEmoji: json['activePetEmoji'],
    profilePic: json['profilePic'] ?? '🦁',
    totalActions: json['totalActions'] ?? 0,
    isPremium: json['isPremium'],
    language: json['language'] ?? 'uz',
  );
}

class GameCategoryModel {
  final String id;
  final String title;
  final String categoryKey;
  final String iconEmoji;
  final Color themeColor;
  final int completedLessons;
  final int totalLessons;
  final bool isUnlocked;

  GameCategoryModel({
    required this.id,
    required this.title,
    required this.categoryKey,
    required this.iconEmoji,
    required this.themeColor,
    required this.completedLessons,
    required this.totalLessons,
    required this.isUnlocked,
  });
}

class ShopItemModel {
  final String id;
  final String name;
  final String type; // 'hat', 'outfit', 'pet', 'furniture', 'mystery'
  final int coinCost;
  final Rarity rarity;
  final String emoji;
  final bool isPurchased;
  final bool isRequested; // New field for parental wishlist

  ShopItemModel({
    required this.id,
    required this.name,
    required this.type,
    required this.coinCost,
    required this.rarity,
    required this.emoji,
    this.isPurchased = false,
    this.isRequested = false,
  });

  ShopItemModel copyWith({bool? isPurchased, bool? isRequested}) {
    return ShopItemModel(
      id: id,
      name: name,
      type: type,
      coinCost: coinCost,
      rarity: rarity,
      emoji: emoji,
      isPurchased: isPurchased ?? this.isPurchased,
      isRequested: isRequested ?? this.isRequested,
    );
  }
}

class PetModel {
  final String id;
  final String name;
  final String emoji;
  final int level;
  final int happinessPercent; // 0..100
  final int hungerPercent;    // 0..100

  PetModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.level,
    required this.happinessPercent,
    required this.hungerPercent,
  });

  PetModel copyWith({
    int? level,
    int? happinessPercent,
    int? hungerPercent,
  }) {
    return PetModel(
      id: id,
      name: name,
      emoji: emoji,
      level: level ?? this.level,
      happinessPercent: happinessPercent ?? this.happinessPercent,
      hungerPercent: hungerPercent ?? this.hungerPercent,
    );
  }
}

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final int rewardCoins;
  final int rewardXp;
  final bool isUnlocked;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.rewardCoins,
    required this.rewardXp,
    required this.isUnlocked,
  });
}

class ParentReportModel {
  final int dailyStudyMinutes;
  final int gamesPlayedToday;
  final List<String> strongSubjects;
  final List<String> weakSubjects;
  final int screenTimeLimitMinutes;
  final bool isLimitEnabled;

  ParentReportModel({
    required this.dailyStudyMinutes,
    required this.gamesPlayedToday,
    required this.strongSubjects,
    required this.weakSubjects,
    required this.screenTimeLimitMinutes,
    required this.isLimitEnabled,
  });
}

class ZombieStats {
  final int bestScore;
  final int bestTime; // in seconds
  final int highestWave;
  final int totalKills;
  final int totalCoins;
  // Permanent Upgrades
  final int dmgLevel;
  final int hpLevel;
  final int speedLevel;
  final int critLevel;

  ZombieStats({
    this.bestScore = 0,
    this.bestTime = 0,
    this.highestWave = 1,
    this.totalKills = 0,
    this.totalCoins = 0,
    this.dmgLevel = 0,
    this.hpLevel = 0,
    this.speedLevel = 0,
    this.critLevel = 0,
  });

  ZombieStats copyWith({
    int? bestScore,
    int? bestTime,
    int? highestWave,
    int? totalKills,
    int? totalCoins,
    int? dmgLevel,
    int? hpLevel,
    int? speedLevel,
    int? critLevel,
  }) {
    return ZombieStats(
      bestScore: bestScore ?? this.bestScore,
      bestTime: bestTime ?? this.bestTime,
      highestWave: highestWave ?? this.highestWave,
      totalKills: totalKills ?? this.totalKills,
      totalCoins: totalCoins ?? this.totalCoins,
      dmgLevel: dmgLevel ?? this.dmgLevel,
      hpLevel: hpLevel ?? this.hpLevel,
      speedLevel: speedLevel ?? this.speedLevel,
      critLevel: critLevel ?? this.critLevel,
    );
  }

  Map<String, dynamic> toJson() => {
    'bestScore': bestScore,
    'bestTime': bestTime,
    'highestWave': highestWave,
    'totalKills': totalKills,
    'totalCoins': totalCoins,
    'dmgLevel': dmgLevel,
    'hpLevel': hpLevel,
    'speedLevel': speedLevel,
    'critLevel': critLevel,
  };

  factory ZombieStats.fromJson(Map<String, dynamic> json) => ZombieStats(
    bestScore: json['bestScore'] ?? 0,
    bestTime: json['bestTime'] ?? 0,
    highestWave: json['highestWave'] ?? 1,
    totalKills: json['totalKills'] ?? 0,
    totalCoins: json['totalCoins'] ?? 0,
    dmgLevel: json['dmgLevel'] ?? 0,
    hpLevel: json['hpLevel'] ?? 0,
    speedLevel: json['speedLevel'] ?? 0,
    critLevel: json['critLevel'] ?? 0,
  );
}

class SkyRushStats {
  final int bestScore;
  final int totalCoins;
  final int totalCrystals;
  final List<String> unlockedCharacters;
  final String activeCharacter;
  final int level;
  final int xp;

  SkyRushStats({
    this.bestScore = 0,
    this.totalCoins = 100,
    this.totalCrystals = 5,
    this.unlockedCharacters = const ['Nova'],
    this.activeCharacter = 'Nova',
    this.level = 1,
    this.xp = 0,
  });

  SkyRushStats copyWith({
    int? bestScore,
    int? totalCoins,
    int? totalCrystals,
    List<String>? unlockedCharacters,
    String? activeCharacter,
    int? level,
    int? xp,
  }) {
    return SkyRushStats(
      bestScore: bestScore ?? this.bestScore,
      totalCoins: totalCoins ?? this.totalCoins,
      totalCrystals: totalCrystals ?? this.totalCrystals,
      unlockedCharacters: unlockedCharacters ?? this.unlockedCharacters,
      activeCharacter: activeCharacter ?? this.activeCharacter,
      level: level ?? this.level,
      xp: xp ?? this.xp,
    );
  }

  Map<String, dynamic> toJson() => {
    'bestScore': bestScore,
    'totalCoins': totalCoins,
    'totalCrystals': totalCrystals,
    'unlockedCharacters': unlockedCharacters,
    'activeCharacter': activeCharacter,
    'level': level,
    'xp': xp,
  };

  factory SkyRushStats.fromJson(Map<String, dynamic> json) => SkyRushStats(
    bestScore: json['bestScore'] ?? 0,
    totalCoins: json['totalCoins'] ?? 0,
    totalCrystals: json['totalCrystals'] ?? 0,
    unlockedCharacters: List<String>.from(json['unlockedCharacters'] ?? ['Nova']),
    activeCharacter: json['activeCharacter'] ?? 'Nova',
    level: json['level'] ?? 1,
    xp: json['xp'] ?? 0,
  );
}

class TurboKartStats {
  final int totalCoins;
  final int totalCrystals;
  final int level;
  final int xp;
  final List<String> unlockedKarts;
  final String activeKart;
  final Map<String, int> kartLevels; // KartId -> Level

  TurboKartStats({
    this.totalCoins = 200,
    this.totalCrystals = 10,
    this.level = 1,
    this.xp = 0,
    this.unlockedKarts = const ['Starter'],
    this.activeKart = 'Starter',
    this.kartLevels = const {'Starter': 1},
  });

  TurboKartStats copyWith({
    int? totalCoins,
    int? totalCrystals,
    int? level,
    int? xp,
    List<String>? unlockedKarts,
    String? activeKart,
    Map<String, int>? kartLevels,
  }) {
    return TurboKartStats(
      totalCoins: totalCoins ?? this.totalCoins,
      totalCrystals: totalCrystals ?? this.totalCrystals,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      unlockedKarts: unlockedKarts ?? this.unlockedKarts,
      activeKart: activeKart ?? this.activeKart,
      kartLevels: kartLevels ?? this.kartLevels,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalCoins': totalCoins,
    'totalCrystals': totalCrystals,
    'level': level,
    'xp': xp,
    'unlockedKarts': unlockedKarts,
    'activeKart': activeKart,
    'kartLevels': kartLevels,
  };

  factory TurboKartStats.fromJson(Map<String, dynamic> json) => TurboKartStats(
    totalCoins: json['totalCoins'] ?? 0,
    totalCrystals: json['totalCrystals'] ?? 0,
    level: json['level'] ?? 1,
    xp: json['xp'] ?? 0,
    unlockedKarts: List<String>.from(json['unlockedKarts'] ?? ['Starter']),
    activeKart: json['activeKart'] ?? 'Starter',
    kartLevels: Map<String, int>.from(json['kartLevels'] ?? {'Starter': 1}),
  );
}

class QuestModel {
  final String id;
  final String title;
  final String targetCategory; // 'math', 'animal_quiz', etc.
  final int goalCount;
  final int currentProgress;
  final int rewardCoins;
  final String iconEmoji;
  final bool isClaimed;

  QuestModel({
    required this.id,
    required this.title,
    required this.targetCategory,
    required this.goalCount,
    this.currentProgress = 0,
    required this.rewardCoins,
    required this.iconEmoji,
    this.isClaimed = false,
  });

  bool get isCompleted => currentProgress >= goalCount;

  QuestModel copyWith({int? currentProgress, bool? isClaimed}) {
    return QuestModel(
      id: id,
      title: title,
      targetCategory: targetCategory,
      goalCount: goalCount,
      currentProgress: currentProgress ?? this.currentProgress,
      rewardCoins: rewardCoins,
      iconEmoji: iconEmoji,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}

class CarouselItem {
  final String id;
  final String imageUrl;
  final String title;
  final String description;
  final String? link;

  CarouselItem({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    this.link,
  });

  factory CarouselItem.fromJson(Map<String, dynamic> json, String id) {
    return CarouselItem(
      id: id,
      imageUrl: json['imageUrl'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() => {
    'imageUrl': imageUrl,
    'title': title,
    'description': description,
    'link': link,
  };
}

class BlogPost {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime date;
  final String imageUrl;

  BlogPost({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.date,
    required this.imageUrl,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json, String id) {
    return BlogPost(
      id: id,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      author: json['author'] ?? 'Admin',
      date: (json['date'] as Timestamp).toDate(),
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'author': author,
    'date': date,
    'imageUrl': imageUrl,
  };
}

class NewsItem {
  final String id;
  final String title;
  final String summary;
  final String content;
  final DateTime date;
  final String imageUrl;

  NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.date,
    required this.imageUrl,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json, String id) {
    return NewsItem(
      id: id,
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      content: json['content'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'summary': summary,
    'content': content,
    'date': date,
    'imageUrl': imageUrl,
  };
}

class UserReview {
  final String id;
  final String userId;
  final String userName;
  final String comment;
  final double rating;
  final DateTime date;

  UserReview({
    required this.id,
    required this.userId,
    required this.userName,
    required this.comment,
    required this.rating,
    required this.date,
  });

  factory UserReview.fromJson(Map<String, dynamic> json, String id) {
    return UserReview(
      id: id,
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Anonymous',
      comment: json['comment'] ?? '',
      rating: (json['rating'] ?? 5.0).toDouble(),
      date: json['date'] != null ? (json['date'] as Timestamp).toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'comment': comment,
    'rating': rating,
    'date': date,
  };
}
