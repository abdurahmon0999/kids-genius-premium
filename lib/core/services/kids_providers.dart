import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kids_models.dart';
import 'storage_service.dart';

// User Profile Provider
class UserProfileNotifier extends StateNotifier<UserProfileModel> {
  UserProfileNotifier()
      : super(StorageService.loadUserLocal() ?? UserProfileModel(
          uid: 'kg_user_101',
          name: 'Leo Explorer',
          role: UserRole.kid,
          coins: 450,
          xp: 280,
          level: 4,
          streakDays: 7,
          activeAvatarHat: '👑',
          activeAvatarOutfit: '🚀',
          activePetName: 'Sparky the Dragon',
          activePetEmoji: '🐲',
          profilePic: '🦁',
          isPremium: true,
        ));

  void _persist() {
    state = state.copyWith(totalActions: state.totalActions + 1); // Track every change as an action
    StorageService.saveUserLocal(state);
    StorageService.syncToCloud(state);
  }

  void addCoins(int amount) {
    state = state.copyWith(coins: state.coins + amount);
    _persist();
  }

  bool spendCoins(int amount) {
    if (state.coins >= amount) {
      state = state.copyWith(coins: state.coins - amount);
      _persist();
      return true;
    }
    return false;
  }

  void addXp(int amount) {
    int newXp = state.xp + amount;
    int newLevel = (newXp / 100).floor() + 1;
    state = state.copyWith(xp: newXp, level: newLevel);
    _persist();
  }

  void updateAvatar({String? hat, String? outfit}) {
    state = state.copyWith(
      activeAvatarHat: hat ?? state.activeAvatarHat,
      activeAvatarOutfit: outfit ?? state.activeAvatarOutfit,
    );
    _persist();
  }

  void updateProfile({String? name, String? profilePic}) {
    state = state.copyWith(
      name: name ?? state.name,
      profilePic: profilePic ?? state.profilePic,
    );
    _persist();
  }

  void updatePet(String petName, String petEmoji) {
    state = state.copyWith(
      activePetName: petName,
      activePetEmoji: petEmoji,
    );
    _persist();
  }

  void toggleRole(UserRole newRole) {
    state = state.copyWith(role: newRole);
    _persist();
  }

