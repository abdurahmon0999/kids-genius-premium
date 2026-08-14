import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/bouncy_button.dart';
import '../../../core/services/kids_providers.dart';

class TurboKartRaceScreen extends ConsumerStatefulWidget {
  const TurboKartRaceScreen({super.key});

  @override
  ConsumerState<TurboKartRaceScreen> createState() => _TurboKartRaceScreenState();
}

class _TurboKartRaceScreenState extends ConsumerState<TurboKartRaceScreen> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final FocusNode _focusNode = FocusNode();
  
  // Game state
  bool _isStarted = false;
  int _countdown = 3;
  bool _isPaused = false;
  bool _isGameOver = false;
  int _place = 1;
  double _distance = 0;
  final double _trackLength = 2000;
  
  // Player kart state
  double _speed = 0;
  double _maxSpeed = 12.0;
  double _acceleration = 0.15;
  double _laneX = 0; // -1 to 1
  double _nitroAmount = 0;
  bool _isNitroActive = false;
  
  // AI Racers
  final List<_AIKart> _aiKarts = [
    _AIKart(id: 'Nova', laneX: -0.6, speedOffset: -0.2),
    _AIKart(id: 'Robo', laneX: 0.6, speedOffset: 0.1),
    _AIKart(id: 'Max', laneX: -0.3, speedOffset: 0.3),
  ];

  // World entities
  final List<_KartCoin> _coins = [];
  final List<_KartObstacle> _obstacles = [];

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_update);
    _startCountdown();
  }

  void _startCountdown() {
    Timer.periodic(1.seconds, (timer) {
      if (_isPaused) return;
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        setState(() {
          _countdown = 0;
          // Don't auto-start ticker, let the tutorial handle it
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _update(Duration elapsed) {
    if (_isPaused || _isGameOver || !_isStarted) return;

    final double dt = 1 / 60;
    
    setState(() {
      // 1. Player Physics
      if (_speed < _maxSpeed) _speed += _acceleration;
      if (_isNitroActive) {
        _speed = _maxSpeed * 1.5;
        _nitroAmount -= 0.01;
        if (_nitroAmount <= 0) {
          _nitroAmount = 0;
          _isNitroActive = false;
        }
      } else {
        _nitroAmount = (_nitroAmount + 0.001).clamp(0, 1);
      }

      _distance += _speed;

      // 2. AI Physics
      for (final ai in _aiKarts) {
        ai.distance += (_maxSpeed + ai.speedOffset);
      }

      // 3. Spawning
      if (math.Random().nextDouble() < 0.02) {
        _obstacles.add(_KartObstacle(math.Random().nextDouble() * 2 - 1, _distance + 800));
      }
      if (math.Random().nextDouble() < 0.05) {
        _coins.add(_KartCoin(math.Random().nextDouble() * 2 - 1, _distance + 800));
      }

      // 4. Collision
      _checkCollisions();

      // 5. Finishing
      if (_distance >= _trackLength) {
        _onFinish();
      }

      // Calculate placement
      int p = 1;
      for (final ai in _aiKarts) {
        if (ai.distance > _distance) p++;
      }
      _place = p;
    });
  }

  void _checkCollisions() {
    // Obstacles
    for (int i = _obstacles.length - 1; i >= 0; i--) {
      final obs = _obstacles[i];
      if ((obs.z - _distance).abs() < 20 && (obs.laneX - _laneX).abs() < 0.3) {
        _speed *= 0.5;
        _obstacles.removeAt(i);
        HapticFeedback.vibrate();
      } else if (obs.z < _distance - 100) {
        _obstacles.removeAt(i);
      }
    }
    // Coins
    for (int i = _coins.length - 1; i >= 0; i--) {
      final coin = _coins[i];
      if ((coin.z - _distance).abs() < 20 && (coin.laneX - _laneX).abs() < 0.3) {
        _coins.removeAt(i);
        ref.read(turboKartProvider.notifier).updateStats(coins: 10, xp: 5);
      } else if (coin.z < _distance - 100) {
        _coins.removeAt(i);
      }
    }
  }

  void _onFinish() {
    _isGameOver = true;
    _ticker.stop();
    
    int bonus = (4 - _place) * 100;
    ref.read(turboKartProvider.notifier).updateStats(coins: 100 + bonus, xp: 50, crystals: _place == 1 ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: _focusNode..requestFocus(),
        onKey: (event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              setState(() => _laneX = (_laneX - 0.1).clamp(-1, 1));
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              setState(() => _laneX = (_laneX + 0.1).clamp(-1, 1));
            } else if (event.logicalKey == LogicalKeyboardKey.keyN && _nitroAmount > 0.5) {
              setState(() => _isNitroActive = true);
            }
          }
        },
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              _laneX = (_laneX + details.delta.dx * 0.005).clamp(-1, 1);
            });
          },
          child: Stack(
            children: [
              // Road & Environment
              _buildRaceView(),

              // HUD
              _buildHUD(),

              // Pause Button
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause, color: Colors.white, size: 32),
                  onPressed: () => setState(() => _isPaused = !_isPaused),
                ),
              ),

              // Countdown Overlay
              if (_countdown > 0 && !_isPaused) _buildCountdown(),
              
              // Start Tutorial
              if (_countdown == 0 && !_isStarted) _buildKartTutorial(),

              // Result Overlay
              if (_isGameOver) _buildResultScreen(),
              
              // Pause Overlay
              if (_isPaused) _buildPauseMenu(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRaceView() {
    return CustomPaint(
      size: Size.infinite,
      painter: _KartRacePainter(
        playerX: _laneX,
        playerDist: _distance,
        aiKarts: _aiKarts,
        obstacles: _obstacles,
        coins: _coins,
        isNitro: _isNitroActive,
      ),
    );
  }

  Widget _buildHUD() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPlaceIndicator(),
                _buildProgressBar(),
                _buildNitroBar(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(16)),
      child: Text('$_place', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildProgressBar() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 10,
        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(5)),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: (_distance / _trackLength).clamp(0, 1),
          child: Container(decoration: BoxDecoration(color: Colors.greenAccent, borderRadius: BorderRadius.circular(5))),
        ),
      ),
    );
  }

  Widget _buildNitroBar() {
    return GestureDetector(
      onTap: () { if (_nitroAmount > 0.5) setState(() => _isNitroActive = true); },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: _isNitroActive ? Colors.orange : Colors.blueGrey.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(CupertinoIcons.bolt_fill, color: Colors.white),
      ),
    );
  }

  Widget _buildCountdown() {
    return Container(
      color: Colors.black26,
      child: Center(
        child: Text('$_countdown', style: const TextStyle(color: Colors.white, fontSize: 120, fontWeight: FontWeight.bold))
          .animate(key: ValueKey(_countdown)).scale(duration: 500.ms).fadeOut(delay: 500.ms),
      ),
    );
  }

  Widget _buildKartTutorial() {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: GlassCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("POYGA QOIDALARI 🏎️", style: AppTypography.heading3(color: Colors.white)),
              const SizedBox(height: 24),
              _buildTutRow(CupertinoIcons.arrow_left_right, "Chapga/O'ngga suring - Burilish"),
              _buildTutRow(CupertinoIcons.bolt_fill, "Nitro to'lganda bosing - Tezlanish"),
              _buildTutRow(CupertinoIcons.star_fill, "1-o'rinni oling va Kristal yuting!"),
              const SizedBox(height: 32),
              BouncyButton(
                text: "POYGANI BOSHLASH!",
                onTap: () {
                  setState(() {
                    _isStarted = true;
                    _ticker.start();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTutRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.orangeAccent, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: GlassCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_place == 1 ? "🏆 VICTORY!" : "🏁 FINISHED", style: AppTypography.heading1(color: Colors.yellowAccent)),
              const SizedBox(height: 20),
              Text("PLACE: $_place", style: AppTypography.heading3(color: Colors.white)),
              const SizedBox(height: 32),
              BouncyButton(text: "RETRY", onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const TurboKartRaceScreen()))),
              const SizedBox(height: 12),
              BouncyButton(text: "HOME", gradientStart: Colors.blueGrey, onTap: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPauseMenu() {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: GlassCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tr('game_paused'), style: AppTypography.heading2(color: Colors.white)),
              const SizedBox(height: 32),
              BouncyButton(
                text: tr('resume_btn'),
                icon: Icons.play_arrow,
                onTap: () => setState(() => _isPaused = false),
              ),
              const SizedBox(height: 12),
              BouncyButton(
                text: tr('restart_btn'),
                icon: Icons.refresh,
                gradientStart: Colors.blueGrey,
                onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const TurboKartRaceScreen()));
                },
              ),
              const SizedBox(height: 12),
              BouncyButton(
                text: tr('home_btn'),
                icon: Icons.home,
                gradientStart: Colors.redAccent,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn();
  }
}

