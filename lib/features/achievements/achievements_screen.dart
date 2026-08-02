import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/bouncy_button.dart';
import '../../core/models/kids_models.dart';
import '../../core/services/kids_providers.dart';
import '../../core/services/achievements_provider.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    final achievements = ref.watch(achievementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Badges & Missions 🎖️',
          style: AppTypography.heading2(
            color: isDark ? Colors.white : AppColors.primary,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: achievements.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = achievements[index];

          return GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(item.iconEmoji, style: const TextStyle(fontSize: 38)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AppTypography.subtitle1(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.description,
                        style: AppTypography.caption(color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Reward: +${item.rewardCoins} Coins | +${item.rewardXp} XP',
                        style: AppTypography.caption(color: AppColors.accent),
                      ),
                    ],
                  ),
                ),
                if (item.isUnlocked) ...[
                  BouncyButton(
                    text: 'Claim 🎁',
                    height: 36,
                    gradientStart: AppColors.accent,
                    gradientEnd: Colors.orange,
                    onTap: () {
                      ref
                          .read(userProfileProvider.notifier)
                          .addCoins(item.rewardCoins);
                      ref
                          .read(userProfileProvider.notifier)
                          .addXp(item.rewardXp);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '🎁 Claimed +${item.rewardCoins} Coins & +${item.rewardXp} XP!',
                          ),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ] else ...[
                  const Icon(Icons.lock, color: Colors.grey, size: 24),
                ],
              ],
            ),
          ).animate().slideY(begin: 0.1 * index, duration: 300.ms);
        },
      ),
    );
  }
}