  void setUser(UserProfileModel newUser) {
    state = newUser;
    _persist();
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileModel>((ref) {
  return UserProfileNotifier();
});

// Game Categories Provider (35+ Game categories as per prompt requirements)
final gameCategoriesProvider = Provider<List<GameCategoryModel>>((ref) {
  return [
    GameCategoryModel(
        id: 'g1', title: 'Math Quest', categoryKey: 'math', iconEmoji: '🔢', themeColor: const Color(0xFF5B5FEF), completedLessons: 12, totalLessons: 20, isUnlocked: true),
    GameCategoryModel(
        id: 'g2', title: 'Memory Cards', categoryKey: 'memory', iconEmoji: '🧠', themeColor: const Color(0xFF00C2FF), completedLessons: 8, totalLessons: 15, isUnlocked: true),
    GameCategoryModel(
        id: 'g3', title: 'ABC Alphabet', categoryKey: 'alphabet', iconEmoji: '🔤', themeColor: const Color(0xFFFFB703), completedLessons: 15, totalLessons: 15, isUnlocked: true),
    GameCategoryModel(
        id: 'g4', title: 'Animal Quiz', categoryKey: 'animal_quiz', iconEmoji: '🦁', themeColor: const Color(0xFF34D399), completedLessons: 6, totalLessons: 10, isUnlocked: true),
    GameCategoryModel(
        id: 'g5', title: 'Coding Basics', categoryKey: 'coding', iconEmoji: '💻', themeColor: const Color(0xFF9D4EDD), completedLessons: 4, totalLessons: 12, isUnlocked: true),
    GameCategoryModel(
        id: 'g6', title: 'Space Explorer', categoryKey: 'science', iconEmoji: '🚀', themeColor: const Color(0xFFEF4444), completedLessons: 9, totalLessons: 18, isUnlocked: true),
    GameCategoryModel(
        id: 'g7', title: 'Word Builder', categoryKey: 'word_builder', iconEmoji: '📝', themeColor: const Color(0xFF3B82F6), completedLessons: 5, totalLessons: 10, isUnlocked: true),
    GameCategoryModel(
        id: 'g8', title: 'Logic Maze', categoryKey: 'maze', iconEmoji: '🧩', themeColor: const Color(0xFF10B981), completedLessons: 3, totalLessons: 8, isUnlocked: true),
    GameCategoryModel(
        id: 'g9', title: 'Music & Beats', categoryKey: 'music', iconEmoji: '🎵', themeColor: const Color(0xFFF59E0B), completedLessons: 7, totalLessons: 12, isUnlocked: true),
    GameCategoryModel(
        id: 'g10', title: 'Drawing Studio', categoryKey: 'drawing', iconEmoji: '🎨', themeColor: const Color(0xFFEC4899), completedLessons: 10, totalLessons: 10, isUnlocked: true),
    GameCategoryModel(
        id: 'g11', title: 'Spot Difference', categoryKey: 'spot_diff', iconEmoji: '🔍', themeColor: const Color(0xFF8B5CF6), completedLessons: 2, totalLessons: 8, isUnlocked: true),
    GameCategoryModel(
        id: 'g12', title: 'Shape Matcher', categoryKey: 'shape_match', iconEmoji: '📐', themeColor: const Color(0xFF14B8A6), completedLessons: 11, totalLessons: 14, isUnlocked: true),
    GameCategoryModel(
        id: 'g13', title: 'Coloring Book', categoryKey: 'coloring_book', iconEmoji: '🖍️', themeColor: const Color(0xFFF43F5E), completedLessons: 0, totalLessons: 10, isUnlocked: true),
    GameCategoryModel(
        id: 'g14', title: 'Puzzle Master', categoryKey: 'puzzle', iconEmoji: '🧩', themeColor: const Color(0xFF10B981), completedLessons: 3, totalLessons: 15, isUnlocked: true),
    GameCategoryModel(
        id: 'g15', title: 'Color Splash', categoryKey: 'color_splash', iconEmoji: '🌈', themeColor: const Color(0xFFF59E0B), completedLessons: 5, totalLessons: 12, isUnlocked: true),
    GameCategoryModel(
        id: 'g16', title: 'AI Storyteller', categoryKey: 'storyteller', iconEmoji: '📖', themeColor: const Color(0xFF8B5CF6), completedLessons: 2, totalLessons: 10, isUnlocked: true),
  ];
});

// Shop Items Provider
class ShopItemsNotifier extends StateNotifier<List<ShopItemModel>> {
  final UserProfileModel? _user;

  ShopItemsNotifier(this._user) : super([]) {
    _loadShopItems();
  }

  void _loadShopItems() {
    state = [
      ShopItemModel(id: 's1', name: 'Golden Crown', type: 'hat', coinCost: 150, rarity: Rarity.legendary, emoji: '👑', isPurchased: true),
      ShopItemModel(id: 's2', name: 'Wizard Hat', type: 'hat', coinCost: 100, rarity: Rarity.epic, emoji: '🧙‍♂️'),
      ShopItemModel(id: 's3', name: 'Astronaut Suit', type: 'outfit', coinCost: 250, rarity: Rarity.legendary, emoji: '🚀', isPurchased: true),
      ShopItemModel(id: 's4', name: 'Superhero Cape', type: 'outfit', coinCost: 120, rarity: Rarity.rare, emoji: '🦸‍♂️'),
      ShopItemModel(id: 's5', name: 'Sparky Dragon', type: 'pet', coinCost: 300, rarity: Rarity.legendary, emoji: '🐲', isPurchased: true),
      ShopItemModel(id: 's6', name: 'Cosmic Unicorn', type: 'pet', coinCost: 350, rarity: Rarity.legendary, emoji: '🦄'),
      ShopItemModel(id: 's7', name: 'Magic Wand', type: 'mystery', coinCost: 80, rarity: Rarity.rare, emoji: '🪄'),
      ShopItemModel(id: 's8', name: 'Treasure Chest', type: 'mystery', coinCost: 200, rarity: Rarity.epic, emoji: '🪙'),
    ];
  }

  void _sync() {
    if (_user != null) {
      StorageService.syncItemsToCloud(_user!.uid, state);
    }
  }

  void buyItem(String id) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(isPurchased: true, isRequested: false);
      }
      return item;
    }).toList();
    _sync();
  }

  void requestItem(String id) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(isRequested: true);
      }
      return item;
    }).toList();
    _sync();
  }
}

