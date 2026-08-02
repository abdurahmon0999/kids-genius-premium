import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/bouncy_button.dart';
import '../../core/services/kids_providers.dart';

class AvatarBuilderScreen extends ConsumerStatefulWidget {
  const AvatarBuilderScreen({super.key});

  @override
  ConsumerState<AvatarBuilderScreen> createState() =>
      _AvatarBuilderScreenState();
}

class _AvatarBuilderScreenState extends ConsumerState<AvatarBuilderScreen> {
  final List<String> _hats = ['👑', '🧙‍♂️', '🎓', '🎩', '⛑️', '🧢', '🎀', '🤠'];
  final List<String> _outfits = ['🚀', '🦸‍♂️', '🥋', '🥼', '🎨', '⚽', '🎒', '🛡️'];

  late String _selectedHat;
  late String _selectedOutfit;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProfileProvider);
    _selectedHat = user.activeAvatarHat;
    _selectedOutfit = user.activeAvatarOutfit;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('3D Avatar Studio 🎨',
            style: AppTypography.heading2(
                color: isDark ? Colors.white : AppColors.primary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar Preview Stage Card
            GlassCard(
              padding: const EdgeInsets.all(28),
              customGradient: AppColors.heroGradient,
              child: Column(
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.4),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_selectedHat, style: const TextStyle(fontSize: 36)),
                          Text('🧑‍🚀 $_selectedOutfit', style: const TextStyle(fontSize: 38)),
                        ],
                      ),
                    ),
                  ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 16),
                  Text(
                    'Hero Avatar Preview',
                    style: AppTypography.heading3(color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Hat Selector Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '🎩 Headwear & Crowns',
                style: AppTypography.heading3(
                    color: isDark ? Colors.white : AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _hats.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final hat = _hats[index];
                  final isSelected = _selectedHat == hat;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedHat = hat),
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent
                            : (isDark ? Colors.white10 : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.accent : Colors.black12,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(hat, style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Outfit Selector Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '👕 Suits & Accessories',
                style: AppTypography.heading3(
                    color: isDark ? Colors.white : AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _outfits.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final outfit = _outfits[index];
                  final isSelected = _selectedOutfit == outfit;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedOutfit = outfit),
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.secondary
                            : (isDark ? Colors.white10 : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.secondary : Colors.black12,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(outfit, style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // Save Avatar Button
            BouncyButton(
              text: 'Save & Equip Avatar ✨',
              gradientStart: AppColors.primary,
              gradientEnd: AppColors.secondary,
              onTap: () {
                ref.read(userProfileProvider.notifier).updateAvatar(
                      hat: _selectedHat,
                      outfit: _selectedOutfit,
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✨ Avatar updated and equipped!'),
                    backgroundColor: AppColors.primary,
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
}
