import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/models/kids_models.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('admin_panel')),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatCards(),
            const SizedBox(height: 24),
            _buildActivityChart(),
            const SizedBox(height: 24),
            Text(tr('unified_content'), style: AppTypography.heading3()),
            const SizedBox(height: 12),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        _statCard(tr('total_kids'), '1,284', Colors.blue),
        const SizedBox(width: 12),
        _statCard(tr('daily_active'), '452', Colors.green),
        const SizedBox(width: 12),
        _statCard(tr('revenue'), '\$4.2k', Colors.orange),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChart() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('platform_activity'), style: AppTypography.subtitle1()),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 2), FlSpot(3, 5),
                      FlSpot(4, 3.5), FlSpot(5, 4.5), FlSpot(6, 4),
                    ],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.1)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        _actionTile(tr('manage_carousel'), Icons.view_carousel, Colors.blue, () => _showManageContentDialog(context, 'carousel')),
        _actionTile(tr('manage_blog'), Icons.article, Colors.orange, () => _showManageContentDialog(context, 'blog')),
        _actionTile(tr('manage_news'), Icons.newspaper, Colors.red, () => _showManageContentDialog(context, 'news')),
        _actionTile(tr('manage_shop'), Icons.shopping_bag, Colors.green, () => _showManageContentDialog(context, 'shop_items')),
        _actionTile(tr('manage_messages'), Icons.message, Colors.cyan, () => _showManageMessagesDialog(context)),
        _actionTile(tr('manage_reviews'), Icons.star_rate, Colors.amber, () => _showManageReviewsDialog(context)),
        _actionTile(tr('seed_data'), Icons.auto_awesome, Colors.deepPurple, () => _seedInitialData(context)),
        _actionTile(tr('user_management'), Icons.people, Colors.purple, () {}),
      ],
    );
  }

  Widget _actionTile(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Future<void> _seedInitialData(BuildContext context) async {
    final batch = FirebaseFirestore.instance.batch();
    
    // 1. Seed Shop Items (15+ items)
    final shopItems = [
      {'name': 'Royal Crown', 'emoji': '👑', 'coinCost': 500, 'type': 'hat', 'rarity': 3},
      {'name': 'Space Helmet', 'emoji': '🧑‍🚀', 'coinCost': 350, 'type': 'hat', 'rarity': 2},
      {'name': 'Wizard Hat', 'emoji': '🧙‍♂️', 'coinCost': 200, 'type': 'hat', 'rarity': 2},
      {'name': 'Golden Wings', 'emoji': '👼', 'coinCost': 800, 'type': 'outfit', 'rarity': 3},
      {'name': 'Magic Cape', 'emoji': '🧥', 'coinCost': 300, 'type': 'outfit', 'rarity': 1},
      {'name': 'Dino Suit', 'emoji': '🦖', 'coinCost': 450, 'type': 'outfit', 'rarity': 2},
      {'name': 'Robot Pet', 'emoji': '🤖', 'coinCost': 1000, 'type': 'pet', 'rarity': 3},
      {'name': 'Alien Friend', 'emoji': '👽', 'coinCost': 600, 'type': 'pet', 'rarity': 2},
      {'name': 'Cat Ears', 'emoji': '🐱', 'coinCost': 100, 'type': 'hat', 'rarity': 0},
      {'name': 'Superhero Mask', 'emoji': '🎭', 'coinCost': 250, 'type': 'hat', 'rarity': 1},
      {'name': 'Magic Wand', 'emoji': '🪄', 'coinCost': 400, 'type': 'mystery', 'rarity': 2},
      {'name': 'Star Shield', 'emoji': '🛡️', 'coinCost': 550, 'type': 'mystery', 'rarity': 2},
      {'name': 'Crystal Ball', 'emoji': '🔮', 'coinCost': 700, 'type': 'mystery', 'rarity': 3},
      {'name': 'Unicorn Pet', 'emoji': '🦄', 'coinCost': 1200, 'type': 'pet', 'rarity': 3},
      {'name': 'Pirate Hat', 'emoji': '🏴‍☠️', 'coinCost': 150, 'type': 'hat', 'rarity': 1},
    ];

    for (var item in shopItems) {
      final docRef = FirebaseFirestore.instance.collection('shop_items').doc();
      batch.set(docRef, item);
    }

    // 2. Seed Initial News
    final news = [
      {
        'title': 'New Quest System!',
        'summary': 'Quests now stay saved on your device.',
        'content': 'We have upgraded the daily quests. Your progress is now safely stored even if you close the app. Finish tasks and claim your rewards!',
        'imageUrl': 'https://images.unsplash.com/photo-1550745679-56521f313a29',
        'date': Timestamp.now(),
      },
      {
        'title': 'Grand Shop Opening!',
        'summary': '15+ new legendary items added.',
        'content': 'Visit the shop to see new crowns, outfits, and pets! Earn coins in games to collect them all.',
        'imageUrl': 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da',
        'date': Timestamp.now(),
      },
    ];

    for (var item in news) {
      final docRef = FirebaseFirestore.instance.collection('news').doc();
      batch.set(docRef, item);
    }

    // 3. Seed Blog Posts
    final blogs = [
      {
        'title': 'How to be a Math Hero 🦸‍♂️',
        'content': 'Mathematics is a super power! To become a master, practice every day for at least 15 minutes. Use our Math Quest game to learn counting and shapes in a fun way.',
        'imageUrl': 'https://images.unsplash.com/photo-1509228468518-180dd4864904',
        'author': 'Teacher Leo',
        'date': Timestamp.now(),
      },
      {
        'title': 'The Secret World of Dinosaurs 🦖',
        'content': 'Did you know that birds are descendants of dinosaurs? Explore the Dino Suit in our shop and learn about the Jurassic era while playing.',
        'imageUrl': 'https://images.unsplash.com/photo-1525857597365-5f6dbff2e36e',
        'author': 'Science Sam',
        'date': Timestamp.now(),
      },
      {
        'title': 'Stay Safe Online! 🛡️',
        'content': 'Always ask your parents before downloading new apps. Our Kids Genius security system is here to keep your progress safe with your secret 4-digit PIN.',
        'imageUrl': 'https://images.unsplash.com/photo-1563986768609-322da13575f3',
        'author': 'Admin',
        'date': Timestamp.now(),
      },
    ];

    for (var item in blogs) {
      final docRef = FirebaseFirestore.instance.collection('blog').doc();
      batch.set(docRef, item);
    }

    // 4. Reset Sky Rush stats for testing
    // (Optional: can add logic here if we want to reset all users' game data)

    try {
      await batch.commit();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('seed_success')), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('seed_error', args: [e.toString()])), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  void _showManageMessagesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('support_messages')),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('support_messages').orderBy('timestamp', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return Center(child: Text(tr('no_messages')));
              
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      title: Text(data['userName'] ?? 'Anonymous'),
                      subtitle: Text(data['message'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(tr('delete_message_confirm')),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: Text(tr('cancel'))),
                                TextButton(
                                  onPressed: () {
                                    doc.reference.delete();
                                    Navigator.pop(context);
                                  }, 
                                  child: Text(tr('add_btn'), style: const TextStyle(color: Colors.redAccent))
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(tr('close'))),
        ],
      ),
    );
  }

  void _showManageReviewsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('all_reviews')),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('reviews').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return Center(child: Text(tr('no_reviews')));

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(tr('review_by', args: [data['userName'] ?? 'Anonymous']), style: const TextStyle(fontWeight: FontWeight.bold))),
                          Row(
                            children: List.generate(5, (i) => Icon(
                              i < (data['rating'] ?? 5.0).toDouble() ? Icons.star : Icons.star_border,
                              size: 14,
                              color: Colors.amber,
                            )),
                          ),
                        ],
                      ),
                      subtitle: Text(data['comment'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(tr('delete_message_confirm')),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: Text(tr('cancel'))),
                                TextButton(
                                  onPressed: () {
                                    doc.reference.delete();
                                    Navigator.pop(context);
                                  }, 
                                  child: Text(tr('add_btn'), style: const TextStyle(color: Colors.redAccent))
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(tr('close'))),
        ],
      ),
    );
  }

  void _showManageContentDialog(BuildContext context, String collection) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(tr('manage_title', args: [collection.replaceAll('_', ' ').toUpperCase()])),
            content: SizedBox(
              width: double.maxFinite,
              height: 400, // Added fixed height to prevent layout errors with Expanded
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection(collection).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(tr('current_items', args: [docs.length.toString()]), style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Divider(),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final data = doc.data() as Map<String, dynamic>;
                            return ListTile(
                              leading: collection == 'shop_items' 
                                ? Text(data['emoji'] ?? '❓', style: const TextStyle(fontSize: 24))
                                : null,
                              title: Text(data['title'] ?? data['name'] ?? 'No Title'),
                              subtitle: Text(data['description'] ?? data['summary'] ?? '', maxLines: 1),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => doc.reference.delete(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (collection != 'carousel' || docs.length < 3)
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            if (collection == 'shop_items') {
                              _showAddShopItemDialog(context);
                            } else if (collection == 'carousel') {
                              _showAddCarouselDialog(context);
                            } else if (collection == 'blog') {
                              _showAddBlogDialog(context);
                            } else {
                              _showAddNewsDialog(context);
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: Text(tr('add_new_item')),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(tr('limit_reached'), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  );
                },
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(tr('close'))),
            ],
          );
        },
      ),
    );
  }

  void _showAddShopItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emojiController = TextEditingController();
    final costController = TextEditingController();
    int selectedRarity = 0;
    String selectedType = 'hat';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(tr('add_shop_item')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: tr('item_name'))),
                TextField(controller: emojiController, decoration: InputDecoration(labelText: tr('emoji_hint'))),
                TextField(controller: costController, decoration: InputDecoration(labelText: tr('cost_label')), keyboardType: TextInputType.number),
                DropdownButton<String>(
                  value: selectedType,
                  isExpanded: true,
                  items: ['hat', 'outfit', 'pet', 'mystery'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => selectedType = val!),
                ),
                DropdownButton<int>(
                  value: selectedRarity,
                  isExpanded: true,
                  items: [0, 1, 2, 3].map((e) => DropdownMenuItem(value: e, child: Text(Rarity.values[e].name))).toList(),
                  onChanged: (val) => setState(() => selectedRarity = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(tr('cancel'))),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('shop_items').add({
                  'name': nameController.text,
                  'emoji': emojiController.text,
                  'coinCost': int.tryParse(costController.text) ?? 100,
                  'type': selectedType,
                  'rarity': selectedRarity,
                });
                Navigator.pop(context);
              },
              child: Text(tr('add_btn')),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCarouselDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final imgController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('add_carousel_item')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: InputDecoration(labelText: tr('language'))), // Using generic 'language' for title for now if needed, or better use dedicated key
              TextField(controller: descController, decoration: InputDecoration(labelText: tr('description_label'))),
              TextField(controller: imgController, decoration: InputDecoration(labelText: tr('image_url_label'))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(tr('cancel'))),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('carousel').add({
                'title': titleController.text,
                'description': descController.text,
                'imageUrl': imgController.text,
                'link': 'details',
              });
              Navigator.pop(context);
            },
            child: Text(tr('add_btn')),
          ),
        ],
      ),
    );
  }

  void _showAddBlogDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final imgController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('add_blog_post')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: InputDecoration(labelText: tr('language'))),
              TextField(controller: contentController, decoration: InputDecoration(labelText: tr('full_content_label')), maxLines: 3),
              TextField(controller: imgController, decoration: InputDecoration(labelText: tr('image_url_label'))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(tr('cancel'))),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('blog').add({
                'title': titleController.text,
                'content': contentController.text,
                'imageUrl': imgController.text,
                'author': 'Admin',
                'date': Timestamp.now(),
              });
              Navigator.pop(context);
            },
            child: Text(tr('add_btn')),
          ),
        ],
      ),
    );
  }

  void _showAddNewsDialog(BuildContext context) {
    final titleController = TextEditingController();
    final summaryController = TextEditingController();
    final contentController = TextEditingController();
    final imgController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('add_news_item')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: InputDecoration(labelText: tr('language'))),
              TextField(controller: summaryController, decoration: InputDecoration(labelText: tr('summary_label'))),
              TextField(controller: contentController, decoration: InputDecoration(labelText: tr('full_content_label')), maxLines: 3),
              TextField(controller: imgController, decoration: InputDecoration(labelText: tr('image_url_label'))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(tr('cancel'))),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('news').add({
                'title': titleController.text,
                'summary': summaryController.text,
                'content': contentController.text,
                'imageUrl': imgController.text,
                'date': Timestamp.now(),
              });
              Navigator.pop(context);
            },
            child: Text(tr('add_btn')),
          ),
        ],
      ),
    );
  }
}
