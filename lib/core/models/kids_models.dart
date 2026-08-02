import 'package:flutter/material.dart';

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
