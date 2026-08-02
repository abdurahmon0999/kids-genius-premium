import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'glass_card.dart';
import '../services/voice_service.dart';

class MascotWidget extends StatelessWidget {
  final String speechText;
  final VoidCallback? onTap;

  const MascotWidget({
    super.key,
    required this.speechText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        VoiceService.speak(speechText);
        if (onTap != null) onTap!();
      },
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        customGradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.9),
            AppColors.secondary.withOpacity(0.9),
          ],
        ),
        child: Row(
          children: [
            // Mascot Animated Avatar Container
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.6),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: const Text(
                  '🦁',
                  style: TextStyle(fontSize: 34),
                )
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .rotate(begin: -0.05, end: 0.05, duration: 1200.ms)
                    .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05)),
              ),
            ),
            const SizedBox(width: 16),

            // Speech Bubble Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Genie the Lion',
                    style: AppTypography.caption(color: AppColors.accent),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    speechText,
                    style: AppTypography.subtitle1(color: Colors.white),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white70,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
