import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/bouncy_button.dart';
import '../../core/services/kids_providers.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/models/kids_models.dart';
import 'package:intl/intl.dart';

class InfoScreen extends ConsumerStatefulWidget {
  const InfoScreen({super.key});

  @override
  ConsumerState<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends ConsumerState<InfoScreen> {
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final comment = _reviewController.text.trim();
    if (comment.isEmpty) return;

    setState(() => _isSubmitting = true);
    
    final user = ref.read(userProfileProvider);
    final review = UserReview(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.uid,
      userName: user.name,
      comment: comment,
      rating: 5.0, // Default for now
      date: DateTime.now(),
    );

    try {
      // 1. Save to Local Storage
      ref.read(localReviewsProvider.notifier).addReview(review);

      // 2. Save to Firestore
      await FirebaseFirestore.instance.collection('reviews').add(review.toJson());

      // 3. Show Local Notification
      await NotificationService.showNotification(
        id: 99,
        title: 'review_accepted'.tr(),
        body: 'Kids Genius',
      );

      _reviewController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('review_accepted'.tr()), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving review'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final localReviews = ref.watch(localReviewsProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('🦁', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text('info'.tr(), style: AppTypography.heading2(color: isDark ? Colors.white : AppColors.primary)),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Text(
                'info_desc'.tr(),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            
            // Write Review Section
            Text('write_review'.tr(), style: AppTypography.heading3(color: isDark ? Colors.white : AppColors.primary)),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _reviewController,
                    maxLines: 3,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'review_hint'.tr(),
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isSubmitting)
                    const CircularProgressIndicator()
                  else
                    BouncyButton(
                      text: 'submit_review'.tr(),
                      onTap: _submitReview,
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Reviews List Section (Local + could be mixed)
            Text('reviews_list'.tr(), style: AppTypography.heading3(color: isDark ? Colors.white : AppColors.primary)),
            const SizedBox(height: 12),
            if (localReviews.isEmpty)
              Text('no_reviews_yet'.tr(), style: const TextStyle(color: Colors.grey))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: localReviews.length,
                reverse: true, // Show latest first
                itemBuilder: (context, index) {
                  final review = localReviews[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(review.userName, style: AppTypography.bodyBold(color: isDark ? AppColors.accent : AppColors.primary)),
                              Text(
                                DateFormat('dd.MM.yyyy').format(review.date),
                                style: AppTypography.caption(color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(review.comment, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                        ],
                      ),
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
