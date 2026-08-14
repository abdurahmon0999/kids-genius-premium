import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/bouncy_button.dart';
import '../../core/widgets/coin_xp_header.dart';
import '../../core/services/kids_providers.dart';
import '../../core/models/kids_models.dart';

class ChildDashboardScreen extends ConsumerWidget {
  const ChildDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final carouselAsync = ref.watch(carouselProvider);
    final isDark = ref.watch(isDarkModeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          carouselAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return _buildDummyCarousel();
              }
              return Column(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 200,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      aspectRatio: 16 / 9,
                      viewportFraction: 0.95,
                      onPageChanged: (index, reason) {
                        // Can add page indicator state here if needed
                      },
                    ),
                    items: items.map((item) => _buildCarouselItem(item)).toList(),
                  ),
                ],
              );
            },
            loading: () => Container(
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(child: CircularProgressIndicator(color: AppColors.accent)),
            ),
            error: (e, _) => _buildDummyCarousel(),
          ),

          const SizedBox(height: 16),

          // User Stats
          CoinXpHeader(
            coins: user.coins, xp: user.xp, level: user.level, streakDays: user.streakDays,
            onCoinTap: () => ref.read(selectedTabProvider.notifier).state = 4,
          ),
          
          const SizedBox(height: 16),

          // Quick Navigation Grid (8+ Pages)
          Text('magical_world'.tr(), style: AppTypography.heading3(color: isDark ? Colors.white : AppColors.primary)),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2,
            children: [
              _buildNavCard(ref, 5, 'news'.tr(), '📰', AppColors.primary),
              _buildNavCard(ref, 6, 'blog'.tr(), '📝', AppColors.secondary),
              _buildNavCard(ref, 7, 'info'.tr(), 'ℹ️', AppColors.accent),
              _buildNavCard(ref, 8, 'contact'.tr(), '📞', AppColors.success),
            ],
          ),

          const SizedBox(height: 24),
          
          // Quest Section
          Text(tr('daily_quests'), style: AppTypography.heading3(color: isDark ? Colors.white : AppColors.primary)),
          const SizedBox(height: 10),
          _buildQuestList(ref, isDark),
        ],
      ),
    );
  }

  Widget _buildCarouselItem(CarouselItem item) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.primary.withValues(alpha: 0.2),
                child: const Center(child: Icon(Icons.image_not_supported, color: Colors.white, size: 40)),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.black87, Colors.black45, Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: const [0.0, 0.4, 0.8],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(8)),
                  child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Text(item.title, style: AppTypography.heading3(color: Colors.white)),
                Text(
                  item.description,
                  style: AppTypography.caption(color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDummyCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 16/9,
        viewportFraction: 0.9,
      ),
      items: [
        CarouselItem(id: 'd1', imageUrl: 'https://images.unsplash.com/photo-1488190211105-8b0e65b80b4e', title: 'welcome'.tr(), description: 'Learn and play every day.'),
        CarouselItem(id: 'd2', imageUrl: 'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9', title: 'magical_world'.tr(), description: 'Explore the magical world.'),
      ].map((item) => _buildCarouselItem(item)).toList(),
    );
  }

  Widget _buildNavCard(WidgetRef ref, int index, String title, String emoji, Color color) {
    return GestureDetector(
      onTap: () => ref.read(navigationHelperProvider)(index),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        customBorderColor: color.withOpacity(0.4),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(title, style: AppTypography.bodyBold()),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestList(WidgetRef ref, bool isDark) {
    final quests = ref.watch(questProvider);
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: quests.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final quest = quests[index];
          return Container(
            width: 180,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.05), 
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white24 : AppColors.primary.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(quest.iconEmoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Expanded(child: Text(tr(quest.title), style: AppTypography.bodyBold(color: isDark ? Colors.white : AppColors.primary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (quest.currentProgress / quest.goalCount).clamp(0.0, 1.0), 
                    color: AppColors.secondary,
                    backgroundColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
                    minHeight: 6,
                  ),
                ),
                const Spacer(),
                if (quest.isCompleted && !quest.isClaimed)
                  BouncyButton(text: tr('claim'), height: 24, fontSize: 10, onTap: () => ref.read(questProvider.notifier).claimReward(quest.id, ref))
                else
                  Text('${quest.currentProgress}/${quest.goalCount}', style: AppTypography.caption(color: isDark ? Colors.white70 : Colors.black54)),
              ],
            ),
          );
        },
      ),
    );
  }
}
