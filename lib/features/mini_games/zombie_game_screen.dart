import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'zombie_game_widget.dart';

class ZombieGameScreen extends ConsumerWidget {
  const ZombieGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // We use a WillPopScope-like behavior or just a Quit button in the widget
      body: ZombieGameWidget(
        onQuit: () => Navigator.pop(context),
      ),
    );
  }
}
