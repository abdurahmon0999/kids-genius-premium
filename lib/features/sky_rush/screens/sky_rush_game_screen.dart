import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/bouncy_button.dart';
import '../../../core/services/kids_providers.dart';

class SkyRushGameScreen extends ConsumerStatefulWidget {
  const SkyRushGameScreen({super.key});

  @override
  ConsumerState<SkyRushGameScreen> createState() => _SkyRushGameScreenState();
}

class _SkyRushGameScreenState extends ConsumerState<SkyRushGameScreen> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final FocusNode _focusNode = FocusNode();
  
  // Game state
  bool _isStarted = false;
  bool _isPaused = false;
  bool _isGameOver = false;
  int _score = 0;
  int _coins = 0;
  int _crystals = 0;
  double _distance = 0;
  double _speed = 5.0;
  int _lives = 3;
  
  // Player position (Lanes: -1, 0, 1)
  int _targetLane = 0;
  double _currentLanePos = 0;
  double _playerY = 0; // Jump/Slide
  double _jumpVelocity = 0;
  bool _isGrounded = true;
  bool _isSliding = false;
  
  // Power-ups
  bool _hasShield = false;
  bool _hasMagnet = false;
  double _powerUpTime = 0;

  // Entities
  final List<_SkyObstacle> _obstacles = [];
  final List<_SkyCoin> _coinsList = [];
  final List<_SkyParticle> _particles = [];
  
  double _nextSpawnTime = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_update);
    _ticker.start();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _update(Duration elapsed) {
    if (!_isStarted || _isPaused || _isGameOver) return;

    final double dt = 1 / 60;
    
    setState(() {
      _distance += _speed * dt;
      _speed += 0.001; // Gradual speed increase
      
      // Smooth lane movement
      _currentLanePos += (_targetLane - _currentLanePos) * 0.15;
      
      // Jump physics
      if (!_isGrounded) {
        _playerY += _jumpVelocity;
        _jumpVelocity -= 0.8; // Gravity
        if (_playerY <= 0) {
          _playerY = 0;
          _isGrounded = true;
          _jumpVelocity = 0;
        }
      }

      // Power-ups timer
      if (_powerUpTime > 0) {
        _powerUpTime -= dt;
        if (_powerUpTime <= 0) {
          _hasShield = false;
          _hasMagnet = false;
        }
      }

      // Spawning
      if (_distance >= _nextSpawnTime) {
        _spawnPattern();
        _nextSpawnTime = _distance + 20 + math.Random().nextDouble() * 30;
      }

      // Update obstacles
      for (int i = _obstacles.length - 1; i >= 0; i--) {
        _obstacles[i].z -= _speed * dt;
        
        // Collision check
        if (_obstacles[i].z > -1 && _obstacles[i].z < 1) {
          if (_obstacles[i].lane == _targetLane && _playerY < 50 && !_isSliding) {
            _onHit();
            _obstacles.removeAt(i);
            continue;
          }
        }
        
        if (_obstacles[i].z < -10) _obstacles.removeAt(i);
      }

      // Update coins
      for (int i = _coinsList.length - 1; i >= 0; i--) {
        _coinsList[i].z -= _speed * dt;
        
        // Magnet effect
        if (_hasMagnet && _coinsList[i].z < 50) {
          _coinsList[i].lane += (_targetLane - _coinsList[i].lane) * 0.1;
        }

        // Collection
        if (_coinsList[i].z > -1 && _coinsList[i].z < 1) {
          if (_coinsList[i].lane.round() == _targetLane) {
            _coins++;
            _score += 10;
            _createImpactParticles(Offset(_currentLanePos * 100, -_playerY), Colors.yellow);
            _coinsList.removeAt(i);
            continue;
          }
        }
        
        if (_coinsList[i].z < -10) _coinsList.removeAt(i);
      }

      // Update particles
      for (int i = _particles.length - 1; i >= 0; i--) {
        _particles[i].life -= dt;
        _particles[i].pos += _particles[i].velocity;
        if (_particles[i].life <= 0) _particles.removeAt(i);
      }
    });
  }

  void _spawnPattern() {
    int lane = math.Random().nextInt(3) - 1;
    _obstacles.add(_SkyObstacle(lane, 300));
    
    // Spawn some coins
    for (int i = 0; i < 5; i++) {
      _coinsList.add(_SkyCoin(lane.toDouble(), 200 + i * 15.0));
    }
  }

  void _onHit() {
    if (_hasShield) {
      _hasShield = false;
      _powerUpTime = 0;
      return;
    }
    
    HapticFeedback.heavyImpact();
    setState(() {
      _lives--;
      if (_lives <= 0) _onGameOver();
    });
  }

  void _onGameOver() {
    _isGameOver = true;
    _ticker.stop();
    
    Future.delayed(Duration.zero, () {
      ref.read(skyRushProvider.notifier).updateStats(
        score: _score,
        coins: _coins,
        crystals: _crystals,
        xp: (_distance / 10).toInt(),
      );
    });
  }

  void _createImpactParticles(Offset pos, Color color) {
    for (int i = 0; i < 8; i++) {
      final rand = math.Random();
      final velocity = Offset(rand.nextDouble() * 10 - 5, rand.nextDouble() * 10 - 5);
      _particles.add(_SkyParticle(pos, velocity, color));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: (event) {
          if (!_isStarted || _isPaused || _isGameOver) return;
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.keyA) {
              if (_targetLane > -1) setState(() => _targetLane--);
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.keyD) {
              if (_targetLane < 1) setState(() => _targetLane++);
            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp || event.logicalKey == LogicalKeyboardKey.keyW || event.logicalKey == LogicalKeyboardKey.space) {
              if (_isGrounded) setState(() { _isGrounded = false; _jumpVelocity = 15; });
            } else if (event.logicalKey == LogicalKeyboardKey.arrowDown || event.logicalKey == LogicalKeyboardKey.keyS) {
              if (!_isSliding) {
                setState(() => _isSliding = true);
                Future.delayed(500.ms, () { if (mounted) setState(() => _isSliding = false); });
              }
            }
          }
        },
        child: GestureDetector(
          onVerticalDragEnd: (details) {
            if (!_isStarted || _isPaused || _isGameOver) return;
            final vel = details.primaryVelocity ?? 0;
            if (vel < -300) { // Up
              if (_isGrounded) setState(() { _isGrounded = false; _jumpVelocity = 15; });
            } else if (vel > 300) { // Down
              if (!_isSliding) {
                setState(() => _isSliding = true);
                Future.delayed(500.ms, () { if (mounted) setState(() => _isSliding = false); });
              }
            }
          },
          onHorizontalDragEnd: (details) {
            if (!_isStarted || _isPaused || _isGameOver) return;
            final vel = details.primaryVelocity ?? 0;
            if (vel < -300) { // Left
              if (_targetLane > -1) setState(() => _targetLane--);
            } else if (vel > 300) { // Right
              if (_targetLane < 1) setState(() => _targetLane++);
            }
          },
          child: Stack(
            children: [
              // Background & World
              _buildWorldPainter(),

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

              if (_isPaused) _buildPauseOverlay(),
              if (_isGameOver) _buildGameOverOverlay(),
              
              if (!_isStarted) _buildStartOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: GlassCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("QANDAY O'YNASH KERAK?", style: AppTypography.heading3(color: Colors.white)),
              const SizedBox(height: 24),
              _buildTutorialRow(CupertinoIcons.arrow_left_right, "Chapga/O'ngga suring - Burilish"),
              _buildTutorialRow(CupertinoIcons.arrow_up, "Tepaga suring - Sakrash"),
              _buildTutorialRow(CupertinoIcons.arrow_down, "Pastga suring - Slide qilish"),
              const SizedBox(height: 32),
              BouncyButton(
                text: "TUSHUNARLI, BOSHLASH!",
                onTap: () => setState(() => _isStarted = true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildWorldPainter() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size.infinite,
          painter: _SkyRushPainter(
            lanePos: _currentLanePos,
            playerY: _playerY,
            isSliding: _isSliding,
            obstacles: _obstacles,
            coins: _coinsList,
            particles: _particles,
            distance: _distance,
          ),
        );
      },
    );
  }

  Widget _buildHUD() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLivesIndicator(),
                Column(
                  children: [
                    Text(tr('distance'), style: AppTypography.caption(color: Colors.white70)),
                    Text('${_distance.toInt()}m', style: AppTypography.heading3(color: Colors.white)),
                  ],
                ),
                _buildTopStat('🪙', _coins.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivesIndicator() {
    return Row(
      children: List.generate(3, (i) => Icon(
        CupertinoIcons.heart_fill, 
        color: i < _lives ? Colors.redAccent : Colors.white24,
        size: 24,
      )),
    );
  }

  Widget _buildTopStat(String emoji, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(val, style: AppTypography.bodyBold(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildPauseOverlay() {
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
                onTap: () => setState(() => _isPaused = false),
              ),
              const SizedBox(height: 12),
              BouncyButton(
                text: tr('home_btn'),
                gradientStart: Colors.blueGrey,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildGameOverOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.9),
      child: Center(
        child: GlassCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tr('game_over_title'), style: AppTypography.heading1(color: Colors.redAccent)),
              const SizedBox(height: 20),
              Text('Score: $_score', style: AppTypography.heading3(color: Colors.white)),
              Text('Distance: ${_distance.toInt()}m', style: AppTypography.subtitle1(color: Colors.white70)),
              const SizedBox(height: 32),
              BouncyButton(
                text: tr('play_again_btn'),
                onTap: () {
                  setState(() {
                    _resetGame();
                  });
                },
              ),
              const SizedBox(height: 12),
              BouncyButton(
                text: tr('home_btn'),
                gradientStart: Colors.blueGrey,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn();
  }

  void _resetGame() {
    _isGameOver = false;
    _score = 0;
    _coins = 0;
    _crystals = 0;
    _distance = 0;
    _speed = 5.0;
    _lives = 3;
    _targetLane = 0;
    _currentLanePos = 0;
    _playerY = 0;
    _obstacles.clear();
    _coinsList.clear();
    _particles.clear();
    _ticker.start();
  }
}

class _SkyObstacle {
  int lane;
  double z;
  _SkyObstacle(this.lane, this.z);
}

class _SkyCoin {
  double lane;
  double z;
  _SkyCoin(this.lane, this.z);
}

class _SkyParticle {
  Offset pos;
  Offset velocity;
  Color color;
  double life = 1.0;
  _SkyParticle(this.pos, this.velocity, this.color);
}

class _SkyRushPainter extends CustomPainter {
  final double lanePos;
  final double playerY;
  final bool isSliding;
  final List<_SkyObstacle> obstacles;
  final List<_SkyCoin> coins;
  final List<_SkyParticle> particles;
  final double distance;

  _SkyRushPainter({
    required this.lanePos,
    required this.playerY,
    required this.isSliding,
    required this.obstacles,
    required this.coins,
    required this.particles,
    required this.distance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint();

    // 1. Draw Background (Sky Gradient)
    final skyGradient = LinearGradient(
      colors: [const Color(0xFF0F0C29), const Color(0xFF302B63)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    paint.shader = skyGradient;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    paint.shader = null;

    // 2. Draw Floor (Futuristic Track)
    _drawTrack(canvas, size, center);

    // 3. Draw Obstacles (3D Perspective)
    for (final obs in obstacles) {
      _drawEntity(canvas, center, obs.lane, obs.z, size, Colors.redAccent, '🚧');
    }

    // 4. Draw Coins
    for (final coin in coins) {
      _drawEntity(canvas, center, coin.lane.toInt(), coin.z, size, Colors.amber, '🪙');
    }

    // 5. Draw Player (🦁)
    _drawPlayer(canvas, center, size);
    
    // 6. Draw Particles
    for (final p in particles) {
      paint.color = p.color.withValues(alpha: p.life);
      canvas.drawCircle(center + p.pos, 3 * p.life, paint);
    }
  }

  void _drawTrack(Canvas canvas, Size size, Offset center) {
    final paint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    double perspective = 0.8;
    double trackW = size.width * 1.5;
    
    // Lane lines
    for (int i = -2; i <= 2; i++) {
      double xStart = center.dx + (i * trackW / 4);
      double xEnd = center.dx + (i * trackW / 10);
      canvas.drawLine(Offset(xStart, size.height), Offset(xEnd, center.dy), paint);
    }

    // Horizontal lines (Moving effect)
    double offset = (distance % 50) / 50;
    for (int i = 0; i < 10; i++) {
      double z = i + offset;
      double y = center.dy + (size.height - center.dy) * (1 / (z + 1));
      double w = size.width * (1 / (z + 1)) * perspective;
      canvas.drawLine(Offset(center.dx - w, y), Offset(center.dx + w, y), paint);
    }
  }

  void _drawEntity(Canvas canvas, Offset center, int lane, double z, Size size, Color color, String emoji) {
    if (z <= 0) return;
    
    double scale = 10 / (z + 10);
    if (scale < 0.05) return;

    double x = center.dx + (lane * (size.width * 0.4) * scale);
    double y = center.dy + (size.height * 0.4) * scale;
    
    final textPainter = TextPainter(
      text: TextSpan(text: emoji, style: TextStyle(fontSize: 80 * scale)),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - (40 * scale), y - (40 * scale)));
  }

  void _drawPlayer(Canvas canvas, Offset center, Size size) {
    double x = center.dx + (lanePos * (size.width * 0.4) * 0.8);
    double y = size.height * 0.85 - playerY;

    if (isSliding) y += 20;

    final textPainter = TextPainter(
      text: TextSpan(text: '🦁', style: TextStyle(fontSize: isSliding ? 40 : 60)),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    
    // Shadow
    final shadowPaint = Paint()..color = Colors.black26;
    canvas.drawOval(Rect.fromCenter(center: Offset(x, size.height * 0.88), width: 40, height: 10), shadowPaint);
    
    textPainter.paint(canvas, Offset(x - (isSliding ? 20 : 30), y - (isSliding ? 20 : 30)));

    // Hero Trail
    final trailPaint = Paint()..color = Colors.cyanAccent.withValues(alpha: 0.3);
    canvas.drawCircle(Offset(x, y + 20), 10, trailPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
