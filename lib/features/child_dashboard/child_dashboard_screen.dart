import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/cupertino.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/bouncy_button.dart';
import '../../core/widgets/coin_xp_header.dart';
import '../../core/widgets/mascot_widget.dart';
import '../../core/models/kids_models.dart';
import '../../core/services/kids_providers.dart';

import 'package:lottie/lottie.dart';

class ChildDashboardScreen extends ConsumerWidget {
  const ChildDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final games = ref.watch(gameCategoriesProvider);
    final isDark = ref.watch(isDarkModeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lottie Lion Welcome
          Center(
            child: Lottie.network(
              'https://assets9.lottiefiles.com/packages/lf20_mye7pyj5.json', // More robust link
              height: 120,
              repeat: true,
              errorBuilder: (context, error, stackTrace) {
                return const Text('🦁', style: TextStyle(fontSize: 80));
              },
            ),
          ),
          const SizedBox(height: 8),
          
          // Coins, XP, Level Header
          CoinXpHeader(
            coins: user.coins,
            xp: user.xp,
            level: user.level,
            streakDays: user.streakDays,
            onCoinTap: () =>
                ref.read(selectedTabProvider.notifier).state = 4, // Shop Tab
          ),
          const SizedBox(height: 16),

          // Animated Kid Greeting Card
          GlassCard(
            padding: const EdgeInsets.all(20),
            customGradient: AppColors.heroGradient,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Good Morning, ${user.name}! ☀️',
                            style: AppTypography.heading2(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ready to level up your brain today? You are on a ${user.streakDays}-day streak! 🔥',
                        style: AppTypography.bodyMedium(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 16),
                      BouncyButton(
                        text: 'Claim Daily Reward 🎁',
                        height: 44,
                        gradientStart: AppColors.accent,
                        gradientEnd: Colors.orange,
                        onTap: () {
                          ref.read(userProfileProvider.notifier).addCoins(50);
                          ref.read(userProfileProvider.notifier).addXp(20);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: const [
                                  Text('🎁 Received +50 Coins & +20 XP!'),
                                ],
                              ),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Kid Avatar & Hat Preview
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.25),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: user.profilePic.startsWith('http')
                        ? ClipOval(
                            child: Image.network(
                              user.profilePic,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.white, size: 40),
                            ),
                          )
                        : Text(
                            '${user.activeAvatarHat}\n${user.profilePic}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 28),
                          ),
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Genie Mascot Guide Widget
          MascotWidget(
            speechText:
                'Daily Challenge: Complete 1 Math Quest to unlock the Dragon Chest!',
            onTap: () =>
                ref.read(selectedTabProvider.notifier).state = 2, // Play tab
          ),

          const SizedBox(height: 20),

          // Daily Mission Progress Section
          Text(
            '🎯 Current Mission',
            style: AppTypography.heading3(
              color: isDark ? Colors.white : AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Space Quiz Explorer 🚀',
                      style: AppTypography.subtitle1(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      '3/5 Lessons',
                      style: AppTypography.caption(color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 0.6,
                    minHeight: 12,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Popular Games Carousel Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🚀 Popular Games',
                style: AppTypography.heading3(
                  color: isDark ? Colors.white : AppColors.primary,
                ),
              ),
              GestureDetector(
                onTap: () => ref.read(selectedTabProvider.notifier).state =
                    1, // Learning path
                child: Text(
                  'See All >',
                  style: AppTypography.caption(color: AppColors.secondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: games.length,
              separatorBuilder: (_, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final game = games[index];
                return GestureDetector(
                  onTap: () => ref.read(selectedTabProvider.notifier).state =
                      2, // Play games
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: game.themeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: game.themeColor.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          game.iconEmoji,
                          style: const TextStyle(fontSize: 38),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          game.title,
                          style: AppTypography.bodyBold(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${game.completedLessons}/${game.totalLessons} Done',
                          style: AppTypography.caption(color: game.themeColor),
                        ),
                      ],
                    ),
                  ),
                ).animate().slideX(begin: 0.1 * index, duration: 300.ms);
              },
            ),
          ),

          const SizedBox(height: 24),

          // Quick Action Launchers (Pet, Shop, Leaderboard, Avatar)
          Text(
            '✨ Magical Features',
            style: AppTypography.heading3(
              color: isDark ? Colors.white : AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _buildFeatureShortcut(
                context: context,
                ref: ref,
                tabIndex: 3, // Pet System
                title: 'Pet Care',
                emoji: '🐲',
                color: AppColors.success,
              ),
              const SizedBox(width: 12),
              _buildFeatureShortcut(
                context: context,
                ref: ref,
                tabIndex: 4, // Shop
                title: 'Item Shop',
                emoji: '🛍️',
                color: AppColors.accent,
              ),
              const SizedBox(width: 12),
              _buildFeatureShortcut(
                context: context,
                ref: ref,
                tabIndex: 5, // Avatar Builder
                title: 'Avatar',
                emoji: '👑',
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              _buildFeatureShortcut(
                context: context,
                ref: ref,
                tabIndex: 6, // Leaderboard
                title: 'Rankings',
                emoji: '🏆',
                color: AppColors.purpleMagic,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFeatureShortcut({
    required BuildContext context,
    required WidgetRef ref,
    required int tabIndex,
    required String title,
    required String emoji,
    required Color color,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(selectedTabProvider.notifier).state = tabIndex,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              Text(
                title,
                style: AppTypography.caption(color: color),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
