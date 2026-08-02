import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'glass_card.dart';

class CoinXpHeader extends StatelessWidget {
  final int coins;
  final int xp;
  final int level;
  final int streakDays;
  final VoidCallback? onCoinTap;

  const CoinXpHeader({
    super.key,
    required this.coins,
    required this.xp,
    required this.level,
    required this.streakDays,
    this.onCoinTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Level Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: AppColors.purpleGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.purpleMagic.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(CupertinoIcons.star_fill, color: AppColors.accent, size: 16),
              const SizedBox(width: 4),
              Text(
                'Lvl $level',
                style: AppTypography.bodyBold(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // XP Progress Pill
        Expanded(
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white30),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.bolt_fill, color: AppColors.success, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (xp % 100) / 100.0,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$xp XP',
                  style: AppTypography.caption(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Streak Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orangeAccent.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              const Icon(CupertinoIcons.flame_fill, color: Colors.orangeAccent, size: 16),
              const SizedBox(width: 4),
              Text(
                '$streakDays',
                style: AppTypography.bodyBold(color: Colors.orangeAccent),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Coin Count Pill
        GestureDetector(
          onTap: onCoinTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.coinGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.money_dollar_circle_fill,
                    color: Colors.white, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$coins',
                  style: AppTypography.bodyBold(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