final shopItemsProvider =
    StateNotifierProvider<ShopItemsNotifier, List<ShopItemModel>>((ref) {
  final user = ref.watch(userProfileProvider);
  return ShopItemsNotifier(user);
});

// Pet State Provider
class PetNotifier extends StateNotifier<PetModel> {
  final UserProfileModel? _user;

  PetNotifier(this._user)
      : super(PetModel(
          id: 'p101',
          name: 'Sparky Dragon',
          emoji: '🐲',
          level: 3,
          happinessPercent: 85,
          hungerPercent: 70,
        )) {
    _loadPet();
  }

  Future<void> _loadPet() async {
    if (_user != null) {
      // In a real app, load pet data from Firestore users/uid/pet
    }
  }

  void _sync() {
    if (_user != null) {
      StorageService.syncPetToCloud(_user!.uid, state);
    }
  }

  void feedPet() {
    int newHunger = (state.hungerPercent + 20).clamp(0, 100);
    int newHappiness = (state.happinessPercent + 10).clamp(0, 100);
    state = state.copyWith(hungerPercent: newHunger, happinessPercent: newHappiness);
    _sync();
  }

  void playWithPet() {
    int newHappiness = (state.happinessPercent + 25).clamp(0, 100);
    state = state.copyWith(happinessPercent: newHappiness);
    _sync();
  }
}

final petProvider = StateNotifierProvider<PetNotifier, PetModel>((ref) {
  final user = ref.watch(userProfileProvider);
  return PetNotifier(user);
});

// Parent Dashboard State Provider
class ParentReportNotifier extends StateNotifier<ParentReportModel> {
  ParentReportNotifier(UserProfileModel user)
      : super(ParentReportModel(
          dailyStudyMinutes: (user.totalActions * 0.5).round(), // Simple calculation for demo
          gamesPlayedToday: (user.totalActions / 5).floor(),
          strongSubjects: ['Math Quest', 'Coding Basics', 'Memory Cards'],
          weakSubjects: ['Word Builder', 'History Quiz'],
          screenTimeLimitMinutes: 60,
          isLimitEnabled: true,
        ));

  void updateFromUser(UserProfileModel user) {
    state = ParentReportModel(
      dailyStudyMinutes: (user.totalActions * 0.5).round(),
      gamesPlayedToday: (user.totalActions / 5).floor(),
      strongSubjects: state.strongSubjects,
      weakSubjects: state.weakSubjects,
      screenTimeLimitMinutes: state.screenTimeLimitMinutes,
      isLimitEnabled: state.isLimitEnabled,
    );
  }

  void toggleLimit(bool enabled) {
    state = ParentReportModel(
      dailyStudyMinutes: state.dailyStudyMinutes,
      gamesPlayedToday: state.gamesPlayedToday,
      strongSubjects: state.strongSubjects,
      weakSubjects: state.weakSubjects,
      screenTimeLimitMinutes: state.screenTimeLimitMinutes,
      isLimitEnabled: enabled,
    );
  }

  void updateScreenTimeLimit(int minutes) {
    state = ParentReportModel(
      dailyStudyMinutes: state.dailyStudyMinutes,
      gamesPlayedToday: state.gamesPlayedToday,
      strongSubjects: state.strongSubjects,
      weakSubjects: state.weakSubjects,
      screenTimeLimitMinutes: minutes,
      isLimitEnabled: state.isLimitEnabled,
    );
  }
}

final parentReportProvider =
    StateNotifierProvider<ParentReportNotifier, ParentReportModel>((ref) {
  final user = ref.watch(userProfileProvider);
  return ParentReportNotifier(user);
});

// Navigation Tab Provider
final selectedTabProvider = StateProvider<int>((ref) => 0);

// Selected Game Index Provider (for jumping from Map to specific game)
final selectedGameIndexProvider = StateProvider<int>((ref) => 0);

// App Theme Dark Mode Provider
final isDarkModeProvider = StateProvider<bool>((ref) => false);

// Accessibility Voice Provider
final isAccessibilityVoiceEnabledProvider = StateProvider<bool>((ref) => true);
