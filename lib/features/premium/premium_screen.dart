import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/cupertino.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/bouncy_button.dart';
import '../../core/services/kids_providers.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kids Genius VIP Pass ⭐',
          style: AppTypography.heading2(
            color: isDark ? Colors.white : AppColors.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // VIP Crown Banner Card
            GlassCard(
              padding: const EdgeInsets.all(24),
              customGradient: AppColors.purpleGradient,
              child: Column(
                children: [
                  const Text('👑', style: TextStyle(fontSize: 64))
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .rotate(begin: -0.08, end: 0.08, duration: 1000.ms),
                  const SizedBox(height: 12),
                  Text(
                    'Unlock All 35+ Magical Worlds',
                    style: AppTypography.heading2(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Unlimited Games • Exclusive Pets • Zero Ads • Audio Stories',
                    style: AppTypography.caption(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Perks Checklist
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildPerkRow(
                    '🚀 All 35+ Educational Game Categories Unlocked',
                  ),
                  const Divider(),
                  _buildPerkRow('🐲 Exclusive Legendary Dragon & Unicorn Pets'),
                  const Divider(),
                  _buildPerkRow(
                    '🎧 Unlimited Access to Audio Stories & Lessons',
                  ),
                  const Divider(),
                  _buildPerkRow('🛡️ Advanced Parent Reports & FL Analytics'),
                  const Divider(),
                  _buildPerkRow('🎁 2x Daily Coins & Double XP Multiplier'),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Pricing Plans
            Row(
              children: [
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    customBorderColor: AppColors.accent,
                    child: Column(
                      children: [
                        Text(
                          'Monthly',
                          style: AppTypography.caption(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$7.99',
                          style: AppTypography.heading3(
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '/month',
                          style: AppTypography.caption(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    customBorderColor: AppColors.success,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'SAVE 40%',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$4.99',
                          style: AppTypography.heading3(
                            color: AppColors.success,
                          ),
                        ),
                        Text(
                          '/month (Billed Yearly)',
                          style: AppTypography.caption(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Subscribe Button
            BouncyButton(
              text: 'Start 7-Day Free Trial ✨',
              gradientStart: AppColors.accent,
              gradientEnd: Colors.orange,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '🎉 7-Day Free VIP Trial Activated! Enjoy Kids Genius VIP!',
                    ),
                    backgroundColor: AppColors.accent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerkRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.checkmark_circle_fill,
            color: AppColors.success,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMedium(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