class _AIKart {
  final String id;
  double laneX;
  double distance = 0;
  double speedOffset;
  _AIKart({required this.id, required this.laneX, required this.speedOffset});
}

class _KartCoin {
  double laneX;
  double z;
  _KartCoin(this.laneX, this.z);
}

class _KartObstacle {
  double laneX;
  double z;
  _KartObstacle(this.laneX, this.z);
}

class _KartRacePainter extends CustomPainter {
  final double playerX;
  final double playerDist;
  final List<_AIKart> aiKarts;
  final List<_KartObstacle> obstacles;
  final List<_KartCoin> coins;
  final bool isNitro;

  _KartRacePainter({
    required this.playerX,
    required this.playerDist,
    required this.aiKarts,
    required this.obstacles,
    required this.coins,
    required this.isNitro,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Sky
    paint.shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height), [const Color(0xFF1A2980), const Color(0xFF26D0CE)]);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    paint.shader = null;

    // 2. Road
    paint.color = Colors.grey.shade900;
    final path = Path();
    path.moveTo(center.dx - 50, center.dy);
    path.lineTo(center.dx + 50, center.dy);
    path.lineTo(size.width * 1.5, size.height);
    path.lineTo(-size.width * 0.5, size.height);
    path.close();
    canvas.drawPath(path, paint);

