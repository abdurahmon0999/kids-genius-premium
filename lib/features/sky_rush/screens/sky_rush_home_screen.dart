import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/bouncy_button.dart';
import '../../../core/services/kids_providers.dart';
import 'sky_rush_game_screen.dart';

class SkyRushHomeScreen extends ConsumerWidget {
  const SkyRushHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(skyRushProvider);
    final user = ref.watch(userProfileProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white24,
                      child: Text(user.profilePic, style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: AppTypography.bodyBold(color: Colors.white)),
                        Text('LVL ${stats.level}', style: AppTypography.caption(color: AppColors.accent)),
                      ],
                    ),
                    const Spacer(),
                    _buildTopStat('🪙', stats.totalCoins.toString()),
                    const SizedBox(width: 8),
                    _buildTopStat('💎', stats.totalCrystals.toString()),
                  ],
                ),
              ),

              const Spacer(),

              // Animated Hero Character
              _buildAnimatedHero(stats.activeCharacter),

              const Spacer(),

              // Menu Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    BouncyButton(
                      text: "▶ PLAY",
                      height: 60,
                      gradientStart: const Color(0xFF00C2FF),
                      gradientEnd: const Color(0xFF0072FF),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SkyRushGameScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSmallMenuBtn(CupertinoIcons.person_2_fill, "CHARACTERS", Colors.purpleAccent),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSmallMenuBtn(CupertinoIcons.bolt_fill, "POWER UPS", Colors.orangeAccent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSmallMenuBtn(CupertinoIcons.bag_fill, "INVENTORY", Colors.cyanAccent),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSmallMenuBtn(CupertinoIcons.star_fill, "LEADERBOARD", Colors.amberAccent),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopStat(String emoji, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(val, style: AppTypography.bodyBold(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildAnimatedHero(String character) {
    return Column(
      children: [
        const Text('🚀', style: TextStyle(fontSize: 100))
          .animate(onPlay: (c) => c.repeat())
          .moveY(begin: -10, end: 10, duration: 2.seconds, curve: Curves.easeInOut)
          .shimmer(duration: 3.seconds),
        const SizedBox(height: 16),
        Text(character, style: AppTypography.heading2(color: Colors.white)),
      ],
    );
  }

  Widget _buildSmallMenuBtn(IconData icon, String label, Color color) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 12),
      customBorderColor: color.withValues(alpha: 0.5),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
