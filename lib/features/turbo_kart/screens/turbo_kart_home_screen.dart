import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/bouncy_button.dart';
import '../../../core/services/kids_providers.dart';
import 'turbo_kart_race_screen.dart';

class TurboKartHomeScreen extends ConsumerWidget {
  const TurboKartHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(turboKartProvider);
    final user = ref.watch(userProfileProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white24,
                      child: Text(user.profilePic, style: const TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: AppTypography.bodyBold(color: Colors.white)),
                        Text('LVL ${stats.level} RACER', style: AppTypography.caption(color: Colors.white70)),
                      ],
                    ),
                    const Spacer(),
                    _buildStatPill('🪙', stats.totalCoins.toString()),
                    const SizedBox(width: 8),
                    _buildStatPill('💎', stats.totalCrystals.toString()),
                  ],
                ),
              ),

              const Spacer(),

              // Selected Kart Preview
              Center(
                child: Column(
                  children: [
                    const Text('🏎️', style: TextStyle(fontSize: 120))
                      .animate(onPlay: (c) => c.repeat())
                      .shimmer(duration: 2.seconds)
                      .moveY(begin: -10, end: 10, duration: 1.5.seconds, curve: Curves.easeInOut),
                    const SizedBox(height: 10),
                    Text(stats.activeKart.toUpperCase(), 
                      style: AppTypography.heading2(color: Colors.white)),
                    Text('SPEED: ${stats.kartLevels[stats.activeKart] ?? 1}/5', 
                      style: AppTypography.caption(color: Colors.yellowAccent)),
                  ],
                ),
              ),

              const Spacer(),

              // Bottom Menu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    BouncyButton(
                      text: "🏁 START RACE",
                      height: 60,
                      gradientStart: Colors.orangeAccent,
                      gradientEnd: Colors.redAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TurboKartRaceScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildMenuIcon(CupertinoIcons.settings_solid, "GARAGE", Colors.blueAccent)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildMenuIcon(CupertinoIcons.map_fill, "RACES", Colors.greenAccent)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildMenuIcon(CupertinoIcons.bag_fill, "SHOP", Colors.purpleAccent)),
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

  Widget _buildStatPill(String emoji, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMenuIcon(IconData icon, String label, Color color) {
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
