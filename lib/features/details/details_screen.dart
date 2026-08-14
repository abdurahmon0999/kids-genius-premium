import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/kids_models.dart';
import '../../core/services/kids_providers.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/bouncy_button.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class DetailsScreen extends ConsumerStatefulWidget {
  final String itemId;
  final String title;
  final String description;
  final String imageUrl;

  const DetailsScreen({
    super.key,
    required this.itemId,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  ConsumerState<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends ConsumerState<DetailsScreen> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 5.0;

  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty) return;

    final user = ref.read(userProfileProvider);
    final review = UserReview(
      id: '',
      userId: user.uid,
      userName: user.name,
      comment: _reviewController.text.trim(),
      rating: _rating,
      date: DateTime.now(),
    );

    // Save to Firestore
    await FirebaseFirestore.instance.collection('reviews').add(review.toJson());

    // Save to LocalStorage
    await StorageService.saveReviewLocal(review);

    final messenger = ScaffoldMessenger.of(context);
    // Trigger Notification
    await NotificationService.showNotification(
      id: 1,
      title: tr('review_accepted'),
      body: tr('app_name'),
    );

    _reviewController.clear();
    setState(() {
      _rating = 5.0;
    });

    messenger.showSnackBar(
      SnackBar(content: Text(tr('thank_you_review'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviews = ref.watch(reviewsProvider);
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  widget.imageUrl, 
                  height: 250, 
                  width: double.infinity, 
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    height: 250, 
                    width: double.infinity, 
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.image, size: 80, color: Colors.white24),
                  ),
                ),
              ).animate().fadeIn().scale(),
            const SizedBox(height: 20),
            Text(widget.title, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 12),
            Text(widget.description, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 30),
            
            // Review Input
            Text(tr('write_review_title'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () => setState(() => _rating = index + 1.0),
                      );
                    }),
                  ),
                  TextField(
                    controller: _reviewController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: tr('review_hint'),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  BouncyButton(
                    text: tr('submit_review_btn'),
                    onTap: _submitReview,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            Text(tr('reviews_list'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 12),
            reviews.when(
              data: (data) => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final r = data[index];
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
                              Text(r.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Row(
                                children: List.generate(5, (i) => Icon(
                                  i < r.rating ? Icons.star : Icons.star_border,
                                  size: 14,
                                  color: Colors.amber,
                                )),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(r.comment),
                          const SizedBox(height: 4),
                          Text(DateFormat('dd.MM.yyyy HH:mm').format(r.date), style: const TextStyle(color: Colors.grey, fontSize: 10)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('error_unknown'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
