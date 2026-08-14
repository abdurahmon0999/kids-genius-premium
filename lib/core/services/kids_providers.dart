import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
    GameCategoryModel(
        id: 'g17', title: 'Zombie Survival', categoryKey: 'zombie_survival', iconEmoji: '🧟', themeColor: const Color(0xFFEF4444), completedLessons: 0, totalLessons: 1, isUnlocked: true),
    GameCategoryModel(
        id: 'g18', title: 'Sky Rush', categoryKey: 'sky_rush', iconEmoji: '🚀', themeColor: const Color(0xFF00C2FF), completedLessons: 0, totalLessons: 1, isUnlocked: true),
    GameCategoryModel(
        id: 'g19', title: 'Turbo Kart', categoryKey: 'turbo_kart', iconEmoji: '🏎️', themeColor: const Color(0xFFFFB703), completedLessons: 0, totalLessons: 1, isUnlocked: true),
  ];
});

final shopItemsProvider = StreamProvider<List<ShopItemModel>>((ref) {
  return FirebaseFirestore.instance.collection('shop_items').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ShopItemModel(
        id: doc.id,
        name: data['name'] ?? '',
        type: data['type'] ?? 'hat',
        coinCost: data['coinCost'] ?? 100,
        rarity: Rarity.values[data['rarity'] ?? 0],
        emoji: data['emoji'] ?? '❓',
        isPurchased: false, 
        isRequested: data['requested_by'] != null && (data['requested_by'] as List).contains(ref.read(userProfileProvider).uid),
      );
    }).toList();
  });
});

// Helper for purchases (kept as StateNotifier for local UI response)
class UserPurchasesNotifier extends StateNotifier<List<String>> {
  final String? uid;
  UserPurchasesNotifier(this.uid) : super([]) {
    _load();
  }

  Future<void> _load() async {
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).collection('data').doc('items').get();
      if (doc.exists) {
        state = List<String>.from(doc.data()?['purchased'] ?? []);
      }
    }
  }

  void addPurchase(String itemId) {
    if (!state.contains(itemId)) {
      state = [...state, itemId];
      if (uid != null) {
        FirebaseFirestore.instance.collection('users').doc(uid).collection('data').doc('items').set({
          'purchased': state,
        }, SetOptions(merge: true));
        
        // Remove from wishlist if it was there
        FirebaseFirestore.instance.collection('shop_items').doc(itemId).update({
          'requested_by': FieldValue.arrayRemove([uid]),
        });
      }
    }
  }

  void requestItem(String itemId) {
    if (uid != null) {
      FirebaseFirestore.instance.collection('shop_items').doc(itemId).update({
        'requested_by': FieldValue.arrayUnion([uid]),
      });
    }
  }
}

