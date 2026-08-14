import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
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
    final shopItemsAsync = ref.watch(shopItemsProvider);
    final ownedItems = ref.watch(userPurchasesProvider);
    final user = ref.watch(userProfileProvider);
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('shop_title'),
            style: AppTypography.heading2(
                color: isDark ? Colors.white : AppColors.primary)),
      ),
      body: shopItemsAsync.when(
        data: (shopItems) {
          if (shopItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🛍️', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 16),
                  Text(tr('no_items_found'), style: AppTypography.heading3(color: isDark ? Colors.white : AppColors.primary)),
                  const SizedBox(height: 8),
                  Text(tr('admin_add_hint'), style: AppTypography.caption(color: Colors.grey), textAlign: TextAlign.center),
                ],
              ),
            );
          }
          return SingleChildScrollView(
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
                            tr('coin_balance'),
                            style: AppTypography.caption(color: Colors.white70),
                          ),
                          Text(
                            '${user.coins} ${tr('coins_text')}',
                            style: AppTypography.heading2(color: Colors.white),
                          ),
                        ],
                      ),
                      const Spacer(),
                      BouncyButton(
                        text: tr('spin_wheel'),
                        height: 40,
                        gradientStart: AppColors.purpleMagic,
                        gradientEnd: AppColors.primary,
                        onTap: () {
                          ref.read(userProfileProvider.notifier).addCoins(100);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(tr('wheel_spun_msg')),
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
                  tr('cosmetics_title'),
                  style: AppTypography.heading3(
                      color: isDark ? Colors.white : AppColors.primary),
                ),
                const SizedBox(height: 12),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: shopItems.length,
                  padding: const EdgeInsets.only(bottom: 100), // Ensure space at bottom
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72, // Adjusted for better text fitting
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemBuilder: (context, index) {
                    final item = shopItems[index];
                    final isOwned = ownedItems.contains(item.id);
                    final rarityColor = _getRarityColor(item.rarity);

                    return GlassCard(
                      padding: const EdgeInsets.all(12),
                      customBorderColor: rarityColor.withValues(alpha: 0.6),
                      child: Column(
                        children: [
                          // Rarity Badge
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: rarityColor.withValues(alpha: 0.2),
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
                          if (isOwned) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                tr('owned'),
                                textAlign: TextAlign.center,
                                style: AppTypography.bodyBold(color: AppColors.success),
                              ),
                            ),
                          ] else ...[
                            BouncyButton(
                              text: '${item.coinCost} 🪙',
                              height: 34,
                              gradientStart: rarityColor,
                              gradientEnd: rarityColor.withValues(alpha: 0.8),
                              onTap: () {
                                final success = ref
                                    .read(userProfileProvider.notifier)
                                    .spendCoins(item.coinCost);
                                if (success) {
                                  ref
                                      .read(userPurchasesProvider.notifier)
                                      .addPurchase(item.id);
                                  if (item.type == 'hat') {
                                    ref
                                        .read(userProfileProvider.notifier)
                                        .updateAvatar(hat: item.emoji);
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(tr('purchased_msg', args: [item.name])),
                                      backgroundColor: AppColors.success,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                } else {
                                  // Show request option if not enough coins
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            title: Text(tr('not_enough_coins')),
                                            content: Text(tr('request_parent_msg', args: [item.name])),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(context), child: Text(tr('cancel'))),
                                              TextButton(
                                                  onPressed: () {
                                                    ref.read(userPurchasesProvider.notifier).requestItem(item.id);
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text(tr('request_sent')), behavior: SnackBarBehavior.floating),
                                                    );
                                                  },
                                                  child: Text(tr('send_message'))),
                                            ],
                                          ));
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(tr('error_unknown'))),
      ),
    );
  }
}
