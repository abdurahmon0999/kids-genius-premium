import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/services/kids_providers.dart';
import '../../core/models/kids_models.dart';
import '../../core/widgets/bouncy_button.dart';
import '../../core/widgets/glass_card.dart';

class ZombieGameWidget extends ConsumerStatefulWidget {
  final VoidCallback onQuit;
  const ZombieGameWidget({super.key, required this.onQuit});

  @override
  ConsumerState<ZombieGameWidget> createState() => _ZombieGameWidgetState();
}

class _ZombieGameWidgetState extends ConsumerState<ZombieGameWidget> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  
  // Game state
  bool _isPaused = false;
  bool _isGameOver = false;
  bool _isLevelUpPending = false;
  int _score = 0;
  int _wave = 1;
  int _kills = 0;
  int _coinsEarned = 0;
  double _survivalTime = 0;
  
  // Player state
  Offset _playerPos = const Offset(200, 300);
  double _playerHp = 100;
  double _playerMaxHp = 100;
  double _playerXp = 0;
  double _playerMaxXp = 100;
  int _playerLevel = 1;
  double _playerSpeed = 3.5;
  
  // Weapon stats
  double _dmg = 25;
  double _fireRate = 0.5; // seconds between shots
  double _lastShotTime = 0;
  double _bulletSpeed = 8.0;
  double _critChance = 0.1;
  
  // Input
  Offset _moveDir = Offset.zero;
  Offset _lookDir = const Offset(1, 0);

  // Entities
  final List<_Zombie> _zombies = [];
  final List<_Bullet> _bullets = [];
  final List<_Particle> _particles = [];
  final List<_DamageNumber> _damageNumbers = [];

  // World size
  Size _worldSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _ticker.start();
    
    // Initial zombie spawn
    _startWave();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (_isPaused || _isGameOver || _isLevelUpPending) return;

    final double dt = 1 / 60; // 60 FPS target
    _survivalTime += dt;
    
    if (_shakeAmount > 0) {
      _shakeAmount *= 0.9; // decay
      if (_shakeAmount < 0.1) _shakeAmount = 0;
    }

    setState(() {
      _updatePlayer(dt);
      _updateZombies(dt);
      _updateBullets(dt);
      _updateParticles(dt);
      _updateDamageNumbers(dt);
      
      // Auto-shoot at nearest zombie
      if (_survivalTime - _lastShotTime >= _fireRate) {
        _shootAtNearest();
      }

      // Check if wave cleared
      if (_zombies.isEmpty && !_isGameOver) {
        _wave++;
        _startWave();
      }
    });
  }

  void _updatePlayer(double dt) {
    if (_moveDir != Offset.zero) {
      _playerPos += _moveDir * _playerSpeed;
      _lookDir = _moveDir; // Update aim direction to movement if not shooting
    }
    
    // Keep in bounds
    _playerPos = Offset(
      _playerPos.dx.clamp(20, _worldSize.width - 20),
      _playerPos.dy.clamp(20, _worldSize.height - 20),
    );
  }

  void _updateZombies(double dt) {
    for (int i = _zombies.length - 1; i >= 0; i--) {
      final z = _zombies[i];
      
      // Move towards player
      final dir = (_playerPos - z.pos);
      if (dir.distance > 5) {
        z.pos += dir / dir.distance * z.speed;
      }
      
      // Attack player
      if (dir.distance < 30) {
        _playerHp -= z.damage * dt;
        if (_playerHp <= 0) {
          _playerHp = 0;
          _onGameOver();
        }
      }
    }
  }

  void _updateBullets(double dt) {
    for (int i = _bullets.length - 1; i >= 0; i--) {
      final b = _bullets[i];
      b.pos += b.velocity;
      
      // Check collision with zombies
      bool hit = false;
      for (final z in _zombies) {
        if ((z.pos - b.pos).distance < 25) {
          bool isCrit = math.Random().nextDouble() < _critChance;
          double finalDmg = isCrit ? _dmg * 2 : _dmg;
          z.hp -= finalDmg;
          _damageNumbers.add(_DamageNumber(b.pos, finalDmg.toInt().toString(), isCrit: isCrit));
          _createImpactParticles(b.pos, AppColors.success);
          
          if (z.hp <= 0) {
            _onZombieKilled(z);
            _zombies.remove(z);
          }
          hit = true;
          break;
        }
      }
      
      if (hit || !_isInsideWorld(b.pos)) {
        _bullets.removeAt(i);
      }
    }
  }

  void _updateParticles(double dt) {
    for (int i = _particles.length - 1; i >= 0; i--) {
      _particles[i].life -= dt;
      _particles[i].pos += _particles[i].velocity;
      if (_particles[i].life <= 0) _particles.removeAt(i);
    }
  }

  void _updateDamageNumbers(double dt) {
    for (int i = _damageNumbers.length - 1; i >= 0; i--) {
      _damageNumbers[i].life -= dt;
      _damageNumbers[i].pos += const Offset(0, -1);
      if (_damageNumbers[i].life <= 0) _damageNumbers.removeAt(i);
    }
  }

  void _startWave() {
    int count = 5 + (_wave * 3);
    for (int i = 0; i < count; i++) {
      _spawnZombie();
    }
    if (_wave % 5 == 0) {
      _spawnZombie(isBoss: true);
    }
  }

  void _spawnZombie({bool isBoss = false}) {
    final rand = math.Random();
    // Spawn at edges
    double x, y;
    if (rand.nextBool()) {
      x = rand.nextBool() ? -50 : _worldSize.width + 50;
      y = rand.nextDouble() * _worldSize.height;
    } else {
      x = rand.nextDouble() * _worldSize.width;
      y = rand.nextBool() ? -50 : _worldSize.height + 50;
    }

    _ZombieType type = _ZombieType.normal;
    if (!isBoss) {
      double r = rand.nextDouble();
      if (_wave > 3 && r < 0.2) type = _ZombieType.fast;
      else if (_wave > 6 && r < 0.15) type = _ZombieType.tank;
    } else {
      type = _ZombieType.boss;
    }

    _zombies.add(_Zombie(Offset(x, y), type, _wave));
  }

  void _shootAtNearest() {
    if (_zombies.isEmpty) return;
    
    _Zombie? nearest;
    double minDist = 999999;
    for (final z in _zombies) {
      double d = (z.pos - _playerPos).distance;
      if (d < minDist) {
        minDist = d;
        nearest = z;
      }
    }

    if (nearest != null && minDist < 450) {
      final dir = (nearest.pos - _playerPos);
      final velocity = dir / dir.distance * _bulletSpeed;
      _bullets.add(_Bullet(_playerPos, velocity));
      _lastShotTime = _survivalTime;
      // Screen shake effect on shoot
      _triggerScreenShake();
    }
  }

  double _shakeAmount = 0;
  void _triggerScreenShake() {
    setState(() {
      _shakeAmount = 5.0;
    });
  }

  void _onZombieKilled(_Zombie z) {
    _score += z.xpValue;
    _kills++;
    _coinsEarned += z.coinValue;
    _playerXp += z.xpValue;
    
    if (_playerXp >= _playerMaxXp) {
      _onLevelUp();
    }
  }

  void _onLevelUp() {
    setState(() {
      _playerLevel++;
      _playerXp = 0;
      _playerMaxXp *= 1.2;
      _isLevelUpPending = true;
    });
  }

  void _applyUpgrade(String type) {
    setState(() {
      if (type == 'dmg') _dmg *= 1.2;
      if (type == 'rate') _fireRate *= 0.85;
      if (type == 'hp') {
        _playerMaxHp += 30;
        _playerHp = _playerMaxHp;
      }
      if (type == 'speed') _playerSpeed *= 1.1;
      if (type == 'crit') _critChance += 0.05;
      
      _isLevelUpPending = false;
    });
  }

  void _onGameOver() {
    _isGameOver = true;
    _ticker.stop();
    
    // Save stats to provider
    Future.delayed(Duration.zero, () {
      ref.read(zombieGameProvider.notifier).updateStats(
        score: _score,
        time: _survivalTime.toInt(),
        wave: _wave,
        kills: _kills,
        coins: _coinsEarned,
      );
    });
  }

  bool _isInsideWorld(Offset pos) {
    return pos.dx > -100 && pos.dx < _worldSize.width + 100 &&
           pos.dy > -100 && pos.dy < _worldSize.height + 100;
  }

  void _createImpactParticles(Offset pos, Color color) {
    for (int i = 0; i < 5; i++) {
      final rand = math.Random();
      final velocity = Offset(rand.nextDouble() * 4 - 2, rand.nextDouble() * 4 - 2);
      _particles.add(_Particle(pos, velocity, color));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _worldSize = Size(constraints.maxWidth, constraints.maxHeight);
        
        final shakeOffset = _shakeAmount > 0 
          ? Offset(math.Random().nextDouble() * _shakeAmount - _shakeAmount/2, 
                   math.Random().nextDouble() * _shakeAmount - _shakeAmount/2)
          : Offset.zero;

        return Container(
          color: const Color(0xFF0F0F15),
          child: Transform.translate(
            offset: shakeOffset,
            child: Stack(
              children: [
                // Game Canvas
                CustomPaint(
                  size: Size.infinite,
                  painter: _GamePainter(
                    playerPos: _playerPos,
                    zombies: _zombies,
                    bullets: _bullets,
                    particles: _particles,
                    damageNumbers: _damageNumbers,
                    lookDir: _lookDir,
                  ),
                ),
                
                // Content above canvas should NOT shake or at least be readable
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
                
                // Joystick
                Positioned(
                  bottom: 50,
                  left: 50,
                  child: _Joystick(
                    onDirectionChanged: (dir) => _moveDir = dir,
                  ),
                ),
                
                if (_isPaused && !_isGameOver && !_isLevelUpPending) _buildPauseOverlay(),
                if (_isLevelUpPending) _buildUpgradeOverlay(),
                if (_isGameOver) _buildGameOverOverlay(),
                
                if (!_isPaused && !_isGameOver)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: widget.onQuit,
                    ),
                  ),
              ],
            ),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🌊 ${tr('wave_text', args: [_wave.toString()])}', style: AppTypography.bodyBold(color: Colors.white)),
                    Text('⏱️ ${_survivalTime.toInt()}s', style: AppTypography.caption(color: Colors.white70)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('💰 $_coinsEarned', style: AppTypography.bodyBold(color: Colors.amber)),
                    Text('💀 $_kills', style: AppTypography.caption(color: Colors.redAccent)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // XP Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _playerXp / _playerMaxXp,
                minHeight: 8,
                backgroundColor: Colors.white10,
                color: Colors.purpleAccent,
              ),
            ),
            const SizedBox(height: 4),
            Text('LVL $_playerLevel', style: AppTypography.caption(color: Colors.purpleAccent)),
            const Spacer(),
            // HP Bar
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _playerHp / _playerMaxHp,
                      minHeight: 12,
                      backgroundColor: Colors.white10,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tr('choose_upgrade'), style: AppTypography.heading3(color: Colors.white)),
              const SizedBox(height: 20),
              _buildUpgradeOption('dmg', 'Attack Damage +20%', Icons.bolt, Colors.orange),
              _buildUpgradeOption('rate', 'Fire Rate +15%', Icons.speed, Colors.cyan),
              _buildUpgradeOption('hp', 'Heal & Max HP +30', Icons.favorite, Colors.redAccent),
            ],
          ),
        ),
      ),
    ).animate().fadeIn();
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
                icon: Icons.play_arrow,
                onTap: () => setState(() => _isPaused = false),
              ),
              const SizedBox(height: 12),
              BouncyButton(
                text: tr('restart_btn'),
                icon: Icons.refresh,
                gradientStart: Colors.blueGrey,
                onTap: () => setState(() => _resetGame()),
              ),
              const SizedBox(height: 12),
              BouncyButton(
                text: tr('exit_btn'),
                icon: Icons.exit_to_app,
                gradientStart: Colors.redAccent,
                onTap: widget.onQuit,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildUpgradeOption(String type, String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: BouncyButton(
        text: title,
        icon: icon,
        gradientStart: color,
        onTap: () => _applyUpgrade(type),
      ),
    );
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
              Text('Time: ${_survivalTime.toInt()}s', style: AppTypography.subtitle1(color: Colors.white70)),
              Text('Kills: $_kills', style: AppTypography.subtitle1(color: Colors.white70)),
              const SizedBox(height: 32),
              BouncyButton(
                text: tr('play_again_btn'),
                icon: Icons.refresh,
                onTap: () {
                  setState(() {
                    _resetGame();
                  });
                },
              ),
              const SizedBox(height: 12),
              BouncyButton(
                text: tr('home_btn'),
                icon: Icons.home,
                gradientStart: Colors.blueGrey,
                onTap: widget.onQuit,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn();
  }

  void _resetGame() {
    _isGameOver = false;
    _isPaused = false;
    _score = 0;
    _wave = 1;
    _kills = 0;
    _coinsEarned = 0;
    _survivalTime = 0;
    _playerHp = 100;
    _playerMaxHp = 100;
    _playerXp = 0;
    _playerMaxXp = 100;
    _playerLevel = 1;
    _playerPos = const Offset(200, 300);
    _zombies.clear();
    _bullets.clear();
    _particles.clear();
    _damageNumbers.clear();
    _startWave();
    _ticker.start();
  }
}