    // Road lines
    paint.color = Colors.white24;
    paint.strokeWidth = 4;
    for (int i = 0; i < 10; i++) {
      double z = (i * 200 - (playerDist % 200)) / 1000;
      if (z < 0) continue;
      double y = center.dy + (size.height - center.dy) * z;
      double w = size.width * z * 0.8;
      canvas.drawLine(Offset(center.dx - w, y), Offset(center.dx + w, y), paint);
    }

    // 3. Obstacles & Coins
    for (final obs in obstacles) {
      _drawEntity(canvas, center, size, obs.laneX, obs.z - playerDist, '🚧', 40);
    }
    for (final coin in coins) {
      _drawEntity(canvas, center, size, coin.laneX, coin.z - playerDist, '🪙', 30);
    }

    // 4. AI Karts
    for (final ai in aiKarts) {
      _drawEntity(canvas, center, size, ai.laneX, ai.distance - playerDist, '🏎️', 50);
    }

    // 5. Player
    _drawPlayer(canvas, size, center);
  }

  void _drawEntity(Canvas canvas, Offset center, Size size, double lx, double relZ, String emoji, double baseSize) {
    if (relZ <= 0 || relZ > 1000) return;
    double scale = 1 / (relZ / 100 + 1);
    double x = center.dx + (lx - playerX) * size.width * 0.5 * scale;
    double y = center.dy + (size.height - center.dy) * (relZ / 1000);
    
    final tp = TextPainter(text: TextSpan(text: emoji, style: TextStyle(fontSize: baseSize * scale * 2)), textDirection: ui.TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height));
  }

  void _drawPlayer(Canvas canvas, Size size, Offset center) {
    double x = size.width / 2;
    double y = size.height * 0.85;
    final tp = TextPainter(text: TextSpan(text: '🏎️', style: TextStyle(fontSize: 80, shadows: isNitro ? [const Shadow(color: Colors.orange, blurRadius: 20)] : [])), textDirection: ui.TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