final userPurchasesProvider = StateNotifierProvider<UserPurchasesNotifier, List<String>>((ref) {
  final user = ref.watch(userProfileProvider);
  return UserPurchasesNotifier(user.uid);
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
      StorageService.syncPetToCloud(_user.uid, state);
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

// Global Page Loading Provider
final isPageLoadingProvider = StateProvider<bool>((ref) => false);

// Enhanced Navigation Provider
final navigationHelperProvider = Provider((ref) {
  return (int index) async {
    final isConnected = ref.read(connectivityProvider).value ?? true;
    if (!isConnected) return;
    
    if (ref.read(selectedTabProvider) == index) return;

    ref.read(isPageLoadingProvider.notifier).state = true;
    await Future.delayed(const Duration(milliseconds: 600));
    ref.read(selectedTabProvider.notifier).state = index;
    ref.read(isPageLoadingProvider.notifier).state = false;
  };
});

// --- New: Daily Quest Provider ---

class QuestNotifier extends StateNotifier<List<QuestModel>> {
  QuestNotifier() : super(_initialQuests()) {
    _loadProgress();
  }

  static List<QuestModel> _initialQuests() {
    return [
      QuestModel(id: 'q1', title: 'quest_math', targetCategory: 'math', goalCount: 3, rewardCoins: 50, iconEmoji: '🔢'),
      QuestModel(id: 'q2', title: 'quest_animals', targetCategory: 'animal_quiz', goalCount: 2, rewardCoins: 30, iconEmoji: '🦁'),
      QuestModel(id: 'q3', title: 'quest_stories', targetCategory: 'storyteller', goalCount: 1, rewardCoins: 40, iconEmoji: '📖'),
    ];
  }

  void _loadProgress() {
    final savedData = StorageService.loadQuestsLocal();
    if (savedData != null) {
      state = [
        for (final quest in state)
          _applyProgress(quest, savedData)
      ];
    }
  }

  QuestModel _applyProgress(QuestModel quest, List<Map<String, dynamic>> savedData) {
    try {
      final saved = savedData.firstWhere((e) => e['id'] == quest.id);
      return quest.copyWith(
        currentProgress: saved['currentProgress'] ?? 0,
        isClaimed: saved['isClaimed'] ?? false,
      );
    } catch (_) {
      return quest;
    }
  }

  void _persist() {
    StorageService.saveQuestsLocal(state);
  }

  void updateProgress(String categoryKey) {
    state = [
      for (final quest in state)
        if (quest.targetCategory == categoryKey && !quest.isCompleted)
          quest.copyWith(currentProgress: quest.currentProgress + 1)
        else
          quest
    ];
    _persist();
  }

  void claimReward(String questId, WidgetRef ref) {
    state = [
      for (final quest in state)
        if (quest.id == questId && quest.isCompleted && !quest.isClaimed)
          _performClaim(quest, ref)
        else
          quest
    ];
    _persist();
  }

  QuestModel _performClaim(QuestModel quest, WidgetRef ref) {
    ref.read(userProfileProvider.notifier).addCoins(quest.rewardCoins);
    ref.read(userProfileProvider.notifier).addXp(quest.rewardCoins ~/ 2);
    return quest.copyWith(isClaimed: true);
  }

  void resetDaily() {
    state = _initialQuests();
    _persist();
  }
}

final questProvider = StateNotifierProvider<QuestNotifier, List<QuestModel>>((ref) {
  return QuestNotifier();
});

// --- New Content Providers ---

final carouselProvider = StreamProvider<List<CarouselItem>>((ref) {
  return FirebaseFirestore.instance
      .collection('carousel')
      .limit(3)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => CarouselItem.fromJson(doc.data(), doc.id)).toList();
  });
});

final blogProvider = StreamProvider<List<BlogPost>>((ref) {
  return FirebaseFirestore.instance.collection('blog').orderBy('date', descending: true).snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => BlogPost.fromJson(doc.data(), doc.id)).toList();
  });
});

final newsProvider = StreamProvider<List<NewsItem>>((ref) {
  return FirebaseFirestore.instance.collection('news').orderBy('date', descending: true).snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => NewsItem.fromJson(doc.data(), doc.id)).toList();
  });
});

final reviewsProvider = StreamProvider<List<UserReview>>((ref) {
  return FirebaseFirestore.instance.collection('reviews').orderBy('date', descending: true).snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => UserReview.fromJson(doc.data(), doc.id)).toList();
  });
});

class LocalReviewsNotifier extends StateNotifier<List<UserReview>> {
  LocalReviewsNotifier() : super(StorageService.loadReviewsLocal());

  void addReview(UserReview review) {
    state = [...state, review];
    StorageService.saveReviewLocal(review);
  }
}

final localReviewsProvider = StateNotifierProvider<LocalReviewsNotifier, List<UserReview>>((ref) {
  return LocalReviewsNotifier();
});

final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map((results) {
    // connectivity_plus v6.0.0+ returns a List<ConnectivityResult>
    return !results.contains(ConnectivityResult.none);
  });
});

// --- New: Zombie Game Provider ---

class ZombieGameNotifier extends StateNotifier<ZombieStats> {
  ZombieGameNotifier() : super(StorageService.loadZombieStatsLocal() ?? ZombieStats());

  void updateStats({
    int? score,
    int? time,
    int? wave,
    int? kills,
    int? coins,
  }) {
    state = state.copyWith(
      bestScore: (score ?? 0) > state.bestScore ? score : state.bestScore,
      bestTime: (time ?? 0) > state.bestTime ? time : state.bestTime,
      highestWave: (wave ?? 1) > state.highestWave ? wave : state.highestWave,
      totalKills: state.totalKills + (kills ?? 0),
      totalCoins: state.totalCoins + (coins ?? 0),
    );
    _persist();
  }

