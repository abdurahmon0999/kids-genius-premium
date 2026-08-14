import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/services/kids_providers.dart';

import '../../features/details/details_screen.dart';

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsProvider);
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      body: newsAsync.when(
        data: (items) {
          if (items.isEmpty) return Center(child: Text('no_news'.tr()));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsScreen(
                      itemId: item.id,
                      title: item.title,
                      description: item.content,
                      imageUrl: item.imageUrl,
                    )));
                  },
                  child: GlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Image.network(
                            item.imageUrl, 
                            height: 150, 
                            width: double.infinity, 
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(height: 150, color: Colors.grey.shade200, child: const Icon(Icons.newspaper, size: 50)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: AppTypography.subtitle1(color: isDark ? Colors.white : Colors.black)),
                              const SizedBox(height: 8),
                              Text(item.summary, style: AppTypography.caption(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('no_news'.tr())),
      ),
    );
  }
}