enum _ZombieType { normal, fast, tank, boss }

class _Zombie {
  Offset pos;
  double hp;
  final double maxHp;
  final double speed;
  final double damage;
  final int xpValue;
  final int coinValue;
  final _ZombieType type;

  _Zombie(this.pos, this.type, int wave) :
    maxHp = _getMaxHp(type, wave),
    hp = _getMaxHp(type, wave),
    speed = _getSpeed(type),
    damage = _getDamage(type, wave),
    xpValue = _getXp(type),
    coinValue = _getCoins(type) {
      // Set initial hp
      hp = maxHp;
    }

  static double _getMaxHp(_ZombieType t, int w) {
    double base = 50.0 + (w * 10);
    if (t == _ZombieType.fast) return base * 0.6;
    if (t == _ZombieType.tank) return base * 3.0;
    if (t == _ZombieType.boss) return base * 10.0;
    return base;
  }

  static double _getSpeed(_ZombieType t) {
    if (t == _ZombieType.fast) return 2.2;
    if (t == _ZombieType.tank) return 0.8;
    if (t == _ZombieType.boss) return 1.0;
    return 1.3;
  }

  static double _getDamage(_ZombieType t, int w) {
    double base = 5.0 + (w * 0.5);
    if (t == _ZombieType.tank) return base * 2.0;
    if (t == _ZombieType.boss) return base * 4.0;
    return base;
  }

