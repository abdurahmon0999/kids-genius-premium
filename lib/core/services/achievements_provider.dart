import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kids_models.dart';
import 'kids_providers.dart';
import 'storage_service.dart';

final achievementsProvider = StateNotifierProvider<AchievementsNotifier, List<AchievementModel>>((ref) {
  final user = ref.watch(userProfileProvider);
  return AchievementsNotifier(user);
});

class AchievementsNotifier extends StateNotifier<List<AchievementModel>> {
  final UserProfileModel _user;
  
  AchievementsNotifier(this._user) : super([]) {
    _initAchievements();
  }

  void _initAchievements() {
    state = [
      AchievementModel(
        id: 'a1',
        title: 'Fast Starter 🚀',
        description: 'Completed your first mini-game!',
        iconEmoji: '⚡️',
        rewardCoins: 50,
        rewardXp: 100,
        isUnlocked: _user.totalActions > 0,
      ),
      AchievementModel(
        id: 'a2',
        title: 'Math Wizard 🔢',
        description: 'Completed 10 logic actions.',
        iconEmoji: '🧙‍♂️',
        rewardCoins: 100,
        rewardXp: 200,
        isUnlocked: _user.totalActions >= 10,
      ),
      AchievementModel(
        id: 'a3',
        title: 'Wealthy Hero 💰',
        description: 'Accumulated more than 500 coins.',
        iconEmoji: '💎',
        rewardCoins: 150,
        rewardXp: 300,
        isUnlocked: _user.coins >= 500,
      ),
      AchievementModel(
        id: 'a4',
        title: 'Level Up Master 🌟',
        description: 'Reached Level 5 in your adventure.',
        iconEmoji: '🏅',
        rewardCoins: 200,
        rewardXp: 500,
        isUnlocked: _user.level >= 5,
      ),
    ];
  }
}
