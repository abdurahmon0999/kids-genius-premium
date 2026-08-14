import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum PasswordStrength { easy, medium, hard, none }

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  PasswordStrength get _strength {
    if (password.isEmpty) return PasswordStrength.none;
    if (password.length < 6) return PasswordStrength.easy;
    
    bool hasLetters = password.contains(RegExp(r'[a-zA-Z]'));
    bool hasNumbers = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (password.length >= 8 && hasLetters && hasNumbers && hasSpecial) {
      return PasswordStrength.hard;
    }
    if (password.length >= 6 && hasLetters && hasNumbers) {
      return PasswordStrength.medium;
    }
    return PasswordStrength.easy;
  }

  Color _getColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.easy:
        return Colors.redAccent;
      case PasswordStrength.medium:
        return Colors.orangeAccent;
      case PasswordStrength.hard:
        return AppColors.success;
      case PasswordStrength.none:
        return Colors.grey.withOpacity(0.3);
    }
  }

  String _getText(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.easy:
        return 'Oson (Kuchsiz)';
      case PasswordStrength.medium:
        return "O'rta";
      case PasswordStrength.hard:
        return 'Qiyin (Kuchli)';
      case PasswordStrength.none:
        return '';
    }
  }

  double _getPercent(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.easy:
        return 0.33;
      case PasswordStrength.medium:
        return 0.66;
      case PasswordStrength.hard:
        return 1.0;
      case PasswordStrength.none:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strength = _strength;
    if (strength == PasswordStrength.none) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: _getPercent(strength),
                backgroundColor: Colors.grey.withOpacity(0.2),
                color: _getColor(strength),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _getText(strength),
              style: TextStyle(
                color: _getColor(strength),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
