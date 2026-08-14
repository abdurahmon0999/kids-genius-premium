import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/services/kids_providers.dart';
import '../../core/services/leaderboard_provider.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final isDark = ref.watch(isDarkModeProvider);
    final leaderboardAsync = ref.watch(leaderboardStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'leaderboard_title'.tr(),
          style: AppTypography.heading2(
            color: isDark ? Colors.white : AppColors.primary,
          ),
        ),
      ),
      body: leaderboardAsync.when(
        data: (leaders) {
          if (leaders.isEmpty) {
            return Center(child: Text('no_heroes'.tr()));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: leaders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final leader = leaders[index];
              final rank = index + 1;
              final isUser = leader.uid == user.uid;

              return GlassCard(
                padding: const EdgeInsets.all(14),
                customGradient: isUser ? AppColors.heroGradient : null,
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getRankColor(rank).withOpacity(0.2),
                      ),
                      child: Center(
                        child: Text('#$rank',
                          style: AppTypography.bodyBold(color: isUser ? Colors.white : _getRankColor(rank))),
                      ),
                    ),
                    const SizedBox(width: 14),
                    
                    // Avatar display
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white10),
                      child: leader.profilePic.startsWith('http')
                        ? ClipOval(
                            child: Image.network(
                              leader.profilePic, 
                              width: 40, 
                              height: 40, 
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.person, size: 20, color: Colors.white70)),
                            ),
                          )
                        : Center(child: Text('${leader.activeAvatarHat}\n${leader.profilePic}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16))),
                    ),
                    
                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(leader.name,
                            style: AppTypography.subtitle1(color: isUser ? Colors.white : (isDark ? Colors.white : Colors.black87))),
                          Text('${leader.xp} XP',
                            style: AppTypography.caption(color: isUser ? Colors.white70 : AppColors.primary)),
                        ],
                      ),
                    ),

                    if (rank <= 3) Icon(CupertinoIcons.rosette, color: AppColors.accent, size: 24),
                  ],
                ),
              ).animate().slideX(begin: 0.1 * index, duration: 300.ms);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('error_load_rankings'.tr())),
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return AppColors.accent;
    if (rank == 2) return Colors.grey.shade400;
    if (rank == 3) return Colors.orange.shade400;
    return AppColors.primary;
  }
}
