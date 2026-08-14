import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/services/kids_providers.dart';

import '../../features/details/details_screen.dart';

class BlogScreen extends ConsumerWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blogsAsync = ref.watch(blogProvider);
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      body: blogsAsync.when(
        data: (blogs) {
          if (blogs.isEmpty) return Center(child: Text('no_blogs'.tr()));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: blogs.length,
            itemBuilder: (context, index) {
              final blog = blogs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GlassCard(
                  padding: const EdgeInsets.all(4),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        blog.imageUrl, 
                        width: 60, height: 60, 
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(width: 60, height: 60, color: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.article)),
                      ),
                    ),
                    title: Text(blog.title, style: AppTypography.subtitle1(color: isDark ? Colors.white : Colors.black87)),
                    subtitle: Text('by_author'.tr(args: [blog.author]), style: AppTypography.caption(color: Colors.grey)),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsScreen(
                        itemId: blog.id,
                        title: blog.title,
                        description: blog.content,
                        imageUrl: blog.imageUrl,
                      )));
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('no_blogs'.tr())),
      ),
    );
  }
}
