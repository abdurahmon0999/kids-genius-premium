import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/bouncy_button.dart';
import '../../core/services/kids_providers.dart';
import '../../core/services/storage_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  void _showEditProfile() {
    final user = ref.read(userProfileProvider);
    final nameController = TextEditingController(text: user.name);
    String selectedAvatar = user.profilePic.length <= 2 ? user.profilePic : '🦁';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => GlassCard(
          padding: const EdgeInsets.all(24),
          borderRadius: 32,
          child: SingleChildScrollView( // Added scroll to avoid overflow
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Choose Your Hero Avatar:', 
                    textAlign: TextAlign.center,
                    style: AppTypography.heading3()),
                  const SizedBox(height: 20),
                  
                  // Expanded Premium Avatar Grid
                  SizedBox(
                    height: 250, // More space for more avatars
                    child: GridView.count(
                      crossAxisCount: 5,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: [
                        '🦁', '🐯', '🐼', '🦊', '🦄', '🐲', '🧑‍🚀', '🦸‍♂️', '🧙‍♂️', '🧜‍♀️', 
                        '🤖', '👾', '🐻', '🐰', '🐭', '🐱', '🐶', '🐷', '🐸', '🐹',
                        '🐵', '🐨', '🦖', '🐝', '🐞', '🦋', '🐳', '🐬', '🐙', '⭐️'
                      ].map((e) {
                        bool isSel = selectedAvatar == e;
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedAvatar = e),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.primary : Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: isSel ? AppColors.accent : Colors.white24, width: 2),
                              boxShadow: isSel ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 10)] : [],
                            ),
                            alignment: Alignment.center,
                            child: Text(e, style: const TextStyle(fontSize: 28)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Hero Name',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      prefixIcon: const Icon(CupertinoIcons.sparkles, color: AppColors.accent),
                    ),
                  ),
                  const SizedBox(height: 24),
                  BouncyButton(
                    text: 'Save Changes ✨',
                    onTap: () {
                      ref.read(userProfileProvider.notifier).updateProfile(
                        name: nameController.text,
                        profilePic: selectedAvatar,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile Saved! 💾'), behavior: SnackBarBehavior.floating),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    final pet = ref.watch(petProvider);
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Hero Profile 👤', style: AppTypography.heading2(color: isDark ? Colors.white : AppColors.primary)),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.pencil_circle_fill, size: 32, color: AppColors.primary),
            onPressed: _showEditProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Avatar Banner
            GlassCard(
              padding: const EdgeInsets.all(24),
              customGradient: AppColors.heroGradient,
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.25),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: user.profilePic.startsWith('http') 
                          ? ClipOval(
                              child: Image.network(
                                user.profilePic, 
                                width: 100, 
                                height: 100, 
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 50, color: Colors.white),
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const CircularProgressIndicator(color: Colors.white24);
                                },
                              ),
                            )
                          : Text(
                              '${user.activeAvatarHat}\n${user.profilePic}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 34),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(user.name, style: AppTypography.heading2(color: Colors.white)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(12)),
                    child: Text('PREMIUM HERO PASS Active ⭐', style: AppTypography.caption(color: Colors.black)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Hero Stats Summary Card
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatPill('Coins 🪙', '${user.coins}', AppColors.accent),
                  _buildStatPill('Total XP ⚡', '${user.xp}', AppColors.success),
                  _buildStatPill(
                    'Level 🌟',
                    '${user.level}',
                    AppColors.primary,
                  ),
                  _buildStatPill(
                    'Pet 🐲',
                    pet.name.split(' ')[0],
                    AppColors.purpleMagic,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout & Session Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  BouncyButton(
                    text: 'Switch Account 🔄',
                    gradientStart: AppColors.primary,
                    gradientEnd: AppColors.secondary,
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Switching account... Please restart.')),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  BouncyButton(
                    text: 'Logout & Exit 🚪',
                    gradientStart: AppColors.danger,
                    gradientEnd: Colors.redAccent,
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logged out!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(String title, String val, Color color) {
    return Column(
      children: [
        Text(val, style: AppTypography.heading3(color: color)),
        const SizedBox(height: 2),
        Text(title, style: AppTypography.caption(color: Colors.grey)),
      ],
    );
  }
}
