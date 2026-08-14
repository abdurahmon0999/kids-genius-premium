import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/bouncy_button.dart';
import '../../core/services/kids_providers.dart';
import '../../core/services/voice_service.dart';
import 'package:lottie/lottie.dart';
import 'zombie_game_screen.dart';
import '../sky_rush/screens/sky_rush_home_screen.dart';
import '../turbo_kart/screens/turbo_kart_home_screen.dart';

class DrawingPoint {
  final Offset offset;
  final Paint paint;
  DrawingPoint(this.offset, this.paint);
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> points;
  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!.offset, points[i + 1]!.offset, points[i]!.paint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(ui.PointMode.points, [points[i]!.offset], points[i]!.paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

class MiniGamesScreen extends ConsumerStatefulWidget {
  const MiniGamesScreen({super.key});

  @override
  ConsumerState<MiniGamesScreen> createState() => _MiniGamesScreenState();
}

class _MiniGamesScreenState extends ConsumerState<MiniGamesScreen> {
  late ConfettiController _confettiController;
  int _activeCategoryIndex = 0; 
  int _score = 0;
  int _questionIndex = 0;
  String _difficulty = 'easy'; // 'easy', 'medium', 'hard'

  // Maze State
  int _mazeX = 0;
  int _mazeY = 0;
  int _mazeLevel = 0;

  // Drawing State
  List<DrawingPoint?> _drawingPoints = [];
  Color _selectedDrawingColor = Colors.white;
  String _selectedTemplate = '🚗'; // Default template for coloring book

  // Storyteller State
  int _selectedStoryIndex = 0;
  bool _isStoryPlaying = false;
  final List<Map<String, String>> _stories = [
    {
      'title': 'Jungle Adventure 🌴',
      'emoji': '🐘',
      'content': 'Once upon a time, a brave explorer named {NAME} entered the deep green jungle. Suddenly, a friendly elephant appeared and gave {NAME} a magic flower. Together, they found a hidden treasure chest filled with golden stars! The jungle animals cheered: Hurray for {NAME}!'
    },
    {
      'title': 'Space Hero 🚀',
      'emoji': '👨‍🚀',
      'content': 'Commander {NAME} jumped into a sparkling rocket ship. Destination: Mars! As the rocket landed, a group of tiny green aliens welcomed {NAME} with a cosmic dance. {NAME} showed them how to do a high-five, and they became the best friends in the whole galaxy.'
    },
    {
      'title': 'Magic Dragon 🐲',
      'emoji': '✨',
      'content': 'In a castle made of clouds, lived a dragon who loved to bake. One day, {NAME} visited the castle. The dragon was sad because he lost his magic spoon. {NAME} used great logic to find it under a rainbow. To say thank you, the dragon flew {NAME} all around the world!'
    },
  ];

  final List<List<String>> _mazeLevels = [
    [
      'S.W..',
      '..W.G',
      '.W.W.',
      '.....',
      'W.W.W',
    ],
    [
      'S....',
      'WWWW.',
      '....G',
      '.WWWW',
      '.....',
    ],
    [
      'S.W...',
      '..W.W.',
      'W...W.',
      '.W.W.G',
      '......',
    ]
  ];

  // Question Data Store
  final Map<String, List<Map<String, dynamic>>> _allGameData = {
    'math': [
      {'q': '5 + 3 = ?', 'options': [7, 8, 9, 10], 'ans': 8},
      {'q': '12 - 4 = ?', 'options': [6, 7, 8, 9], 'ans': 8},
      {'q': '4 × 3 = ?', 'options': [10, 12, 14, 16], 'ans': 12},
      {'q': '15 ÷ 3 = ?', 'options': [3, 4, 5, 6], 'ans': 5},
    ],
    'animal_quiz': [
      {'q': '🐘', 'options': ['Lion', 'Elephant', 'Monkey', 'Cat'], 'ans': 'Elephant'},
      {'q': '🦁', 'options': ['Tiger', 'Dog', 'Lion', 'Bear'], 'ans': 'Lion'},
      {'q': '🐒', 'options': ['Monkey', 'Snake', 'Bird', 'Fox'], 'ans': 'Monkey'},
      {'q': '🐱', 'options': ['Rabbit', 'Cat', 'Mouse', 'Cow'], 'ans': 'Cat'},
    ],
    'word_builder': [
      {'q': 'A _ _ L E', 'options': ['P P', 'B B', 'T T', 'M M'], 'ans': 'P P', 'full': 'APPLE'},
      {'q': 'B _ N _ N A', 'options': ['A A', 'E E', 'I I', 'O O'], 'ans': 'A A', 'full': 'BANANA'},
      {'q': 'C _ T', 'options': ['A', 'E', 'I', 'O'], 'ans': 'A', 'full': 'CAT'},
      {'q': 'D _ G', 'options': ['O', 'A', 'U', 'I'], 'ans': 'O', 'full': 'DOG'},
      {'q': 'F _ S H', 'options': ['I', 'O', 'A', 'E'], 'ans': 'I', 'full': 'FISH'},
      {'q': 'S _ N', 'options': ['U', 'O', 'A', 'E'], 'ans': 'U', 'full': 'SUN'},
      {'q': 'M _ _ N', 'options': ['O O', 'E E', 'A A', 'U U'], 'ans': 'O O', 'full': 'MOON'},
      {'q': 'B _ _ K', 'options': ['O O', 'A A', 'I I', 'E E'], 'ans': 'O O', 'full': 'BOOK'},
    ],
    'memory': [
      {'q': 'Which one matches: 🍎', 'options': ['🍎', '🍐', '🍊', '🍋'], 'ans': '🍎'},
      {'q': 'Find the pair: 🐱', 'options': ['🐶', '🐱', '🐭', '🐹'], 'ans': '🐱'},
      {'q': 'What was next? 🔵 🔴 _', 'options': ['🔵', '🔴', '🟡', '🟢'], 'ans': '🔵'},
      {'q': 'Remember: ⭐️ 🌙', 'options': ['🌙 ⭐️', '⭐️ 🌙', '☁️ ☀️', '⭐️ ☁️'], 'ans': '⭐️ 🌙'},
    ],
    'alphabet': [
      {'q': 'Which is "B"?', 'options': ['A', 'B', 'C', 'D'], 'ans': 'B'},
      {'q': 'What comes after D?', 'options': ['C', 'E', 'F', 'G'], 'ans': 'E'},
      {'q': 'Capital of "a"?', 'options': ['A', 'B', 'Q', 'E'], 'ans': 'A'},
      {'q': 'Find the vowel:', 'options': ['B', 'Z', 'E', 'M'], 'ans': 'E'},
    ],
    'coding': [
      {'q': 'If 🍏=1, then 🍏+🍏=?', 'options': [1, 2, 3, 4], 'ans': 2},
      {'q': 'Repeat 3 times: ⭐️', 'options': ['⭐️', '⭐️⭐️', '⭐️⭐️⭐️', '✨'], 'ans': '⭐️⭐️⭐️'},
      {'q': 'Move ➡️ then ⬆️', 'options': ['➡️⬆️', '⬆️➡️', '⬅️⬇️', '↘️'], 'ans': '➡️⬆️'},
      {'q': 'Next in 1, 0, 1, 0, _', 'options': [0, 1, 2, 5], 'ans': 1},
      {'q': 'Command to Start?', 'options': ['Run', 'Stop', 'Wait', 'End'], 'ans': 'Run'},
      {'q': 'Which is a Loop?', 'options': ['🔄', '➡️', '⏹', '⚠️'], 'ans': '🔄'},
      {'q': 'Bug means...', 'options': ['Error', 'Feature', 'Win', 'Fast'], 'ans': 'Error'},
      {'q': 'Fixing code is:', 'options': ['Debugging', 'Playing', 'Eating', 'Sleeping'], 'ans': 'Debugging'},
    ],
    'science': [
      {'q': 'The Red Planet?', 'options': ['Mars', 'Venus', 'Earth', 'Moon'], 'ans': 'Mars'},
      {'q': 'Which is the Sun?', 'options': ['☀️', '🌕', '🌎', '🌑'], 'ans': '☀️'},
      {'q': 'We live on...', 'options': ['Saturn', 'Jupiter', 'Earth', 'Pluto'], 'ans': 'Earth'},
      {'q': 'Night light?', 'options': ['Star', 'Cloud', 'Moon', 'Plane'], 'ans': 'Moon'},
      {'q': 'Largest Planet?', 'options': ['Jupiter', 'Mars', 'Earth', 'Mercury'], 'ans': 'Jupiter'},
      {'q': 'Has Rings?', 'options': ['Saturn', 'Mars', 'Venus', 'Earth'], 'ans': 'Saturn'},
      {'q': 'Twinkle stars are:', 'options': ['Suns', 'Rocks', 'Planes', 'Birds'], 'ans': 'Suns'},
      {'q': 'Rocket goes to...', 'options': ['Space', 'Ocean', 'Forest', 'City'], 'ans': 'Space'},
    ],
    'maze': [
      {'q': 'Go to the 🏁', 'options': ['⬅️', '⬆️', '➡️', '⬇️'], 'ans': '➡️'},
      {'q': 'Avoid the 💣', 'options': ['Jump', 'Run', 'Stop', 'Wait'], 'ans': 'Jump'},
      {'q': 'Collect the 💎', 'options': ['💎', '🧱', '🔥', '💧'], 'ans': '💎'},
      {'q': 'Open the 🚪', 'options': ['🔑', '📦', '🧹', '🔔'], 'ans': '🔑'},
      {'q': 'Shortcut?', 'options': ['Teleport', 'Walk', 'Crawl', 'Sit'], 'ans': 'Teleport'},
      {'q': 'Follow the 🐾', 'options': ['Tracks', 'Walls', 'Water', 'Fire'], 'ans': 'Tracks'},
      {'q': 'Bridge over 🌊', 'options': ['Walk', 'Swim', 'Fly', 'Drive'], 'ans': 'Walk'},
      {'q': 'Dark room needs:', 'options': ['🔦', '🥣', '🧸', '📻'], 'ans': '🔦'},
    ],
    'music': [
      {'q': 'Identify: 🎸', 'options': ['Piano', 'Guitar', 'Drum', 'Violin'], 'ans': 'Guitar'},
      {'q': 'Which is a Piano?', 'options': ['🎺', '🎷', '🎹', '🎻'], 'ans': '🎹'},
      {'q': 'Makes a LOUD sound?', 'options': ['🥁', '🪕', '🎻', '🎹'], 'ans': '🥁'},
      {'q': 'Singing emoji?', 'options': ['🎤', '🎧', '📻', '🎸'], 'ans': '🎤'},
      {'q': 'Trumpet shape?', 'options': ['🎺', '🎻', '🎹', '🎸'], 'ans': '🎺'},
      {'q': 'Violin Bow?', 'options': ['🎻', '🎸', '🥁', '🎷'], 'ans': '🎻'},
      {'q': 'Rockstar gear?', 'options': ['🎸⚡️', '🎹🌸', '🎻🎻', '🎺☁️'], 'ans': '🎸⚡️'},
      {'q': 'Headphones for?', 'options': ['Listening', 'Seeing', 'Eating', 'Running'], 'ans': 'Listening'},
    ],
    'shape_match': [
      {'q': 'Square?', 'options': ['🔺', '🟡', '⬛', '💎'], 'ans': '⬛'},
      {'q': 'Triangle has _ sides', 'options': [2, 3, 4, 5], 'ans': 3},
      {'q': 'Round like a ball?', 'options': ['🟡', '⬛', '➖', '✖️'], 'ans': '🟡'},
      {'q': 'Three sides:', 'options': ['Square', 'Circle', 'Triangle', 'Star'], 'ans': 'Triangle'},
    ],
    'drawing': [
      {'q': 'What color is 🍎?', 'options': ['Red', 'Blue', 'Green', 'Yellow'], 'ans': 'Red'},
      {'q': 'Which is a Brush?', 'options': ['✏️', '🖌️', '📏', '✂️'], 'ans': '🖌️'},
      {'q': 'Mix Yellow + Blue?', 'options': ['Red', 'Green', 'Purple', 'Orange'], 'ans': 'Green'},
      {'q': 'Artist tool?', 'options': ['🎨', '⚒️', '🧪', '🔭'], 'ans': '🎨'},
    ],
    'spot_diff': [
      {'q': 'Which is different: 🍎🍎🍐🍎', 'options': ['🍎', '🍐', '🍏', '🍓'], 'ans': '🍐'},
      {'q': 'Odd one out: 🐶🐱🐹🚗', 'options': ['🐶', '🐱', '🚗', '🐹'], 'ans': '🚗'},
      {'q': 'Find the fake: ⚽️⚽️🏀⚽️', 'options': ['⚽️', '🏀', '🏈', '🎾'], 'ans': '🏀'},
      {'q': 'One is NOT a fruit:', 'options': ['🍌', '🍒', '🥦', '🍇'], 'ans': '🥦'},
    ],
    'puzzle': [
      {'q': '🔴 🔵 🔴 _', 'options': ['🔵', '🔴', '🟡', '🟢'], 'ans': '🔵'},
      {'q': '🐱 🐶 🐱 _', 'options': ['🐱', '🐶', '🐭', '🐹'], 'ans': '🐶'},
      {'q': '1️⃣ 2️⃣ 1_ 2️⃣', 'options': ['2️⃣', '1️⃣', '3️⃣', '4️⃣'], 'ans': '1️⃣'},
      {'q': '⭐️ 🌙 ⭐️ _', 'options': ['🌙', '⭐️', '☀️', '☁️'], 'ans': '🌙'},
    ],
    'color_splash': [
      {'q': 'Red + Yellow = ?', 'options': ['Orange', 'Green', 'Purple', 'Pink'], 'ans': 'Orange'},
      {'q': 'Blue + Red = ?', 'options': ['Purple', 'Green', 'Orange', 'Yellow'], 'ans': 'Purple'},
      {'q': 'Yellow + Blue = ?', 'options': ['Green', 'Orange', 'Red', 'Pink'], 'ans': 'Green'},
      {'q': 'Which is a "Cold" color?', 'options': ['Blue', 'Red', 'Orange', 'Yellow'], 'ans': 'Blue'},
    ],
  };

  List<Map<String, dynamic>> _getCurrentQuestions(String key) {
    return _allGameData[key] ?? _allGameData['math']!;
  }

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    
    // Sync with the selected game from the map
    _activeCategoryIndex = ref.read(selectedGameIndexProvider);
    
    // Speak first question after a small delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentQuestion();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onAnswerSelected(dynamic selected, String categoryKey) {
    final questions = _getCurrentQuestions(categoryKey);
    final currentQ = questions[_questionIndex];
    bool isCorrect = selected == currentQ['ans'];

    if (isCorrect) {
      int multiplier = _difficulty == 'hard' ? 3 : (_difficulty == 'medium' ? 2 : 1);
      int coinsAward = 15 * multiplier;
      int xpAward = 25 * multiplier;

      _score += 10 * multiplier;
      ref.read(userProfileProvider.notifier).addCoins(coinsAward);
      ref.read(userProfileProvider.notifier).addXp(xpAward);
      ref.read(questProvider.notifier).updateProgress(categoryKey); // Update Quests
      
      HapticFeedback.lightImpact(); // Sensory Feedback
      _confettiController.play();
      VoiceService.speakSuccess();

      // Show Premium Lottie Celebration
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black45,
        builder: (context) {
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted && Navigator.canPop(context)) Navigator.pop(context);
          });
          return Center(
            child: Lottie.network(
              'https://assets9.lottiefiles.com/packages/lf20_mye7pyj5.json',
              width: 300,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.star, size: 100, color: Colors.yellow);
              },
            ),
          );
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Barakalla! ${categoryKey == 'word_builder' ? "Javob: ${currentQ['full']}!" : "+$coinsAward Tanga & +$xpAward XP!"}'),
          backgroundColor: AppColors.success,
          duration: const Duration(milliseconds: 1000),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      HapticFeedback.heavyImpact(); // Sensory Feedback for errors
      VoiceService.speakError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Oops! Yana bir bor urinib ko\'r! 💪'),
          backgroundColor: AppColors.danger,
          duration: const Duration(milliseconds: 1000),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() {
      _questionIndex = (_questionIndex + 1) % questions.length;
      _speakCurrentQuestion();
    });
  }

  void _speakCurrentQuestion() {
    final categories = ref.read(gameCategoriesProvider);
    final currentCategory = categories[_activeCategoryIndex.clamp(0, categories.length - 1)];
    final questions = _getCurrentQuestions(currentCategory.categoryKey);
    final currentQ = questions[_questionIndex];
    
    String textToSpeak = currentQ['q'];
    // Clean up emojis for better speech if needed, but TTS usually handles them or ignores them.
    VoiceService.speak(textToSpeak);
  }

  void _switchGame(int index) {
    final categories = ref.read(gameCategoriesProvider);
    final currentCategory = categories[index.clamp(0, categories.length - 1)];

    if (currentCategory.categoryKey == 'zombie_survival') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ZombieGameScreen()),
      );
      return;
    }

    if (currentCategory.categoryKey == 'sky_rush') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SkyRushHomeScreen()),
      );
      return;
    }

    if (currentCategory.categoryKey == 'turbo_kart') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TurboKartHomeScreen()),
      );
      return;
    }

    setState(() {
      _activeCategoryIndex = index;
      _questionIndex = 0;
      
      if (currentCategory.categoryKey == 'maze') {
        _resetMaze();
        VoiceService.speak(tr('maze_start_msg'));
      } else {
        _speakCurrentQuestion();
      }
    });
  }

  void _resetMaze() {
    _mazeX = 0;
    _mazeY = 0;
  }

  void _moveMaze(int dx, int dy) {
    final level = _mazeLevels[_mazeLevel % _mazeLevels.length];
    int newX = (_mazeX + dx).clamp(0, level[0].length - 1);
    int newY = (_mazeY + dy).clamp(0, level.length - 1);

    if (level[newY][newX] != 'W') {
      setState(() {
        _mazeX = newX;
        _mazeY = newY;
      });

      if (level[newY][newX] == 'G') {
        _score += 50;
        ref.read(userProfileProvider.notifier).addCoins(30);
        ref.read(userProfileProvider.notifier).addXp(50);
        _confettiController.play();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tr('goal_reached')), 
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _mazeLevel++;
              _resetMaze();
            });
          }
        });
      }
    }
  }

  Widget _buildMazeGame(Color themeColor) {
    final level = _mazeLevels[_mazeLevel % _mazeLevels.length];
    return Column(
      children: [
        Text(tr('level_text', args: [(_mazeLevel + 1).toString()]), style: AppTypography.subtitle1(color: Colors.white)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(level.length, (y) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(level[y].length, (x) {
                  String cell = level[y][x];
                  Widget content;
                  if (x == _mazeX && y == _mazeY) {
                    content = const Text('🐱', style: TextStyle(fontSize: 24));
                  } else if (cell == 'W') {
                    content = const Text('🧱', style: TextStyle(fontSize: 24));
                  } else if (cell == 'G') {
                    content = const Text('🏁', style: TextStyle(fontSize: 24));
                  } else {
                    content = const SizedBox(width: 24, height: 24);
                  }
                  return Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white12),
                    ),
                    child: content,
                  );
                }),
              );
            }),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMazeControl(Icons.keyboard_arrow_up, () => _moveMaze(0, -1)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMazeControl(Icons.keyboard_arrow_left, () => _moveMaze(-1, 0)),
            const SizedBox(width: 40),
            _buildMazeControl(Icons.keyboard_arrow_right, () => _moveMaze(1, 0)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMazeControl(Icons.keyboard_arrow_down, () => _moveMaze(0, 1)),
          ],
        ),
      ],
    );
  }

  Widget _buildMazeControl(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white24,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildDrawingGame(Color themeColor, {bool isColoringMode = false}) {
    return Column(
      children: [
        Text(isColoringMode ? tr('coloring_book_title') : tr('magic_canvas'), 
            style: AppTypography.subtitle1(color: Colors.white)),
        const SizedBox(height: 16),
        
        if (isColoringMode) ...[
          // Template Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['🚗', '🏠', '🌟', '🐘', '🚀', '🍰', '🦖', '🎈'].map((t) {
                bool isSel = _selectedTemplate == t;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedTemplate = t;
                    _drawingPoints.clear();
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSel ? Colors.white24 : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(t, style: const TextStyle(fontSize: 32)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Canvas Area
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Stack(
            children: [
              if (isColoringMode)
                Center(
                  child: Opacity(
                    opacity: 0.2,
                    child: Text(_selectedTemplate, style: const TextStyle(fontSize: 180)),
                  ),
                ),
              GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    RenderBox renderBox = context.findRenderObject() as RenderBox;
                    _drawingPoints.add(DrawingPoint(
                      renderBox.globalToLocal(details.globalPosition) - Offset(40, isColoringMode ? 320 : 240), 
                      Paint()
                        ..color = _selectedDrawingColor
                        ..strokeCap = ui.StrokeCap.round
                        ..strokeWidth = 8.0,
                    ));
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    _drawingPoints.add(null);
                  });
                },
                child: CustomPaint(
                  size: Size.infinite,
                  painter: DrawingPainter(_drawingPoints),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Tools & Colors
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildColorOption(Colors.white),
            _buildColorOption(const Color(0xFFEC4899)), // Pink
            _buildColorOption(const Color(0xFF3B82F6)), // Blue
            _buildColorOption(const Color(0xFFFFB703)), // Yellow
            _buildColorOption(const Color(0xFF10B981)), // Green
            _buildColorOption(const Color(0xFFF43F5E)), // Red
            IconButton(
              icon: const Icon(CupertinoIcons.trash_fill, color: Colors.white70),
              onPressed: () => setState(() => _drawingPoints.clear()),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        BouncyButton(
          text: isColoringMode ? tr('finished_coloring') : tr('finished_drawing'),
          onTap: () {
            _score += 50;
            ref.read(userProfileProvider.notifier).addCoins(25);
            ref.read(userProfileProvider.notifier).addXp(45);
            _confettiController.play();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isColoringMode ? tr('great_job_coloring') : tr('beautiful_art')),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStorytellerGame(Color themeColor) {
    final user = ref.read(userProfileProvider);
    final story = _stories[_selectedStoryIndex];
    final personalizedContent = story['content']!.replaceAll('{NAME}', user.name);

    return Column(
      children: [
        Text(tr('storyteller_title'), style: AppTypography.heading3(color: Colors.white)),
        const SizedBox(height: 16),

        // Story Theme Selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_stories.length, (index) {
              bool isSel = _selectedStoryIndex == index;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedStoryIndex = index;
                  _isStoryPlaying = false;
                  VoiceService.stop();
                }),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSel ? Colors.white24 : Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSel ? Colors.white : Colors.transparent),
                  ),
                  child: Row(
                    children: [
                      Text(_stories[index]['emoji']!, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(_stories[index]['title']!, style: AppTypography.caption(color: Colors.white)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 20),

        // Story Display Console
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                story['emoji']!,
                style: const TextStyle(fontSize: 60),
              ).animate(key: ValueKey('story_emoji_$_selectedStoryIndex')).scale(),
              const SizedBox(height: 16),
              Text(
                personalizedContent,
                textAlign: TextAlign.center,
                style: AppTypography.subtitle1(color: Colors.white),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlBtn(
                    icon: _isStoryPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    color: AppColors.accent,
                    onTap: () {
                      if (_isStoryPlaying) {
                        VoiceService.stop();
                      } else {
                        VoiceService.speak(personalizedContent);
                      }
                      setState(() => _isStoryPlaying = !_isStoryPlaying);
                    },
                  ),
                  const SizedBox(width: 20),
                  _buildControlBtn(
                    icon: Icons.stop_circle_rounded,
                    color: Colors.white30,
                    onTap: () {
                      VoiceService.stop();
                      setState(() => _isStoryPlaying = false);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        BouncyButton(
          text: tr('finished_listening'),
          onTap: () {
            VoiceService.stop();
            _score += 30;
            ref.read(userProfileProvider.notifier).addCoins(10);
            ref.read(userProfileProvider.notifier).addXp(30);
            ref.read(questProvider.notifier).updateProgress('storyteller'); // Update Quest
            _confettiController.play();
          },
        ),
      ],
    );
  }

  Widget _buildControlBtn({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: color, size: 64),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final categories = ref.watch(gameCategoriesProvider);
    final currentCategory = categories[_activeCategoryIndex.clamp(0, categories.length - 1)];
    final questions = _getCurrentQuestions(currentCategory.categoryKey);
    final currentQ = questions[_questionIndex];

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(tr('arcade_title'),
                style: AppTypography.heading2(
                    color: isDark ? Colors.white : AppColors.primary)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Difficulty Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDifficultyBtn('easy', tr('easy')),
                    const SizedBox(width: 8),
                    _buildDifficultyBtn('medium', tr('med')),
                    const SizedBox(width: 8),
                    _buildDifficultyBtn('hard', tr('hard')),
                  ],
                ),
                const SizedBox(height: 16),

                // Game Selector Tabs (Scrollable)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(categories.length, (index) {
                      final cat = categories[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildGameTab(index, '${cat.iconEmoji} ${tr(cat.categoryKey)}', cat.themeColor),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),

                // Play Area Card
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  customGradient: LinearGradient(
                    colors: [
                      currentCategory.themeColor,
                      currentCategory.themeColor.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: currentCategory.categoryKey == 'maze' 
                    ? _buildMazeGame(currentCategory.themeColor)
                    : currentCategory.categoryKey == 'drawing'
                      ? _buildDrawingGame(currentCategory.themeColor)
                      : currentCategory.categoryKey == 'coloring_book'
                        ? _buildDrawingGame(currentCategory.themeColor, isColoringMode: true)
                        : currentCategory.categoryKey == 'storyteller'
                          ? _buildStorytellerGame(currentCategory.themeColor)
                          : Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  tr('score_text', args: [_score.toString()]),
                                  style: AppTypography.bodyBold(color: Colors.white),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  tr('question_text', args: [(_questionIndex + 1).toString(), questions.length.toString()]),
                                  style: AppTypography.bodyBold(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(CupertinoIcons.volume_up, color: Colors.white70, size: 28),
                              onPressed: _speakCurrentQuestion,
                            ),
                          ),
                          const SizedBox(height: 8),

                          if (currentCategory.categoryKey == 'animal_quiz') 
                            Text(
                              currentQ['q'],
                              style: const TextStyle(fontSize: 80),
                            ).animate().shake(duration: 500.ms)
                          else
                            Text(
                              currentQ['q'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: currentCategory.categoryKey == 'word_builder' ? 42 : 36,
                                letterSpacing: currentCategory.categoryKey == 'word_builder' ? 4 : 0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ).animate(key: ValueKey('q_${currentCategory.categoryKey}_$_questionIndex')).scale(duration: 400.ms),

                          const SizedBox(height: 32),

                          // Options Grid
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 2.2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            children: (currentQ['options'] as List).map((opt) {
                              return BouncyButton(
                                text: '$opt',
                                gradientStart: Colors.white,
                                gradientEnd: Colors.white.withValues(alpha: 0.9),
                                textColor: currentCategory.themeColor,
                                onTap: () => _onAnswerSelected(opt, currentCategory.categoryKey),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                ),
              ],
            ),
          ),
        ),

        // Confetti Celebration Overlay
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppColors.primary,
              AppColors.secondary,
              AppColors.accent,
              AppColors.success,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyBtn(String level, String label) {
    bool isSel = _difficulty == level;
    return GestureDetector(
      onTap: () => setState(() => _difficulty = level),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSel ? AppColors.primary : Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSel ? Colors.white : Colors.white24),
        ),
        child: Text(label, style: TextStyle(color: isSel ? Colors.white : Colors.grey, fontSize: 12)),
      ),
    );
  }

  Widget _buildGameTab(int index, String label, Color color) {
    final isSelected = _activeCategoryIndex == index;
    return GestureDetector(
      onTap: () => _switchGame(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.caption(
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color) {
    bool isSelected = _selectedDrawingColor == color;
    return GestureDetector(
      onTap: () => setState(() => _selectedDrawingColor = color),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)] : [],
        ),
      ),
    );
  }
}
