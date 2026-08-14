import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:untitled/core/models/kids_models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/bouncy_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/services/kids_providers.dart';
import '../../core/services/security_provider.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showSetPinDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('set_4_digit_pin'.tr()),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: InputDecoration(hintText: 'enter_new_pin'.tr()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr())),
          TextButton(
            onPressed: () {
              if (controller.text.length == 4) {
                ref.read(securityProvider.notifier).setPin(controller.text);
                Navigator.pop(context);
              }
            }, 
            child: Text('save'.tr())
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    final isVoiceEnabled = ref.watch(isAccessibilityVoiceEnabledProvider);
    final securityState = ref.watch(securityProvider);
    final userProfile = ref.watch(userProfileProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Language Settings
        Text(
          'language'.tr(),
          style: AppTypography.heading3(
            color: isDark ? Colors.white : AppColors.primary,
          ),
        ),
        const SizedBox(height: 10),
        GlassCard(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              _buildLanguageTile(context, ref, userProfile, 'O\'zbekcha', 'uz', isDark),
              const Divider(),
              _buildLanguageTile(context, ref, userProfile, 'Русский', 'ru', isDark),
              const Divider(),
              _buildLanguageTile(context, ref, userProfile, 'English', 'en', isDark),
            ],
          ),
        ),

          const SizedBox(height: 24),
          // Security Settings
          Text(
            'app_security'.tr(),
            style: AppTypography.heading3(
              color: isDark ? Colors.white : AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(CupertinoIcons.lock_shield_fill, color: AppColors.primary),
                  title: Text(securityState.isPinSet ? 'change_pin'.tr() : 'set_pin'.tr(), 
                    style: AppTypography.subtitle1(color: isDark ? Colors.white : Colors.black87)),
                  subtitle: Text(securityState.isPinSet ? 'pin_protection_active'.tr() : 'secure_app_hint'.tr(),
                    style: AppTypography.caption(color: Colors.grey)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showSetPinDialog(context, ref),
                ),
                if (securityState.isPinSet) ...[
                  const Divider(),
                  SwitchListTile(
                    title: Text('biometrics'.tr(), style: AppTypography.subtitle1(color: isDark ? Colors.white : Colors.black87)),
                    subtitle: Text('biometrics_subtitle'.tr(), style: AppTypography.caption(color: Colors.grey)),
                    value: securityState.isBiometricsEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => ref.read(securityProvider.notifier).toggleBiometrics(val),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(CupertinoIcons.trash, color: Colors.redAccent),
                    title: Text('remove_security'.tr(), style: const TextStyle(color: Colors.redAccent)),
                    onTap: () => ref.read(securityProvider.notifier).removePin(),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),
          GlassCard(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(
                    'dark_mode'.tr(),
                    style: AppTypography.subtitle1(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'dark_mode_subtitle'.tr(),
                    style: AppTypography.caption(color: Colors.grey),
                  ),
                  value: isDark,
                  activeThumbColor: AppColors.primary,
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
            '♿ ${'accessibility_settings'.tr()}',
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
                    'voice_assistant'.tr(),
                    style: AppTypography.subtitle1(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'voice_assistant_subtitle'.tr(),
                    style: AppTypography.caption(color: Colors.grey),
                  ),
                  value: isVoiceEnabled,
                  activeThumbColor: AppColors.secondary,
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
                    'large_font'.tr(),
                    style: AppTypography.subtitle1(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'large_font_subtitle'.tr(),
                    style: AppTypography.caption(color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'font_size_msg'.tr(),
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
          const SizedBox(height: 32),
          BouncyButton(
            text: 'logout'.tr(),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
            },
            gradientStart: Colors.redAccent,
            gradientEnd: Colors.orangeAccent,
          ),
          const SizedBox(height: 100), // Extra space for bottom nav
        ],
      );
  }

  Widget _buildLanguageTile(BuildContext context, WidgetRef ref, UserProfileModel user, String title, String code, bool isDark) {
    final isSelected = context.locale.languageCode == code;
    return ListTile(
      title: Text(
        title, 
        style: TextStyle(
          color: isSelected 
              ? AppColors.primary 
              : (isDark ? Colors.white70 : Colors.black87), 
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
        )
      ),
      trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
      onTap: () {
        context.setLocale(Locale(code));
        final updatedUser = user.copyWith(language: code);
        ref.read(userProfileProvider.notifier).setUser(updatedUser);
      },
    );
  }
}