  bool buyUpgrade(String type, int cost) {
    if (state.totalCoins >= cost) {
      state = state.copyWith(
        totalCoins: state.totalCoins - cost,
        dmgLevel: type == 'dmg' ? state.dmgLevel + 1 : state.dmgLevel,
        hpLevel: type == 'hp' ? state.hpLevel + 1 : state.hpLevel,
        speedLevel: type == 'speed' ? state.speedLevel + 1 : state.speedLevel,
        critLevel: type == 'crit' ? state.critLevel + 1 : state.critLevel,
      );
      _persist();
      return true;
    }
    return false;
  }

  void _persist() {
    StorageService.saveZombieStatsLocal(state);
  }
}

final zombieGameProvider = StateNotifierProvider<ZombieGameNotifier, ZombieStats>((ref) {
  return ZombieGameNotifier();
});

// --- New: Sky Rush Game Provider ---

class SkyRushNotifier extends StateNotifier<SkyRushStats> {
  SkyRushNotifier() : super(StorageService.loadSkyRushStatsLocal() ?? SkyRushStats());

  void updateStats({int? score, int? coins, int? crystals, int? xp}) {
    int newXp = state.xp + (xp ?? 0);
    int newLevel = state.level;
    if (newXp >= state.level * 200) {
      newXp -= state.level * 200;
      newLevel++;
    }

    state = state.copyWith(
      bestScore: (score ?? 0) > state.bestScore ? score : state.bestScore,
      totalCoins: state.totalCoins + (coins ?? 0),
      totalCrystals: state.totalCrystals + (crystals ?? 0),
      xp: newXp,
      level: newLevel,
    );
    _persist();
  }

  void unlockCharacter(String name, int coinCost, int crystalCost) {
    if (state.totalCoins >= coinCost && state.totalCrystals >= crystalCost) {
      state = state.copyWith(
        totalCoins: state.totalCoins - coinCost,
        totalCrystals: state.totalCrystals - crystalCost,
        unlockedCharacters: [...state.unlockedCharacters, name],
      );
      _persist();
    }
  }

  void setActiveCharacter(String name) {
    if (state.unlockedCharacters.contains(name)) {
      state = state.copyWith(activeCharacter: name);
      _persist();
    }
  }

  void _persist() {
    StorageService.saveSkyRushStatsLocal(state);
  }
}

final skyRushProvider = StateNotifierProvider<SkyRushNotifier, SkyRushStats>((ref) {
  return SkyRushNotifier();
});

// --- New: Turbo Kart Provider ---

class TurboKartNotifier extends StateNotifier<TurboKartStats> {
  TurboKartNotifier() : super(StorageService.loadTurboKartStatsLocal() ?? TurboKartStats());

  void updateStats({int? coins, int? crystals, int? xp}) {
    int newXp = state.xp + (xp ?? 0);
    int newLevel = state.level;
    if (newXp >= state.level * 300) {
      newXp -= state.level * 300;
      newLevel++;
    }

    state = state.copyWith(
      totalCoins: state.totalCoins + (coins ?? 0),
      totalCrystals: state.totalCrystals + (crystals ?? 0),
      xp: newXp,
      level: newLevel,
    );
    _persist();
  }

  void upgradeKart(String kartId, int cost) {
    if (state.totalCoins >= cost) {
      final currentLvl = state.kartLevels[kartId] ?? 1;
      final newLevels = Map<String, int>.from(state.kartLevels);
      newLevels[kartId] = currentLvl + 1;
      
      state = state.copyWith(
        totalCoins: state.totalCoins - cost,
        kartLevels: newLevels,
      );
      _persist();
    }
  }

  void unlockKart(String kartId, int cost) {
    if (state.totalCrystals >= cost && !state.unlockedKarts.contains(kartId)) {
      state = state.copyWith(
        totalCrystals: state.totalCrystals - cost,
        unlockedKarts: [...state.unlockedKarts, kartId],
      );
      _persist();
    }
  }

  void _persist() {
    StorageService.saveTurboKartStatsLocal(state);
  }
}

final turboKartProvider = StateNotifierProvider<TurboKartNotifier, TurboKartStats>((ref) {
  return TurboKartNotifier();
});
