import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/bouncy_button.dart';
import '../../core/services/kids_providers.dart';

class PetSystemScreen extends ConsumerWidget {
  const PetSystemScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pet = ref.watch(petProvider);
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pet Sanctuary 🐲',
          style: AppTypography.heading2(
            color: isDark ? Colors.white : AppColors.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Pet Mascot Arena Card
            GlassCard(
              padding: const EdgeInsets.all(28),
              customGradient: AppColors.purpleGradient,
              child: Column(
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.25),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purpleMagic.withOpacity(0.5),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                    child: Center(
                      child:
                          Text(pet.emoji, style: const TextStyle(fontSize: 68))
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .scale(
                                begin: const Offset(0.95, 0.95),
                                end: const Offset(1.05, 1.05),
                                duration: 1000.ms,
                              ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    pet.name,
                    style: AppTypography.heading2(color: Colors.white),
                  ),
                  Text(
                    'Level ${pet.level} Magical Companion',
                    style: AppTypography.caption(color: AppColors.accent),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Pet Vitals Progress Bars
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Happiness Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Happiness ❤️',
                        style: AppTypography.subtitle1(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        '${pet.happinessPercent}%',
                        style: AppTypography.bodyBold(color: AppColors.danger),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: pet.happinessPercent / 100.0,
                      minHeight: 12,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.danger,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Hunger / Energy Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fullness 🍎',
                        style: AppTypography.subtitle1(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        '${pet.hungerPercent}%',
                        style: AppTypography.bodyBold(color: AppColors.success),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: pet.hungerPercent / 100.0,
                      minHeight: 12,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Pet Care Actions
            Row(
              children: [
                Expanded(
                  child: BouncyButton(
                    text: 'Feed Snack 🍎',
                    gradientStart: AppColors.success,
                    gradientEnd: Colors.teal,
                    onTap: () {
                      ref.read(petProvider.notifier).feedPet();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🍎 Yum! Pet fed (+20 Fullness)!'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BouncyButton(
                    text: 'Play Game 🎾',
                    gradientStart: AppColors.accent,
                    gradientEnd: Colors.orange,
                    onTap: () {
                      ref.read(petProvider.notifier).playWithPet();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🎾 Played with Pet (+25 Happiness)!'),
                          backgroundColor: AppColors.accent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
