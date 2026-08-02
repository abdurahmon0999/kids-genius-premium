import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/services/kids_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    final isVoiceEnabled = ref.watch(isAccessibilityVoiceEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings & Accessibility ⚙️',
          style: AppTypography.heading2(
            color: isDark ? Colors.white : AppColors.primary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Settings
          GlassCard(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(
                    'Dark Mode 🌙',
                    style: AppTypography.subtitle1(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Sleek dark glassmorphism palette',
                    style: AppTypography.caption(color: Colors.grey),
                  ),
                  value: isDark,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    ref.read(isDarkModeProvider.notifier).state = val;
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Accessibility Settings
          Text(
            '♿ Accessibility Settings',
            style: AppTypography.heading3(
              color: isDark ? Colors.white : AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),

          GlassCard(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(
                    'Voice Assistant Reading 🗣️',
                    style: AppTypography.subtitle1(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Read quiz text aloud for young kids',
                    style: AppTypography.caption(color: Colors.grey),
                  ),
                  value: isVoiceEnabled,
                  activeColor: AppColors.secondary,
                  onChanged: (val) {
                    ref
                            .read(isAccessibilityVoiceEnabledProvider.notifier)
                            .state =
                        val;
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    CupertinoIcons.textformat_size,
                    color: AppColors.accent,
                  ),
                  title: Text(
                    'Large Font Size Mode',
                    style: AppTypography.subtitle1(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Enhanced readability for 4-6 age group',
                    style: AppTypography.caption(color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Font size optimized for young learners!',
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
        ],
      ),
    );
  }
}
