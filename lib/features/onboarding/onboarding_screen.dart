import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/bouncy_button.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinished;
  const OnboardingScreen({super.key, required this.onFinished});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      icon: Icons.auto_awesome,
      title: 'onboarding_title_1'.tr(),
      desc: 'onboarding_desc_1'.tr(),
      color: AppColors.primary,
    ),
    OnboardingData(
      icon: Icons.videogame_asset,
      title: 'onboarding_title_2'.tr(),
      desc: 'onboarding_desc_2'.tr(),
      color: AppColors.secondary,
    ),
    OnboardingData(
      icon: Icons.pets,
      title: 'onboarding_title_3'.tr(),
      desc: 'onboarding_desc_3'.tr(),
      color: AppColors.success,
    ),
    OnboardingData(
      icon: Icons.emoji_events,
      title: 'onboarding_title_4'.tr(),
      desc: 'onboarding_desc_4'.tr(),
      color: AppColors.accent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemBuilder: (context, index) {
              final data = _pages[index];
              return Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [data.color.withValues(alpha: 0.8), AppColors.bgLight],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(data.icon, size: 120, color: Colors.white)
                        .animate()
                        .scale(duration: 600.ms, curve: Curves.elasticOut)
                        .shimmer(duration: 2.seconds),
                    const SizedBox(height: 40),
                    Text(data.title, 
                      textAlign: TextAlign.center,
                      style: AppTypography.heading1(color: Colors.white)),
                    const SizedBox(height: 20),
                    Text(data.desc, 
                      textAlign: TextAlign.center,
                      style: AppTypography.subtitle1(color: Colors.black87)),
                  ],
                ),
              );
            },
          ),
          
          // Navigation Controls
          Positioned(
            bottom: 60,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) => _buildIndicator(index)),
                ),
                const SizedBox(height: 32),
                BouncyButton(
                  text: _currentPage == _pages.length - 1 ? 'start_adventure'.tr() : 'next'.tr(),
                  onTap: () async {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(duration: 300.ms, curve: Curves.easeIn);
                    } else {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('is_first_launch', false);
                      widget.onFinished();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    bool isSel = _currentPage == index;
    return AnimatedContainer(
      duration: 200.ms,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isSel ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isSel ? Colors.white : Colors.white54,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingData {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  OnboardingData({required this.icon, required this.title, required this.desc, required this.color});
}
