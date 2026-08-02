import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/cupertino.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/bouncy_button.dart';
import '../../core/models/kids_models.dart';
import '../../core/services/kids_providers.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  Color _getRarityColor(Rarity rarity) {
    switch (rarity) {
      case Rarity.common:
        return Colors.grey;
      case Rarity.rare:
        return AppColors.secondary;
      case Rarity.epic:
        return AppColors.purpleMagic;
      case Rarity.legendary:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopItems = ref.watch(shopItemsProvider);
    final user = ref.watch(userProfileProvider);
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Item Shop & Mystery Box 🛍️',
            style: AppTypography.heading2(
                color: isDark ? Colors.white : AppColors.primary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coin Balance Showcase Card
            GlassCard(
              padding: const EdgeInsets.all(16),
              customGradient: AppColors.coinGradient,
              child: Row(
                children: [
                  const Icon(CupertinoIcons.money_dollar_circle_fill,
                      color: Colors.white, size: 36),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Coin Balance',
                        style: AppTypography.caption(color: Colors.white70),
                      ),
                      Text(
                        '${user.coins} Coins',
                        style: AppTypography.heading2(color: Colors.white),
                      ),
                    ],
                  ),
                  const Spacer(),
                  BouncyButton(
                    text: 'Spin Wheel 🎡',
                    height: 40,
                    gradientStart: AppColors.purpleMagic,
                    gradientEnd: AppColors.primary,
                    onTap: () {
                      ref.read(userProfileProvider.notifier).addCoins(100);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🎡 Wheel Spun! Won 100 Lucky Coins! 🎉'),
                          backgroundColor: AppColors.purpleMagic,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Shop Items Grid Header
            Text(
              '✨ Rare & Legendary Cosmetics',
              style: AppTypography.heading3(
                  color: isDark ? Colors.white : AppColors.primary),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: shopItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.78,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final item = shopItems[index];
                final rarityColor = _getRarityColor(item.rarity);

                return GlassCard(
                  padding: const EdgeInsets.all(12),
                  customBorderColor: rarityColor.withOpacity(0.6),
                  child: Column(
                    children: [
                      // Rarity Badge
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: rarityColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: rarityColor, width: 1),
                          ),
                          child: Text(
                            item.rarity.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: rarityColor,
                            ),
                          ),
                        ),
                      ),

                      // Emoji Image
                      Text(
                        item.emoji,
                        style: const TextStyle(fontSize: 44),
                      ).animate().scale(duration: 300.ms),

                      const SizedBox(height: 6),

                      Text(
                        item.name,
                        style: AppTypography.bodyBold(
                            color: isDark ? Colors.white : Colors.black),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const Spacer(),

                      // Buy Button / Owned Badge / Request Button
                      if (item.isPurchased) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'OWNED ✓',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyBold(color: AppColors.success),
                          ),
                        ),
                      ] else if (item.isRequested) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'WAITING... 🛡️',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyBold(color: AppColors.primary),
                          ),
                        ),
                      ] else ...[
                        BouncyButton(
                          text: '${item.coinCost} 🪙',
                          height: 34,
                          gradientStart: rarityColor,
                          gradientEnd: rarityColor.withOpacity(0.8),
                          onTap: () {
                            final success = ref
                                .read(userProfileProvider.notifier)
                                .spendCoins(item.coinCost);
                            if (success) {
                              ref
                                  .read(shopItemsProvider.notifier)
                                  .buyItem(item.id);
                              if (item.type == 'hat') {
                                ref
                                    .read(userProfileProvider.notifier)
                                    .updateAvatar(hat: item.emoji);
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '🎉 Purchased ${item.name}! Equipped to avatar!'),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } else {
                               // Show request option if not enough coins
                               showDialog(
                                 context: context,
                                 builder: (context) => AlertDialog(
                                   title: const Text('Not Enough Coins!'),
                                   content: Text('Would you like to request "${item.name}" from your parents?'),
                                   actions: [
                                     TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                     TextButton(
                                       onPressed: () {
                                         ref.read(shopItemsProvider.notifier).requestItem(item.id);
                                         Navigator.pop(context);
                                         ScaffoldMessenger.of(context).showSnackBar(
                                           const SnackBar(content: Text('Request sent to Parents! 🛡️'), behavior: SnackBarBehavior.floating),
                                         );
                                       }, 
                                       child: const Text('Send Request 📩')
                                     ),
                                   ],
                                 )
                               );
                            }
                          },
                        ),
                      ],
                    ],
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
