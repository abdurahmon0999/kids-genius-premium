import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/services/security_provider.dart';
import '../../core/services/voice_service.dart';
import '../../core/services/kids_providers.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  String _enteredPin = "";
  bool _isError = false;

  void _onNumberTap(String val) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += val;
        _isError = false;
      });

      if (_enteredPin.length == 4) {
        _verify();
      }
    }
  }

  void _onDelete() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  Future<void> _verify() async {
    final success = await ref.read(securityProvider.notifier).verifyPin(_enteredPin);
    if (success) {
      VoiceService.speak(tr('welcome_back'));
    } else {
      setState(() {
        _isError = true;
        _enteredPin = "";
      });
      VoiceService.speak(tr('pin_incorrect'));
    }
  }

  @override
  void initState() {
    super.initState();
    // Auto-trigger biometrics if enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(securityProvider);
      if (state.isBiometricsEnabled) {
        ref.read(securityProvider.notifier).authenticateBiometrically();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final state = ref.watch(securityProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark ? [AppColors.bgDark, AppColors.cardDark] : [AppColors.primary.withValues(alpha: 0.1), AppColors.bgLight],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🛡️', style: TextStyle(fontSize: 60))
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 2.seconds),
              const SizedBox(height: 20),
              Text(
                tr('security_title'),
                style: AppTypography.heading2(color: isDark ? Colors.white : AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                tr('enter_pin_continue'),
                style: AppTypography.caption(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              
              // PIN Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  bool filled = _enteredPin.length > index;
                  return AnimatedContainer(
                    duration: 200.ms,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isError ? Colors.red : (filled ? AppColors.primary : Colors.grey.withValues(alpha: 0.3)),
                      border: Border.all(color: filled ? AppColors.accent : Colors.transparent, width: 2),
                    ),
                  ).animate(target: _isError ? 1 : 0).shake(hz: 8, curve: Curves.easeInOut);
                }),
              ),
              
              const SizedBox(height: 50),
              
              // Number Pad
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    _buildRow(["1", "2", "3"], isDark),
                    _buildRow(["4", "5", "6"], isDark),
                    _buildRow(["7", "8", "9"], isDark),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlBtn(
                          icon: state.isBiometricsEnabled ? CupertinoIcons.device_phone_portrait : null, 
                          onTap: state.isBiometricsEnabled ? () => ref.read(securityProvider.notifier).authenticateBiometrically() : null,
                          isDark: isDark,
                        ),
                        _buildNumBtn("0", isDark),
                        _buildControlBtn(icon: CupertinoIcons.delete_left, onTap: _onDelete, isDark: isDark),
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

  Widget _buildRow(List<String> nums, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: nums.map((n) => _buildNumBtn(n, isDark)).toList(),
      ),
    );
  }

  Widget _buildNumBtn(String text, bool isDark) {
    return GestureDetector(
      onTap: () => _onNumberTap(text),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
        ),
        alignment: Alignment.center,
        child: Text(text, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
      ),
    );
  }

  Widget _buildControlBtn({IconData? icon, VoidCallback? onTap, required bool isDark}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        alignment: Alignment.center,
        child: icon != null ? Icon(icon, color: isDark ? Colors.white70 : Colors.black54, size: 30) : null,
      ),
    );
  }
}