  static int _getXp(_ZombieType t) {
    if (t == _ZombieType.fast) return 15;
    if (t == _ZombieType.tank) return 40;
    if (t == _ZombieType.boss) return 200;
    return 10;
  }

  static int _getCoins(_ZombieType t) {
    if (t == _ZombieType.fast) return 2;
    if (t == _ZombieType.tank) return 5;
    if (t == _ZombieType.boss) return 50;
    return 1;
  }
}

class _Bullet {
  Offset pos;
  final Offset velocity;
  _Bullet(this.pos, this.velocity);
}

class _Particle {
  Offset pos;
  final Offset velocity;
  final Color color;
  double life = 0.5;
  _Particle(this.pos, this.velocity, this.color);
}

class _DamageNumber {
  Offset pos;
  final String text;
  final bool isCrit;
  double life = 1.0;
  _DamageNumber(this.pos, this.text, {this.isCrit = false});
}

class _GamePainter extends CustomPainter {
  final Offset playerPos;
  final List<_Zombie> zombies;
  final List<_Bullet> bullets;
  final List<_Particle> particles;
  final List<_DamageNumber> damageNumbers;
  final Offset lookDir;

  _GamePainter({
    required this.playerPos,
    required this.zombies,
    required this.bullets,
    required this.particles,
    required this.damageNumbers,
    required this.lookDir,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Draw grid/background decor
    paint.color = Colors.white.withValues(alpha: 0.03);
    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Draw Particles
    for (final p in particles) {
      paint.color = p.color.withValues(alpha: p.life * 2);
      canvas.drawCircle(p.pos, 2, paint);
    }

    // Draw Zombies
    for (final z in zombies) {
      _drawZombie(canvas, z);
    }

    // Draw Bullets
    paint.color = Colors.yellowAccent;
    for (final b in bullets) {
      canvas.drawCircle(b.pos, 3, paint);
    }

    // Draw Player
    _drawPlayer(canvas);

    // Draw Damage Numbers
    for (final dn in damageNumbers) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: dn.text,
          style: TextStyle(
            color: dn.isCrit ? Colors.orange : Colors.white,
            fontWeight: dn.isCrit ? FontWeight.bold : FontWeight.normal,
            fontSize: dn.isCrit ? 18 : 14,
            shadows: const [Shadow(blurRadius: 2, color: Colors.black)],
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, dn.pos);
    }
  }

