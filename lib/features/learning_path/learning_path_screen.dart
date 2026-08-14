import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/bouncy_button.dart';
import '../../core/services/kids_providers.dart';
import '../mini_games/zombie_game_screen.dart';
import '../sky_rush/screens/sky_rush_home_screen.dart';
import '../turbo_kart/screens/turbo_kart_home_screen.dart';

class LearningPathScreen extends ConsumerWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final games = ref.watch(gameCategoriesProvider);
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('learning_path'.tr(), style: AppTypography.heading2(color: isDark ? Colors.white : AppColors.primary)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          final isEven = index % 2 == 0;

          return Column(
            children: [
              // Node Connector Line
              if (index > 0)
                Container(
                  width: 4,
                  height: 40,
                  color: games[index - 1].themeColor.withOpacity(0.5),
                ),

              // Interactive Node Card
              Align(
                alignment: isEven ? Alignment.centerLeft : Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 0.85,
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    customBorderColor: game.themeColor.withOpacity(0.6),
                    child: Row(
                      children: [
                        // Icon Circle
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: game.themeColor.withValues(alpha: 0.2),
                            border: Border.all(color: game.themeColor, width: 2),
                          ),
                          child: Center(
                            child: Text(game.iconEmoji, style: const TextStyle(fontSize: 28)),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Title & Progress
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                game.categoryKey.tr(),
                                style: AppTypography.subtitle1(color: isDark ? Colors.white : Colors.black),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: List.generate(
                                  3,
                                  (starIndex) => Icon(
                                    CupertinoIcons.star_fill,
                                    size: 16,
                                    color: starIndex < 2 ? AppColors.accent : Colors.grey.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Play Button
                        BouncyButton(
                          text: 'play_btn'.tr(),
                          height: 38,
                          gradientStart: game.themeColor,
                          gradientEnd: game.themeColor.withOpacity(0.8),
                          onTap: () {
                            if (game.categoryKey == 'zombie_survival') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ZombieGameScreen()),
                              );
                            } else if (game.categoryKey == 'sky_rush') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SkyRushHomeScreen()),
                              );
                            } else if (game.categoryKey == 'turbo_kart') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const TurboKartHomeScreen()),
                              );
                            } else {
                              ref.read(selectedGameIndexProvider.notifier).state = index;
                              ref.read(selectedTabProvider.notifier).state = 2; // Mini game player tab
                            }
                          },
                        ),
                      ],
                    ),
                  ).animate().scale(duration: 400.ms, delay: (100 * index).ms),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
