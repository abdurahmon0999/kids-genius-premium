import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/bouncy_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/services/kids_providers.dart';

class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('error_empty_message')), backgroundColor: AppColors.danger),
      );
      return;
    }

    setState(() => _isSending = true);

    final user = ref.read(userProfileProvider);

    try {
      await FirebaseFirestore.instance.collection('support_messages').add({
        'userId': user.uid,
        'userName': user.name,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _messageController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('message_sent_success')), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error sending message'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(tr('contact'), style: AppTypography.heading2(color: isDark ? Colors.white : AppColors.primary)),
            const SizedBox(height: 12),
            Text(tr('need_help_contact'), textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
            const SizedBox(height: 32),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.email, color: AppColors.primary),
                    title: Text('support@kidsgenius.academy'),
                  ),
                  const ListTile(
                    leading: Icon(Icons.phone, color: AppColors.secondary),
                    title: Text('+998 90 440 18 23'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Message Input
            Text(tr('write_message_title'), style: AppTypography.heading3(color: isDark ? Colors.white : AppColors.primary)),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _messageController,
                    maxLines: 4,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: tr('message_hint'),
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isSending)
                    const CircularProgressIndicator()
                  else
                    BouncyButton(
                      text: tr('send_message'),
                      onTap: _sendMessage,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