  void _drawPlayer(Canvas canvas) {
    final paint = Paint()..color = AppColors.primary;
    canvas.drawCircle(playerPos, 20, paint);
    
    // Draw "Guide Lion" emoji or just a face
    final textPainter = TextPainter(
      text: const TextSpan(text: '🦁', style: TextStyle(fontSize: 24)),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, playerPos - const Offset(12, 16));

    // Direction indicator
    final aimPaint = Paint()..color = Colors.white24..strokeWidth = 2;
    canvas.drawLine(playerPos, playerPos + lookDir * 40, aimPaint);
  }

  void _drawZombie(Canvas canvas, _Zombie z) {
    Color color = Colors.greenAccent;
    String emoji = '🧟';
    double size = 20;

    if (z.type == _ZombieType.fast) {
      color = Colors.orangeAccent;
      emoji = '🏃';
    } else if (z.type == _ZombieType.tank) {
      color = Colors.red;
      emoji = '👹';
      size = 30;
    } else if (z.type == _ZombieType.boss) {
      color = Colors.purple;
      emoji = '💀';
      size = 50;
    }

    final paint = Paint()..color = color.withValues(alpha: 0.3);
    canvas.drawCircle(z.pos, size, paint);

    final textPainter = TextPainter(
      text: TextSpan(text: emoji, style: TextStyle(fontSize: size * 1.2)),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, z.pos - Offset(size * 0.6, size * 0.8));

    // HP Bar for zombie
    if (z.hp < z.maxHp) {
      final hpPaint = Paint()..color = Colors.red;
      final bgPaint = Paint()..color = Colors.black26;
      double barW = size * 2;
      canvas.drawRect(Rect.fromLTWH(z.pos.dx - size, z.pos.dy - size - 10, barW, 4), bgPaint);
      canvas.drawRect(Rect.fromLTWH(z.pos.dx - size, z.pos.dy - size - 10, barW * (z.hp / z.maxHp), 4), hpPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Joystick extends StatefulWidget {
  final ValueChanged<Offset> onDirectionChanged;
  const _Joystick({required this.onDirectionChanged});

  @override
  State<_Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<_Joystick> {
  Offset _dragPos = Offset.zero;
  final double _radius = 60;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _dragPos += details.delta;
          if (_dragPos.distance > _radius) {
            _dragPos = _dragPos / _dragPos.distance * _radius;
          }
        });
        widget.onDirectionChanged(_dragPos / _radius);
      },
      onPanEnd: (details) {
        setState(() {
          _dragPos = Offset.zero;
        });
        widget.onDirectionChanged(Offset.zero);
      },
      child: Container(
        width: _radius * 2,
        height: _radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.1),
          border: Border.all(color: Colors.white24, width: 2),
        ),
        child: Center(
          child: Transform.translate(
            offset: _dragPos,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white54,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
