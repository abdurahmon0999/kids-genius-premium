import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/models/kids_models.dart';
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
  bool _isUploading = false;

  Future<void> _pickAndUploadImage(StateSetter setModalState) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      
      if (image != null) {
        setModalState(() => _isUploading = true);
        final user = ref.read(userProfileProvider);
        
        print("Image selected: ${image.path}");
        
        final dynamic uploadData = kIsWeb ? await image.readAsBytes() : File(image.path);

        final String? downloadUrl = await StorageService.uploadProfileImage(
          uploadData, 
          user.uid
        ).timeout(const Duration(seconds: 30));

        if (downloadUrl != null) {
          ref.read(userProfileProvider.notifier).updateProfile(profilePic: downloadUrl);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(tr('image_saved')), backgroundColor: AppColors.success),
            );
          }
        } else {
          throw Exception("Upload failed - URL is null");
        }
      }
    } on TimeoutException catch (e) {
      print("Upload timeout: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('upload_timeout')), backgroundColor: AppColors.danger),
        );
      }
    } catch (e) {
      print("Upload error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('error_upload')), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setModalState(() => _isUploading = false);
    }
  }

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
                  Text(tr('choose_avatar'), 
                    textAlign: TextAlign.center,
                    style: AppTypography.heading3()),
                  const SizedBox(height: 16),
                  
                  // New Upload Button
                  if (_isUploading)
                    Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 8),
                        Text(tr('uploading'), style: AppTypography.caption(color: Colors.white70)),
                      ],
                    )
                  else
                    BouncyButton(
                      text: tr('upload_image'),
                      gradientStart: AppColors.secondary,
                      onTap: () => _pickAndUploadImage(setModalState),
                    ),
                    
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
                      labelText: tr('hero_name'),
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      prefixIcon: const Icon(CupertinoIcons.sparkles, color: AppColors.accent),
                    ),
                  ),
                  const SizedBox(height: 24),
                  BouncyButton(
                    text: tr('save_changes'),
                    onTap: () {
                      ref.read(userProfileProvider.notifier).updateProfile(
                        name: nameController.text,
                        profilePic: selectedAvatar,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(tr('profile_saved')), behavior: SnackBarBehavior.floating),
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
        title: Text(tr('hero_profile'), style: AppTypography.heading2(color: isDark ? Colors.white : AppColors.primary)),
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
                      color: Colors.white.withValues(alpha: 0.25),
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
                    child: Text(tr('premium_pass'), style: AppTypography.caption(color: Colors.black)),
                  ),
                  const SizedBox(height: 20),
                  
                  // Role Switcher for Testing/Admin Access
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildRoleMiniTile(UserRole.kid, tr('kid'), ref, user.role),
                      const SizedBox(width: 8),
                      _buildRoleMiniTile(UserRole.parent, tr('parent'), ref, user.role),
                      const SizedBox(width: 8),
                      _buildRoleMiniTile(UserRole.admin, tr('admin'), ref, user.role),
                    ],
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
                  _buildStatPill(tr('coins_text'), '${user.coins}', AppColors.accent),
                  _buildStatPill(tr('total_xp'), '${user.xp}', AppColors.success),
                  _buildStatPill(
                    tr('level'),
                    '${user.level}',
                    AppColors.primary,
                  ),
                  _buildStatPill(
                    tr('pet_text'),
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
                    text: tr('switch_account'),
                    gradientStart: AppColors.primary,
                    gradientEnd: AppColors.secondary,
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await FirebaseAuth.instance.signOut();
                      messenger.showSnackBar(
                        SnackBar(content: Text(tr('switching_account_msg'))),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  BouncyButton(
                    text: tr('logout_exit'),
                    gradientStart: AppColors.danger,
                    gradientEnd: Colors.redAccent,
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await FirebaseAuth.instance.signOut();
                      messenger.showSnackBar(
                        SnackBar(content: Text(tr('logged_out_msg'))),
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

  Widget _buildRoleMiniTile(UserRole role, String label, WidgetRef ref, UserRole currentRole) {
    final isSelected = role == currentRole;
    return GestureDetector(
      onTap: () {
        if (role == UserRole.admin && currentRole != UserRole.admin) {
          _showAdminKeyDialog(ref);
        } else if (role != currentRole) {
          ref.read(userProfileProvider.notifier).toggleRole(role);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Role changed to $label'), duration: const Duration(seconds: 1)),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white12,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label.split(' ')[0], // Get only emoji/first part
          style: TextStyle(fontSize: 18, color: isSelected ? AppColors.primary : Colors.white60),
        ),
      ),
    );
  }

  void _showAdminKeyDialog(WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('admin_key_required')),
        content: TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: tr('enter_admin_key')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(tr('cancel'))),
          TextButton(
            onPressed: () {
              if (controller.text == "7777") {
                ref.read(userProfileProvider.notifier).toggleRole(UserRole.admin);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Admin access granted! 👑'), backgroundColor: AppColors.success),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(tr('invalid_admin_key')), backgroundColor: AppColors.danger),
                );
              }
            }, 
            child: Text(tr('save'))
          ),
        ],
      ),
    );
  }
}
